import UIKit

protocol LayoutSelectionDelegate: AnyObject {
    func layoutSelectionDidSelectLayout(_ layout: LayoutTemplate)
}

class LayoutSelectionViewController: UIViewController {

    weak var delegate: LayoutSelectionDelegate?

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let layouts = LayoutTemplate.defaultLayouts

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Choose Layout"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(LayoutCell.self, forCellWithReuseIdentifier: "LayoutCell")

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

extension LayoutSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layouts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayoutCell", for: indexPath) as? LayoutCell else {
            fatalError("Unable to dequeue LayoutCell")
        }
        cell.configure(with: layouts[indexPath.item])
        return cell
    }
}

extension LayoutSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLayout = layouts[indexPath.item]
        delegate?.layoutSelectionDidSelectLayout(selectedLayout)
    }
}

extension LayoutSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let spacing: CGFloat = 16
        let width = (view.frame.width - (padding * 2) - spacing) / 2
        return CGSize(width: width, height: width * 1.2)
    }
}

class LayoutCell: UICollectionViewCell {

    private let previewView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let photoCountLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1

        setupPreviewView()
        setupLabels()
    }

    private func setupPreviewView() {
        addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.backgroundColor = .tertiarySystemBackground
        previewView.layer.cornerRadius = 8

        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            previewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            previewView.heightAnchor.constraint(equalTo: previewView.widthAnchor, multiplier: 0.8)
        ])
    }

    private func setupLabels() {
        [titleLabel, descriptionLabel, photoCountLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 2

        photoCountLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        photoCountLabel.textColor = .systemBlue
        photoCountLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            photoCountLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            photoCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            photoCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            photoCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])
    }

    func configure(with layout: LayoutTemplate) {
        titleLabel.text = layout.name
        descriptionLabel.text = layout.description
        photoCountLabel.text = "\(layout.photoCount) photos"

        setupPreviewLayout(for: layout)
    }

    private func setupPreviewLayout(for layout: LayoutTemplate) {
        previewView.subviews.forEach { $0.removeFromSuperview() }

        let photoViews = (0..<layout.photoCount).map { _ in
            let view = UIView()
            view.backgroundColor = .systemGray4
            view.layer.cornerRadius = 4
            return view
        }

        photoViews.forEach { previewView.addSubview($0) }

        switch layout.photoCount {
        case 1:
            if !photoViews.isEmpty {
                layoutSinglePhoto(photoViews[0])
            }
        case 4 where layout.name.contains("Strip"):
            layoutPhotoStrip(photoViews)
        case 4:
            layoutGrid2x2(photoViews)
        case 6:
            layoutCollage(photoViews)
        default:
            if !photoViews.isEmpty {
                layoutSinglePhoto(photoViews[0])
            }
        }
    }

    private func layoutSinglePhoto(_ photoView: UIView) {
        photoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 4),
            photoView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 4),
            photoView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -4),
            photoView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -4)
        ])
    }

    private func layoutPhotoStrip(_ photoViews: [UIView]) {
        for (index, photoView) in photoViews.enumerated() {
            photoView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                photoView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 4),
                photoView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -4),
                photoView.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.22)
            ])

            if index == 0 {
                photoView.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 4).isActive = true
            } else {
                photoView.topAnchor.constraint(equalTo: photoViews[index - 1].bottomAnchor, constant: 2).isActive = true
            }
        }
    }

    private func layoutGrid2x2(_ photoViews: [UIView]) {
        for (index, photoView) in photoViews.enumerated() {
            photoView.translatesAutoresizingMaskIntoConstraints = false

            let row = index / 2
            let col = index % 2

            NSLayoutConstraint.activate([
                photoView.widthAnchor.constraint(equalTo: previewView.widthAnchor, multiplier: 0.47),
                photoView.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.47)
            ])

            if col == 0 {
                photoView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 4).isActive = true
            } else {
                photoView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -4).isActive = true
            }

            if row == 0 {
                photoView.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 4).isActive = true
            } else {
                photoView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -4).isActive = true
            }
        }
    }

    private func layoutCollage(_ photoViews: [UIView]) {
        for (index, photoView) in photoViews.enumerated() {
            photoView.translatesAutoresizingMaskIntoConstraints = false

            switch index {
            case 0, 1:
                NSLayoutConstraint.activate([
                    photoView.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 4),
                    photoView.widthAnchor.constraint(equalTo: previewView.widthAnchor, multiplier: 0.47),
                    photoView.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.3)
                ])
                if index == 0 {
                    photoView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 4).isActive = true
                } else {
                    photoView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -4).isActive = true
                }

            case 2, 3:
                NSLayoutConstraint.activate([
                    photoView.centerYAnchor.constraint(equalTo: previewView.centerYAnchor),
                    photoView.widthAnchor.constraint(equalTo: previewView.widthAnchor, multiplier: 0.47),
                    photoView.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.3)
                ])
                if index == 2 {
                    photoView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 4).isActive = true
                } else {
                    photoView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -4).isActive = true
                }

            case 4, 5:
                NSLayoutConstraint.activate([
                    photoView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -4),
                    photoView.widthAnchor.constraint(equalTo: previewView.widthAnchor, multiplier: 0.47),
                    photoView.heightAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 0.3)
                ])
                if index == 4 {
                    photoView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 4).isActive = true
                } else {
                    photoView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -4).isActive = true
                }

            default:
                break
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewView.subviews.forEach { $0.removeFromSuperview() }
    }
}