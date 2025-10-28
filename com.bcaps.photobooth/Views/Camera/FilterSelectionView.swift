import UIKit

protocol FilterSelectionDelegate: AnyObject {
    func filterSelectionDidChange(_ filter: FilterType)
}

class FilterSelectionView: UIView {

    weak var delegate: FilterSelectionDelegate?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var filterButtons: [FilterButton] = []
    private var selectedFilter: FilterType = .original

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.cornerRadius = 12

        setupScrollView()
        setupFilterButtons()
    }

    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 16

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }

    private func setupFilterButtons() {
        let filters = FilterType.allCases

        for filter in filters {
            let button = createFilterButton(for: filter)
            filterButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        // Select the first filter (original) by default
        updateSelection(.original)
    }

    private func createFilterButton(for filter: FilterType) -> FilterButton {
        let button = FilterButton(filter: filter)
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 80)
        ])

        return button
    }

    @objc private func filterButtonTapped(_ sender: FilterButton) {
        let filter = sender.filter
        updateSelection(filter)
        delegate?.filterSelectionDidChange(filter)
    }

    private func updateSelection(_ filter: FilterType) {
        selectedFilter = filter

        for button in filterButtons {
            button.updateSelection(button.filter == filter)
        }
    }

    func setSelectedFilter(_ filter: FilterType) {
        updateSelection(filter)
    }
}

// MARK: - FilterButton

class FilterButton: UIButton {

    let filter: FilterType
    private let thumbnailImageView = UIImageView()
    private let labelView = UILabel()
    private let selectionIndicator = UIView()

    init(filter: FilterType) {
        self.filter = filter
        super.init(frame: .zero)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        layer.cornerRadius = 8
        clipsToBounds = true

        setupThumbnail()
        setupLabel()
        setupSelectionIndicator()
        layoutComponents()
    }

    private func setupThumbnail() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 4
        thumbnailImageView.backgroundColor = UIColor.systemGray5

        // Generate thumbnail asynchronously
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let thumbnail = FilterManager.shared.createFilterThumbnail(self.filter)

            DispatchQueue.main.async {
                self.thumbnailImageView.image = thumbnail
            }
        }

        addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLabel() {
        labelView.text = filter.displayName
        labelView.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        labelView.textColor = .white
        labelView.textAlignment = .center

        addSubview(labelView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupSelectionIndicator() {
        selectionIndicator.backgroundColor = UIColor.systemBlue
        selectionIndicator.layer.cornerRadius = 2
        selectionIndicator.alpha = 0

        addSubview(selectionIndicator)
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
    }

    private func layoutComponents() {
        NSLayoutConstraint.activate([
            // Thumbnail
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 44),

            // Label
            labelView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 4),
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            labelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            labelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            // Selection indicator
            selectionIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectionIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectionIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    func updateSelection(_ isSelected: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.selectionIndicator.alpha = isSelected ? 1.0 : 0.0
            self.backgroundColor = isSelected
                ? UIColor.white.withAlphaComponent(0.3)
                : UIColor.white.withAlphaComponent(0.1)
            self.transform = isSelected
                ? CGAffineTransform(scaleX: 1.05, y: 1.05)
                : CGAffineTransform.identity
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = self.isSelected
                ? CGAffineTransform(scaleX: 1.05, y: 1.05)
                : CGAffineTransform.identity
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = self.isSelected
                ? CGAffineTransform(scaleX: 1.05, y: 1.05)
                : CGAffineTransform.identity
        }
    }
}