import UIKit

protocol ReviewViewControllerDelegate: AnyObject {
    func reviewViewControllerDidFinishSession(_ viewController: ReviewViewController)
    func reviewViewControllerDidRetakePhotos(_ viewController: ReviewViewController)
}

class ReviewViewController: UIViewController {

    weak var delegate: ReviewViewControllerDelegate?
    var photos: [Photo] = []
    var selectedLayout: LayoutTemplate = LayoutTemplate(name: "Photo Strip", description: "3 photos + text strip", photoCount: 3, aspectRatio: CGSize(width: 2, height: 6))

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let actionStackView = UIStackView()

    private let shareButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let retakeButton = UIButton(type: .system)
    private let finishButton = UIButton(type: .system)

    private var photoStripImageView: UIImageView?
    private var photoStripImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPhotos()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Review Photos"

        setupScrollView()
        setupActionButtons()
        setupNavigationBar()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func setupActionButtons() {
        view.addSubview(actionStackView)
        actionStackView.translatesAutoresizingMaskIntoConstraints = false

        actionStackView.axis = .horizontal
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 16
        actionStackView.alignment = .fill

        [shareButton, saveButton, retakeButton, finishButton].forEach { button in
            actionStackView.addArrangedSubview(button)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }

        shareButton.setTitle("Share", for: .normal)
        shareButton.backgroundColor = .systemBlue
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)

        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        retakeButton.setTitle("Retake", for: .normal)
        retakeButton.backgroundColor = .systemOrange
        retakeButton.setTitleColor(.white, for: .normal)
        retakeButton.addTarget(self, action: #selector(retakeButtonTapped), for: .touchUpInside)

        finishButton.setTitle("Finish", for: .normal)
        finishButton.backgroundColor = .systemPurple
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            actionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            actionStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }

    private func loadPhotos() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Create and display photo strip
        createPhotoStrip()

        // Only show individual photos if not in wedding mode
        if !PhotoStripComposer.shared.isWeddingTheme {
            // Add individual photos
            for (index, photo) in photos.enumerated() {
                if let image = PhotoStorage.shared.loadPhoto(id: photo.id) {
                    let photoView = createPhotoView(image: image, index: index)
                    stackView.addArrangedSubview(photoView)
                }
            }
        } else {
            // In wedding mode, add a message about the beautiful memories
            addWeddingMessage()
        }
    }

    private func createPhotoStrip() {
        let images = photos.compactMap { PhotoStorage.shared.loadPhoto(id: $0.id) }
        guard !images.isEmpty else { return }

        photoStripImage = PhotoStripComposer.shared.createPhotoStrip(from: images, layout: selectedLayout)

        if let stripImage = photoStripImage {
            let stripContainer = createPhotoStripView(image: stripImage)
            stackView.addArrangedSubview(stripContainer)

            // Add a separator
            let separator = UIView()
            separator.backgroundColor = .separator
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            stackView.addArrangedSubview(separator)
        }
    }

    private func createPhotoStripView(image: UIImage) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1

        let titleLabel = UILabel()
        if PhotoStripComposer.shared.isWeddingTheme {
            titleLabel.text = "♥ \(PhotoStripComposer.shared.coupleNames) Wedding Memories ♥"
            titleLabel.textColor = .systemPink
        } else {
            titleLabel.text = "Photo Strip - \(selectedLayout.name)"
            titleLabel.textColor = .label
        }
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .white
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowRadius = 8
        imageView.layer.shadowOpacity = 0.2

        photoStripImageView = imageView

        containerView.addSubview(titleLabel)
        containerView.addSubview(imageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Calculate screen-fitting height for the photo strip
        let screenHeight = UIScreen.main.bounds.height
        let availableHeight = screenHeight - 150 // Account for navigation, title, button, and margins
        let photoStripHeight = max(min(availableHeight * 0.9, 1000), 500) // 90% of available height, max 1000, min 500

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: photoStripHeight),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        return containerView
    }

    private func addWeddingMessage() {
        let messageContainer = UIView()
        messageContainer.backgroundColor = .systemPink.withAlphaComponent(0.1)
        messageContainer.layer.cornerRadius = 12
        messageContainer.layer.borderWidth = 1
        messageContainer.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.3).cgColor

        let heartsLabel = UILabel()
        heartsLabel.text = "♥ ♥ ♥"
        heartsLabel.font = UIFont.systemFont(ofSize: 28)
        heartsLabel.textColor = .systemPink
        heartsLabel.textAlignment = .center

        let messageLabel = UILabel()
        messageLabel.text = "Your beautiful wedding memories are captured above in the photo strip.\n\nShare this special moment with your loved ones!"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .label
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let dateLabel = UILabel()
        dateLabel.text = PhotoStripComposer.shared.weddingDate
        dateLabel.font = UIFont.italicSystemFont(ofSize: 14)
        dateLabel.textColor = .systemPink
        dateLabel.textAlignment = .center

        messageContainer.addSubview(heartsLabel)
        messageContainer.addSubview(messageLabel)
        messageContainer.addSubview(dateLabel)

        heartsLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heartsLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 20),
            heartsLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 16),
            heartsLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: heartsLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -20)
        ])

        stackView.addArrangedSubview(messageContainer)
    }

    private func createPhotoView(image: UIImage, index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8

        let label = UILabel()
        label.text = "Photo \(index + 1)"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center

        containerView.addSubview(imageView)
        containerView.addSubview(label)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            imageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 300),

            containerView.heightAnchor.constraint(equalToConstant: 350)
        ])

        return containerView
    }

    @objc private func shareButtonTapped() {
        var itemsToShare: [UIImage] = []

        // Add photo strip if available
        if let stripImage = photoStripImage {
            itemsToShare.append(stripImage)
        }

        // Add individual photos
        let images = photos.compactMap { PhotoStorage.shared.loadPhoto(id: $0.id) }
        itemsToShare.append(contentsOf: images)

        guard !itemsToShare.isEmpty else {
            showAlert(title: "Error", message: "No photos to share")
            return
        }

        let activityController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = shareButton

        present(activityController, animated: true)
    }

    @objc private func saveButtonTapped() {
        var imagesToSave: [UIImage] = []

        // Add photo strip if available
        if let stripImage = photoStripImage {
            imagesToSave.append(stripImage)
        }

        // Add individual photos
        let images = photos.compactMap { PhotoStorage.shared.loadPhoto(id: $0.id) }
        imagesToSave.append(contentsOf: images)

        guard !imagesToSave.isEmpty else {
            showAlert(title: "Error", message: "No photos to save")
            return
        }

        var savedCount = 0

        for image in imagesToSave {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            savedCount += 1
        }

        let stripText = photoStripImage != nil ? " (including photo strip)" : ""
        showAlert(title: "Success", message: "Saved \(savedCount) photos to your photo library\(stripText)")
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Save Error", message: error.localizedDescription)
        }
    }

    @objc private func retakeButtonTapped() {
        let alert = UIAlertController(
            title: "Retake Photos",
            message: "Are you sure you want to retake all photos? This will delete the current session.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Retake", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.reviewViewControllerDidRetakePhotos(self)
        })

        present(alert, animated: true)
    }

    @objc private func finishButtonTapped() {
        delegate?.reviewViewControllerDidFinishSession(self)
    }


    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}