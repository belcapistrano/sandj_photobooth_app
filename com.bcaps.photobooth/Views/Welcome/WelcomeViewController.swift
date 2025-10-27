import UIKit

class WelcomeViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAnimations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar for full-screen welcome experience
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show navigation bar when leaving welcome screen
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = .white

        setupScrollView()
        setupWelcomeContent()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupWelcomeContent() {
        // Couple names - main focal point
        let coupleNamesLabel = UILabel()
        coupleNamesLabel.text = "Shahnila & Josh"
        coupleNamesLabel.font = UIFont.systemFont(ofSize: 42, weight: .light)
        coupleNamesLabel.textColor = .black
        coupleNamesLabel.textAlignment = .center
        coupleNamesLabel.alpha = 0

        // Minimal subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Wedding"
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0

        // Single elegant heart
        let heartLabel = UILabel()
        heartLabel.text = "♥"
        heartLabel.font = UIFont.systemFont(ofSize: 24)
        heartLabel.textColor = .systemPink
        heartLabel.textAlignment = .center
        heartLabel.alpha = 0

        // Start button - clean and prominent
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .black
        startButton.layer.cornerRadius = 8
        startButton.addTarget(self, action: #selector(startPhotoBoothTapped), for: .touchUpInside)
        startButton.alpha = 0

        // Minimal settings button
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        settingsButton.setTitleColor(.systemGray, for: .normal)
        settingsButton.backgroundColor = .clear
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        settingsButton.alpha = 0

        // Add elements to content view
        [coupleNamesLabel, subtitleLabel, heartLabel, startButton, settingsButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Clean, centered layout
        NSLayoutConstraint.activate([
            // Couple names - centered and prominent
            coupleNamesLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coupleNamesLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -80),
            coupleNamesLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 40),
            coupleNamesLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40),

            // Heart - subtle decoration
            heartLabel.topAnchor.constraint(equalTo: coupleNamesLabel.bottomAnchor, constant: 12),
            heartLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: heartLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Start button - prominent and accessible
            startButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            startButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),

            // Settings - subtle and unobtrusive
            settingsButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 30),
            settingsButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            settingsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])

        // Store references for animations
        coupleNamesLabel.tag = 1
        heartLabel.tag = 2
        subtitleLabel.tag = 3
        startButton.tag = 4
        settingsButton.tag = 5
    }

    private func setupAnimations() {
        // Animate elements in sequence after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animateWelcomeElements()
        }
    }

    private func animateWelcomeElements() {
        let elements = (1...5).compactMap { contentView.viewWithTag($0) }

        for (index, element) in elements.enumerated() {
            let delay = Double(index) * 0.15

            UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [], animations: {
                element.alpha = 1

                // Subtle entrance animation for all elements
                element.transform = CGAffineTransform(translationX: 0, y: -20)
                element.transform = CGAffineTransform.identity
            })

            // Add gentle floating animation to the heart only
            if element.tag == 2 { // Heart
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.6) {
                    self.addFloatingAnimation(to: element)
                }
            }
        }
    }

    private func addFloatingAnimation(to view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = -4
        animation.duration = 3.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(animation, forKey: "floating")
    }

    @objc private func startPhotoBoothTapped() {
        // Subtle button press animation
        UIView.animate(withDuration: 0.1, animations: {
            if let button = self.contentView.viewWithTag(4) {
                button.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                if let button = self.contentView.viewWithTag(4) {
                    button.transform = CGAffineTransform.identity
                }
            }
        }

        // Navigate to camera view with auto-start enabled
        let cameraVC = CameraViewController(autoStartSession: true)
        navigationController?.pushViewController(cameraVC, animated: true)
    }

    @objc private func settingsButtonTapped() {
        let settingsVC = WeddingSettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
}