import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    private let cameraManager = CameraManager.shared
    private let sessionManager = SessionManager.shared

    private var shouldAutoStartSession: Bool = false

    init(autoStartSession: Bool = false) {
        self.shouldAutoStartSession = autoStartSession
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureButton: UIButton!
    private var controlBar: ControlBar!
    private var filterSelectionView: FilterSelectionView!

    private var currentSession: PhotoSession?
    private var capturedPhotos: [Photo] = []
    private var currentFilter: FilterType = .original

    // PhotoBooth session properties
    private var isPhotoBoothSession = false
    private var photoBoothTimer: Timer?
    private var currentPhotoIndex = 0
    private let photosPerSession = 3
    private let countdownDuration = 3
    private var countdownLabel: UILabel!
    private var sessionProgressView: UIView!
    private var cameraFrameOverlay: UIView!
    private var smileyOverlay: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
        startNewSession()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupUI() {
        view.backgroundColor = .black
        updateTitle()

        setupCaptureButton()
        setupFilterSelection()
        setupControlBar()
        setupNavigationBar()
        setupCountdownLabel()
        setupSessionProgressView()
        setupCameraFrameOverlay()
        setupSmileyOverlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraManager.startSession()
        updateTitle() // Update title when returning from settings
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Auto-start PhotoBooth session if flag is set
        if shouldAutoStartSession && !isPhotoBoothSession {
            shouldAutoStartSession = false // Only auto-start once
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.startPhotoBoothSession()
            }
        }
    }

    private func updateTitle() {
        if PhotoStripComposer.shared.isWeddingTheme {
            title = ""
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.systemPink
            ]
        } else {
            title = ""
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.label
            ]
        }
        updateFrameOverlay()
    }

    private func updateFrameOverlay() {
        guard let cameraFrameOverlay = cameraFrameOverlay else { return }

        // Find and update the frame title
        for subview in cameraFrameOverlay.subviews {
            for headerSubview in subview.subviews {
                if let titleLabel = headerSubview as? UILabel {
                    titleLabel.text = ""
                    titleLabel.textColor = PhotoStripComposer.shared.isWeddingTheme ? .systemPink : .white
                    break
                }
            }
        }
    }

    private func setupCaptureButton() {
        captureButton = UIButton(type: .system)
        captureButton.setTitle("START", for: .normal)
        captureButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.layer.cornerRadius = 12
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)

        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupFilterSelection() {
        filterSelectionView = FilterSelectionView()
        filterSelectionView.delegate = self

        view.addSubview(filterSelectionView)
        filterSelectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            filterSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterSelectionView.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20),
            filterSelectionView.heightAnchor.constraint(equalToConstant: 92)
        ])
    }

    private func setupControlBar() {
        controlBar = ControlBar()
        controlBar.delegate = self

        view.addSubview(controlBar)
        controlBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlBar.topAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: 20),
            controlBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Review",
            style: .plain,
            target: self,
            action: #selector(reviewButtonTapped)
        )

        let sessionsButton = UIBarButtonItem(
            title: "Sessions",
            style: .plain,
            target: self,
            action: #selector(sessionsButtonTapped)
        )

        let settingsButton = UIBarButtonItem(
            title: "Settings",
            style: .plain,
            target: self,
            action: #selector(weddingSettingsButtonTapped)
        )
        settingsButton.tintColor = .systemPink

        navigationItem.leftBarButtonItems = [sessionsButton, settingsButton]
    }

    private func setupCountdownLabel() {
        countdownLabel = UILabel()
        countdownLabel.textAlignment = .center
        countdownLabel.font = UIFont.boldSystemFont(ofSize: 120)
        countdownLabel.textColor = .white
        countdownLabel.isHidden = true
        countdownLabel.layer.shadowColor = UIColor.black.cgColor
        countdownLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        countdownLabel.layer.shadowOpacity = 0.8
        countdownLabel.layer.shadowRadius = 4

        view.addSubview(countdownLabel)
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countdownLabel.widthAnchor.constraint(equalToConstant: 200),
            countdownLabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupSessionProgressView() {
        sessionProgressView = UIView()
        sessionProgressView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        sessionProgressView.layer.cornerRadius = 12
        sessionProgressView.isHidden = true

        view.addSubview(sessionProgressView)
        sessionProgressView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sessionProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sessionProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sessionProgressView.widthAnchor.constraint(equalToConstant: 200),
            sessionProgressView.heightAnchor.constraint(equalToConstant: 60)
        ])

        let progressLabel = UILabel()
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.boldSystemFont(ofSize: 18)
        progressLabel.textColor = .white
        progressLabel.tag = 100

        sessionProgressView.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: sessionProgressView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: sessionProgressView.centerYAnchor)
        ])
    }

    private func setupCameraFrameOverlay() {
        cameraFrameOverlay = UIView()
        cameraFrameOverlay.backgroundColor = .clear
        cameraFrameOverlay.isUserInteractionEnabled = false

        view.addSubview(cameraFrameOverlay)
        cameraFrameOverlay.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cameraFrameOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            cameraFrameOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraFrameOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraFrameOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add blackout header section
        let headerBlackout = UIView()
        headerBlackout.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        cameraFrameOverlay.addSubview(headerBlackout)
        headerBlackout.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerBlackout.topAnchor.constraint(equalTo: cameraFrameOverlay.topAnchor),
            headerBlackout.leadingAnchor.constraint(equalTo: cameraFrameOverlay.leadingAnchor),
            headerBlackout.trailingAnchor.constraint(equalTo: cameraFrameOverlay.trailingAnchor),
            headerBlackout.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Add blackout footer section
        let footerBlackout = UIView()
        footerBlackout.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        cameraFrameOverlay.addSubview(footerBlackout)
        footerBlackout.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            footerBlackout.bottomAnchor.constraint(equalTo: cameraFrameOverlay.bottomAnchor),
            footerBlackout.leadingAnchor.constraint(equalTo: cameraFrameOverlay.leadingAnchor),
            footerBlackout.trailingAnchor.constraint(equalTo: cameraFrameOverlay.trailingAnchor),
            footerBlackout.heightAnchor.constraint(equalToConstant: 200)
        ])

        // Add decorative photo frame border
        let frameView = UIView()
        frameView.backgroundColor = .clear
        frameView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        frameView.layer.borderWidth = 4
        frameView.layer.cornerRadius = 12
        cameraFrameOverlay.addSubview(frameView)
        frameView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            frameView.topAnchor.constraint(equalTo: headerBlackout.bottomAnchor, constant: 20),
            frameView.leadingAnchor.constraint(equalTo: cameraFrameOverlay.leadingAnchor, constant: 20),
            frameView.trailingAnchor.constraint(equalTo: cameraFrameOverlay.trailingAnchor, constant: -20),
            frameView.bottomAnchor.constraint(equalTo: footerBlackout.topAnchor, constant: -20)
        ])

        // Add corner decorations
        addCornerDecorations(to: frameView)

        // Add frame title
        let frameTitle = UILabel()
        frameTitle.text = ""
        frameTitle.font = UIFont.boldSystemFont(ofSize: 16)
        frameTitle.textColor = .white
        frameTitle.textAlignment = .center
        frameTitle.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        frameTitle.layer.cornerRadius = 8
        frameTitle.clipsToBounds = true

        headerBlackout.addSubview(frameTitle)
        frameTitle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            frameTitle.centerXAnchor.constraint(equalTo: headerBlackout.centerXAnchor),
            frameTitle.centerYAnchor.constraint(equalTo: headerBlackout.centerYAnchor),
            frameTitle.widthAnchor.constraint(equalToConstant: 250),
            frameTitle.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func addCornerDecorations(to frameView: UIView) {
        let cornerSize: CGFloat = 20
        let cornerThickness: CGFloat = 4

        // Top-left corner
        let topLeft = UIView()
        topLeft.backgroundColor = .white
        frameView.addSubview(topLeft)
        topLeft.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topLeft.topAnchor.constraint(equalTo: frameView.topAnchor, constant: -cornerThickness),
            topLeft.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: -cornerThickness),
            topLeft.widthAnchor.constraint(equalToConstant: cornerSize),
            topLeft.heightAnchor.constraint(equalToConstant: cornerSize)
        ])

        // Top-right corner
        let topRight = UIView()
        topRight.backgroundColor = .white
        frameView.addSubview(topRight)
        topRight.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topRight.topAnchor.constraint(equalTo: frameView.topAnchor, constant: -cornerThickness),
            topRight.trailingAnchor.constraint(equalTo: frameView.trailingAnchor, constant: cornerThickness),
            topRight.widthAnchor.constraint(equalToConstant: cornerSize),
            topRight.heightAnchor.constraint(equalToConstant: cornerSize)
        ])

        // Bottom-left corner
        let bottomLeft = UIView()
        bottomLeft.backgroundColor = .white
        frameView.addSubview(bottomLeft)
        bottomLeft.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomLeft.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: cornerThickness),
            bottomLeft.leadingAnchor.constraint(equalTo: frameView.leadingAnchor, constant: -cornerThickness),
            bottomLeft.widthAnchor.constraint(equalToConstant: cornerSize),
            bottomLeft.heightAnchor.constraint(equalToConstant: cornerSize)
        ])

        // Bottom-right corner
        let bottomRight = UIView()
        bottomRight.backgroundColor = .white
        frameView.addSubview(bottomRight)
        bottomRight.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomRight.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: cornerThickness),
            bottomRight.trailingAnchor.constraint(equalTo: frameView.trailingAnchor, constant: cornerThickness),
            bottomRight.widthAnchor.constraint(equalToConstant: cornerSize),
            bottomRight.heightAnchor.constraint(equalToConstant: cornerSize)
        ])
    }

    private func setupSmileyOverlay() {
        smileyOverlay = UIView()
        smileyOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        smileyOverlay.layer.cornerRadius = 20
        smileyOverlay.isHidden = true
        smileyOverlay.isUserInteractionEnabled = false

        view.addSubview(smileyOverlay)
        smileyOverlay.translatesAutoresizingMaskIntoConstraints = false

        // Create smiley face emoji label
        let smileyLabel = UILabel()
        smileyLabel.text = "😊"
        smileyLabel.font = UIFont.systemFont(ofSize: 80)
        smileyLabel.textAlignment = .center

        // Create instruction text
        let instructionLabel = UILabel()
        instructionLabel.text = "Get Ready to SMILE!"
        instructionLabel.font = UIFont.boldSystemFont(ofSize: 24)
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center

        // Create wedding-specific text if in wedding mode
        let weddingLabel = UILabel()
        weddingLabel.text = "Say Cheese!"
        weddingLabel.font = UIFont(name: "Georgia-Italic", size: 18) ?? UIFont.italicSystemFont(ofSize: 18)
        weddingLabel.textColor = .systemPink
        weddingLabel.textAlignment = .center

        smileyOverlay.addSubview(smileyLabel)
        smileyOverlay.addSubview(instructionLabel)
        smileyOverlay.addSubview(weddingLabel)

        smileyLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        weddingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            smileyOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            smileyOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            smileyOverlay.widthAnchor.constraint(equalToConstant: 300),
            smileyOverlay.heightAnchor.constraint(equalToConstant: 200),

            smileyLabel.topAnchor.constraint(equalTo: smileyOverlay.topAnchor, constant: 20),
            smileyLabel.centerXAnchor.constraint(equalTo: smileyOverlay.centerXAnchor),

            instructionLabel.topAnchor.constraint(equalTo: smileyLabel.bottomAnchor, constant: 10),
            instructionLabel.leadingAnchor.constraint(equalTo: smileyOverlay.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: smileyOverlay.trailingAnchor, constant: -16),

            weddingLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 8),
            weddingLabel.leadingAnchor.constraint(equalTo: smileyOverlay.leadingAnchor, constant: 16),
            weddingLabel.trailingAnchor.constraint(equalTo: smileyOverlay.trailingAnchor, constant: -16),
            weddingLabel.bottomAnchor.constraint(lessThanOrEqualTo: smileyOverlay.bottomAnchor, constant: -16)
        ])

        // Tag the labels for easy access
        smileyLabel.tag = 101
        instructionLabel.tag = 102
        weddingLabel.tag = 103
    }

    private func setupCamera() {
        cameraManager.setupCamera { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let previewLayer):
                    self?.setupPreviewLayer(previewLayer)
                case .failure(let error):
                    self?.showCameraError(error)
                }
            }
        }
    }

    private func setupPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
    }

    private func showCameraError(_ error: Error) {
        let alert = UIAlertController(
            title: "Camera Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func startNewSession() {
        currentSession = PhotoSession(selectedFilter: currentFilter, isWeddingTheme: PhotoStripComposer.shared.isWeddingTheme)
        capturedPhotos.removeAll()
        updateUI()
    }

    private func updateUI() {
        let photoCount = capturedPhotos.count
        title = photoCount > 0 ? "Photo \(photoCount + 1)" : "Photo Booth"

        navigationItem.rightBarButtonItem?.isEnabled = photoCount > 0
    }

    @objc private func captureButtonTapped() {
        if isPhotoBoothSession {
            stopPhotoBoothSession()
        } else {
            startPhotoBoothSession()
        }
    }

    private func handleCapturedPhoto(_ image: UIImage) {
        let photo = Photo()

        do {
            _ = try PhotoStorage.shared.savePhoto(image, id: photo.id)
            capturedPhotos.append(photo)

            if var session = currentSession {
                session = PhotoSession(
                    id: session.id,
                    photos: capturedPhotos,
                    timestamp: session.timestamp,
                    isComplete: false
                )
                currentSession = session
                try SessionStorage.shared.saveSession(session)
            }

            updateUI()
            showPhotoPreview(image)

        } catch {
            showCameraError(error)
        }
    }

    private func showPhotoPreview(_ image: UIImage) {
        // Create a container view for the preview with background
        let previewContainer = UIView()
        previewContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        previewContainer.layer.cornerRadius = 16
        previewContainer.alpha = 0

        // Create the image view
        let preview = UIImageView(image: image)
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        preview.layer.cornerRadius = 12
        preview.layer.borderWidth = 3
        preview.layer.borderColor = UIColor.white.cgColor

        // Add shadow for depth
        previewContainer.layer.shadowColor = UIColor.black.cgColor
        previewContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        previewContainer.layer.shadowRadius = 12
        previewContainer.layer.shadowOpacity = 0.5

        view.addSubview(previewContainer)
        previewContainer.addSubview(preview)

        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        preview.translatesAutoresizingMaskIntoConstraints = false

        // Make preview container fit most of the screen
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        let containerWidth = screenWidth * 0.85  // 85% of screen width
        let containerHeight = screenHeight * 0.7 // 70% of screen height

        NSLayoutConstraint.activate([
            previewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            previewContainer.widthAnchor.constraint(equalToConstant: containerWidth),
            previewContainer.heightAnchor.constraint(equalToConstant: containerHeight),

            preview.topAnchor.constraint(equalTo: previewContainer.topAnchor, constant: 16),
            preview.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 16),
            preview.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -16),
            preview.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -50)
        ])

        // Add photo count label
        let photoCountLabel = UILabel()
        photoCountLabel.text = "Photo \(capturedPhotos.count)"
        photoCountLabel.font = UIFont.boldSystemFont(ofSize: 22)
        photoCountLabel.textColor = .white
        photoCountLabel.textAlignment = .center

        previewContainer.addSubview(photoCountLabel)
        photoCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            photoCountLabel.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: -16),
            photoCountLabel.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor, constant: 16),
            photoCountLabel.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -16),
            photoCountLabel.heightAnchor.constraint(equalToConstant: 30)
        ])

        // Animate the preview appearance with a scale effect
        previewContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            previewContainer.alpha = 1
            previewContainer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { _ in
            // Hold the preview for 2 seconds, then fade out
            UIView.animate(withDuration: 0.4, delay: 2.0, options: [], animations: {
                previewContainer.alpha = 0
                previewContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                previewContainer.removeFromSuperview()
            }
        }
    }

    @objc private func reviewButtonTapped() {
        guard !capturedPhotos.isEmpty else { return }

        let reviewVC = ReviewViewController()
        reviewVC.photos = capturedPhotos
        reviewVC.delegate = self
        navigationController?.pushViewController(reviewVC, animated: true)
    }


    @objc private func sessionsButtonTapped() {
        let sessionsVC = SessionsViewController()
        let navController = UINavigationController(rootViewController: sessionsVC)
        present(navController, animated: true)
    }

    @objc private func weddingSettingsButtonTapped() {
        let settingsVC = WeddingSettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }

    // MARK: - PhotoBooth Session Methods

    private func startPhotoBoothSession() {
        guard !isPhotoBoothSession else { return }

        isPhotoBoothSession = true
        currentPhotoIndex = 0
        capturedPhotos.removeAll()
        currentSession = sessionManager.createPhotoBoothSession()

        updateCaptureButtonForSession()
        showSessionProgress()
        startCountdown()
    }

    private func stopPhotoBoothSession() {
        isPhotoBoothSession = false
        photoBoothTimer?.invalidate()
        photoBoothTimer = nil

        hideCountdown()
        hideSessionProgress()
        updateCaptureButtonForSession()
    }

    private func startCountdown() {
        var countdown = countdownDuration
        showCountdown(countdown)

        photoBoothTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            countdown -= 1

            if countdown > 0 {
                self?.showCountdown(countdown)
            } else {
                timer.invalidate()
                self?.capturePhotoInSession()
            }
        }
    }

    private func capturePhotoInSession() {
        hideCountdown()

        cameraManager.capturePhoto { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.handleSessionPhoto(image)
                case .failure(let error):
                    self?.showCameraError(error)
                    self?.stopPhotoBoothSession()
                }
            }
        }
    }

    private func handleSessionPhoto(_ image: UIImage) {
        guard var session = currentSession else {
            stopPhotoBoothSession()
            return
        }

        // Apply selected filter to the captured photo
        let processedImage = applyCurrentFilter(to: image)

        do {
            session = try sessionManager.addPhotoToPhotoBoothSession(processedImage, session: session)
            currentSession = session
            capturedPhotos = session.photos
            currentPhotoIndex += 1

            updateSessionProgress()
            showPhotoPreview(processedImage)

            if currentPhotoIndex < photosPerSession {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.startCountdown()
                }
            } else {
                finishPhotoBoothSession()
            }
        } catch {
            showCameraError(error)
            stopPhotoBoothSession()
        }
    }

    private func applyCurrentFilter(to image: UIImage) -> UIImage {
        guard currentFilter != .original else { return image }
        return FilterManager.shared.applyFilter(currentFilter, to: image) ?? image
    }

    private func finishPhotoBoothSession() {
        guard let session = currentSession else {
            stopPhotoBoothSession()
            return
        }

        do {
            let completedSession = try sessionManager.completePhotoBoothSession(session)
            currentSession = completedSession
        } catch {
            showCameraError(error)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.stopPhotoBoothSession()
            self?.updateUI()
            self?.autoNavigateToReview()
        }
    }

    private func autoNavigateToReview() {
        // Automatically navigate to review page after session completion
        guard !capturedPhotos.isEmpty else { return }

        let reviewVC = ReviewViewController()
        reviewVC.photos = capturedPhotos
        reviewVC.delegate = self
        navigationController?.pushViewController(reviewVC, animated: true)
    }

    // MARK: - UI Updates for PhotoBooth Session

    private func updateCaptureButtonForSession() {
        if isPhotoBoothSession {
            captureButton.setTitle("STOP", for: .normal)
            captureButton.backgroundColor = .systemRed
        } else {
            captureButton.setTitle("START", for: .normal)
            captureButton.backgroundColor = .systemBlue
        }
    }

    private func showCountdown(_ count: Int) {
        countdownLabel.text = "\(count)"
        countdownLabel.isHidden = false

        // Show smiley overlay when countdown reaches 1 (right before photo)
        if count == 1 {
            showSmileyPrompt()
        } else {
            hideSmileyPrompt()
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.countdownLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.countdownLabel.transform = .identity
            }
        }
    }

    private func hideCountdown() {
        countdownLabel.isHidden = true
        hideSmileyPrompt()
    }

    private func showSmileyPrompt() {
        // Update text based on wedding theme
        if let weddingLabel = smileyOverlay.viewWithTag(103) as? UILabel {
            weddingLabel.isHidden = !PhotoStripComposer.shared.isWeddingTheme
        }

        smileyOverlay.isHidden = false
        smileyOverlay.alpha = 0
        smileyOverlay.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
            self.smileyOverlay.alpha = 1
            self.smileyOverlay.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    private func hideSmileyPrompt() {
        UIView.animate(withDuration: 0.2, animations: {
            self.smileyOverlay.alpha = 0
            self.smileyOverlay.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.smileyOverlay.isHidden = true
        }
    }

    private func showSessionProgress() {
        sessionProgressView.isHidden = false
        updateSessionProgress()
    }

    private func updateSessionProgress() {
        if let progressLabel = sessionProgressView.viewWithTag(100) as? UILabel {
            progressLabel.text = "Photo \(currentPhotoIndex + 1) of \(photosPerSession)"
        }
    }

    private func hideSessionProgress() {
        sessionProgressView.isHidden = true
    }
}

extension CameraViewController: ControlBarDelegate {
    func controlBarDidToggleFlash() {
        cameraManager.toggleFlash()
    }

    func controlBarDidToggleCamera() {
        cameraManager.switchCamera()
    }

}

extension CameraViewController: FilterSelectionDelegate {
    func filterSelectionDidChange(_ filter: FilterType) {
        currentFilter = filter
        // TODO: Apply real-time filter to camera preview in Phase 3
        print("Filter selected: \(filter.displayName)")
    }
}

extension CameraViewController: ReviewViewControllerDelegate {
    func reviewViewControllerDidFinishSession(_ viewController: ReviewViewController) {
        if var session = currentSession {
            session = PhotoSession(
                id: session.id,
                photos: capturedPhotos,
                timestamp: session.timestamp,
                isComplete: true
            )

            do {
                try SessionStorage.shared.saveSession(session)
                startNewSession()
                navigationController?.popViewController(animated: true)
            } catch {
                showCameraError(error)
            }
        }
    }

    func reviewViewControllerDidRetakePhotos(_ viewController: ReviewViewController) {
        navigationController?.popViewController(animated: true)
    }
}

