import UIKit

class SessionsViewController: UIViewController {

    private let sessionManager = SessionManager.shared
    private let tableView = UITableView()
    private var sessions: [PhotoSession] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSessions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSessions()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Photo Sessions"

        setupTableView()
        setupNavigationBar()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SessionTableViewCell.self, forCellReuseIdentifier: "SessionCell")
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 120

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllSessions)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }

    private func loadSessions() {
        sessions = sessionManager.getCompletedSessions().sorted { $0.timestamp > $1.timestamp }
        tableView.reloadData()

        if sessions.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }

    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No photo sessions yet.\nTake some photos to get started!"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = UIFont.systemFont(ofSize: 18)
        emptyLabel.numberOfLines = 0
        emptyLabel.tag = 999

        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func hideEmptyState() {
        view.subviews.first { $0.tag == 999 }?.removeFromSuperview()
    }

    @objc private func clearAllSessions() {
        let alert = UIAlertController(
            title: "Clear All Sessions",
            message: "This will permanently delete all photo sessions. This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive) { [weak self] _ in
            self?.performClearAll()
        })

        present(alert, animated: true)
    }

    private func performClearAll() {
        for session in sessions {
            try? sessionManager.deleteSession(session)
        }
        loadSessions()
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    private func deleteSession(at indexPath: IndexPath) {
        let session = sessions[indexPath.row]

        let alert = UIAlertController(
            title: "Delete Session",
            message: "This will permanently delete this photo session and all its photos.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            do {
                try self?.sessionManager.deleteSession(session)
                self?.sessions.remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .fade)

                if self?.sessions.isEmpty == true {
                    self?.showEmptyState()
                }
            } catch {
                self?.showError("Failed to delete session: \(error.localizedDescription)")
            }
        })

        present(alert, animated: true)
    }

    private func shareSession(_ session: PhotoSession) {
        let images = sessionManager.getSessionPhotos(session)

        // Create photo strip
        if let stripImage = sessionManager.generatePhotoStrip(for: session) {
            var itemsToShare: [Any] = [stripImage]
            itemsToShare.append(contentsOf: images)

            let activityController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = view
            present(activityController, animated: true)
        } else {
            showError("Unable to create photo strip")
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Data Source & Delegate

extension SessionsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as? SessionTableViewCell else {
            fatalError("Unable to dequeue SessionTableViewCell")
        }
        let session = sessions[indexPath.row]
        cell.configure(with: session, sessionManager: sessionManager)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let session = sessions[indexPath.row]

        let reviewVC = ReviewViewController()
        reviewVC.photos = session.photos
        navigationController?.pushViewController(reviewVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteSession(at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, completion in
            let session = self?.sessions[indexPath.row]
            if let session = session {
                self?.shareSession(session)
            }
            completion(true)
        }
        shareAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [shareAction])
    }
}

// MARK: - Custom Table View Cell

class SessionTableViewCell: UITableViewCell {

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let photoCountLabel = UILabel()
    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        setupThumbnail()
        setupLabels()
        setupLayout()
    }

    private func setupThumbnail() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.backgroundColor = .systemGray5
    }

    private func setupLabels() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label

        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel

        photoCountLabel.font = UIFont.systemFont(ofSize: 12)
        photoCountLabel.textColor = .systemBlue
        photoCountLabel.textAlignment = .right

        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(photoCountLabel)
    }

    private func setupLayout() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(stackView)

        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 80),

            stackView.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with session: PhotoSession, sessionManager: SessionManager) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        titleLabel.text = "Photo Session"
        subtitleLabel.text = dateFormatter.string(from: session.timestamp)
        photoCountLabel.text = "\(session.photos.count) photos"

        // Load thumbnail from first photo
        if let firstPhoto = session.photos.first,
           let image = PhotoStorage.shared.loadPhoto(id: firstPhoto.id) {
            thumbnailImageView.image = image
        } else {
            thumbnailImageView.image = nil
        }
    }
}