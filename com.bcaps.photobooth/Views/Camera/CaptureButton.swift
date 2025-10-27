import UIKit

class CaptureButton: UIButton {

    private let outerRing = CAShapeLayer()
    private let innerCircle = CAShapeLayer()
    private let actionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }

    private func setupButton() {
        backgroundColor = .clear

        layer.addSublayer(outerRing)
        layer.addSublayer(innerCircle)

        outerRing.fillColor = UIColor.clear.cgColor
        outerRing.strokeColor = UIColor.white.cgColor
        outerRing.lineWidth = 4

        innerCircle.fillColor = UIColor.white.cgColor
        innerCircle.strokeColor = UIColor.clear.cgColor

        setupActionLabel()
    }

    private func setupActionLabel() {
        actionLabel.text = "START"
        actionLabel.textAlignment = .center
        actionLabel.font = UIFont.boldSystemFont(ofSize: 12)
        actionLabel.textColor = .black
        actionLabel.isHidden = false

        addSubview(actionLabel)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) / 2 - 2
        let innerRadius = outerRadius * 0.7

        let outerPath = UIBezierPath(arcCenter: center, radius: outerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        outerRing.path = outerPath.cgPath

        let innerPath = UIBezierPath(arcCenter: center, radius: innerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        innerCircle.path = innerPath.cgPath
    }

    func animateCapture() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.8
        scaleAnimation.duration = 0.1
        scaleAnimation.autoreverses = true

        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.fromValue = UIColor.white.cgColor
        colorAnimation.toValue = UIColor.systemBlue.cgColor
        colorAnimation.duration = 0.1
        colorAnimation.autoreverses = true

        innerCircle.add(scaleAnimation, forKey: "captureScale")
        innerCircle.add(colorAnimation, forKey: "captureColor")
    }

    func setSessionMode(_ isSession: Bool) {
        if isSession {
            innerCircle.fillColor = UIColor.systemRed.cgColor
            outerRing.strokeColor = UIColor.systemRed.cgColor
            actionLabel.text = "STOP"
            actionLabel.textColor = .white
            actionLabel.isHidden = false
        } else {
            innerCircle.fillColor = UIColor.white.cgColor
            outerRing.strokeColor = UIColor.white.cgColor
            actionLabel.text = "START"
            actionLabel.textColor = .black
            actionLabel.isHidden = false
        }
    }
}