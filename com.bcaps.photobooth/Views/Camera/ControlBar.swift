import UIKit

protocol ControlBarDelegate: AnyObject {
    func controlBarDidToggleFlash()
    func controlBarDidToggleCamera()
}

class ControlBar: UIView {

    weak var delegate: ControlBarDelegate?

    private let stackView = UIStackView()
    private let flashButton = UIButton(type: .system)
    private let cameraToggleButton = UIButton(type: .system)

    private var isFlashOn = false

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
        layer.cornerRadius = 8

        setupStackView()
        setupButtons()
        updateButtonStates()
    }

    private func setupStackView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
    }

    private func setupButtons() {
        [flashButton, cameraToggleButton].forEach { button in
            button.tintColor = .white
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            stackView.addArrangedSubview(button)
        }

        flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        cameraToggleButton.addTarget(self, action: #selector(cameraToggleButtonTapped), for: .touchUpInside)
    }

    private func updateButtonStates() {
        let flashImage = isFlashOn ? "bolt.fill" : "bolt.slash"
        flashButton.setImage(UIImage(systemName: flashImage), for: .normal)
        flashButton.setTitle("Flash", for: .normal)
        flashButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        flashButton.setTitleColor(.white, for: .normal)
        configureButton(flashButton, title: "Flash")

        cameraToggleButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        configureButton(cameraToggleButton, title: "Flip")
    }

    private func configureButton(_ button: UIButton, title: String) {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.title = title
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 10)
                outgoing.foregroundColor = UIColor.white
                return outgoing
            }
            config.imagePlacement = .top
            config.imagePadding = 5
            button.configuration = config
        } else {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            button.setTitleColor(.white, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 25, left: -20, bottom: -25, right: 20)
            button.imageEdgeInsets = UIEdgeInsets(top: -15, left: 0, bottom: 15, right: 0)
        }
    }

    @objc private func flashButtonTapped() {
        isFlashOn.toggle()
        updateButtonStates()
        delegate?.controlBarDidToggleFlash()

        animateButtonPress(flashButton)
    }

    @objc private func cameraToggleButtonTapped() {
        delegate?.controlBarDidToggleCamera()
        animateButtonPress(cameraToggleButton)
    }


    private func animateButtonPress(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
}