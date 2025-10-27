import UIKit

class WeddingSettingsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let coupleNamesTextField = UITextField()
    private let weddingDatePicker = UIDatePicker()
    private let hashtagTextField = UITextField()
    private let weddingThemeSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentSettings()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Wedding Settings"

        setupScrollView()
        setupNavigationBar()
        setupFormElements()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveSettings)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelSettings)
        )
    }

    private func setupFormElements() {
        // Wedding Theme Toggle
        let themeContainer = createFormRow(
            title: "Wedding Theme",
            subtitle: "Enable special wedding-themed photo strips",
            control: weddingThemeSwitch
        )
        stackView.addArrangedSubview(themeContainer)

        // Couple Names
        let coupleNamesContainer = createTextFieldRow(
            title: "Couple Names",
            placeholder: "e.g., Shahnila & Josh",
            textField: coupleNamesTextField
        )
        stackView.addArrangedSubview(coupleNamesContainer)

        // Wedding Date
        let dateContainer = createDatePickerRow(
            title: "Wedding Date",
            datePicker: weddingDatePicker
        )
        stackView.addArrangedSubview(dateContainer)

        // Hashtag
        let hashtagContainer = createTextFieldRow(
            title: "Wedding Hashtag",
            placeholder: "e.g., #ShahnilaAndJoshWedding",
            textField: hashtagTextField
        )
        stackView.addArrangedSubview(hashtagContainer)

        // Preview Section
        let previewContainer = createPreviewSection()
        stackView.addArrangedSubview(previewContainer)
    }

    private func createFormRow(title: String, subtitle: String, control: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(control)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        control.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: control.leadingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: control.leadingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),

            control.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            control.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])

        return container
    }

    private func createTextFieldRow(title: String, placeholder: String, textField: UITextField) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label

        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)

        container.addSubview(titleLabel)
        container.addSubview(textField)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),

            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])

        return container
    }

    private func createDatePickerRow(title: String, datePicker: UIDatePicker) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.maximumDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year from now

        container.addSubview(titleLabel)
        container.addSubview(datePicker)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: datePicker.leadingAnchor, constant: -16),

            datePicker.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            datePicker.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -16),

            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])

        return container
    }

    private func createPreviewSection() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = "Preview"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label

        let previewLabel = UILabel()
        previewLabel.text = "Your photo strips will include:\n• Couple names at the top\n• Wedding date\n• Custom hashtag\n• Elegant pink theme with hearts\n• Thank you message"
        previewLabel.font = UIFont.systemFont(ofSize: 14)
        previewLabel.textColor = .secondaryLabel
        previewLabel.numberOfLines = 0

        let heartLabel = UILabel()
        heartLabel.text = "♥ ♥ ♥"
        heartLabel.font = UIFont.systemFont(ofSize: 24)
        heartLabel.textColor = .systemPink
        heartLabel.textAlignment = .center

        container.addSubview(titleLabel)
        container.addSubview(previewLabel)
        container.addSubview(heartLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        heartLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            previewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            previewLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            previewLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            heartLabel.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 12),
            heartLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            heartLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            heartLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        return container
    }

    private func loadCurrentSettings() {
        let composer = PhotoStripComposer.shared

        weddingThemeSwitch.isOn = composer.isWeddingTheme
        coupleNamesTextField.text = composer.coupleNames
        hashtagTextField.text = composer.eventHashtag

        // Parse the wedding date string back to Date
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        if let date = formatter.date(from: composer.weddingDate) {
            weddingDatePicker.date = date
        }
    }

    @objc private func saveSettings() {
        let composer = PhotoStripComposer.shared

        composer.isWeddingTheme = weddingThemeSwitch.isOn
        composer.coupleNames = coupleNamesTextField.text ?? "Shahnila & Josh"
        composer.eventHashtag = hashtagTextField.text ?? "#ShahnilaAndJoshWedding"

        // Format the selected date
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        composer.weddingDate = formatter.string(from: weddingDatePicker.date)

        // Show confirmation
        let alert = UIAlertController(
            title: "Settings Saved",
            message: "Your wedding theme settings have been updated!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func cancelSettings() {
        dismiss(animated: true)
    }
}