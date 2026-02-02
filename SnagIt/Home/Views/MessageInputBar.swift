//
//  MessageInputBar.swift
//  SnagIt
//
//  Created by Misha Causur on 02.02.2026.
//

import UIKit

final class MessageInputBar: UIView {
    private lazy var ui = createUI()
    private var textViewHeightConstraint: NSLayoutConstraint?
    private var cachedHeight: CGFloat = 56

    var onSend: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleHeight]
        cachedHeight = 56
        self.frame.size.height = cachedHeight

        _ = ui
        layout()
        updateSendButtonState()
        updateHeight()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(cachedHeight, 56))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeight()
    }

    @objc private func sendTapped() {
        let raw = ui.textView.text ?? ""
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        onSend?(text)
        ui.textView.text = ""
        ui.placeholderLabel.isHidden = false
        updateSendButtonState()
        updateHeight()
    }
}

extension MessageInputBar: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        ui.placeholderLabel.isHidden = !(ui.textView.text ?? "").isEmpty
        updateSendButtonState()
        updateHeight()
    }
}

private extension MessageInputBar {
    struct UI {
        let background: UIVisualEffectView
        let container: UIView
        let textView: UITextView
        let placeholderLabel: UILabel
        let sendButton: UIButton
    }

    func createUI() -> UI {

        let background = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemChromeMaterial)
        ).configure {  //.systemThickMaterial)).configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        let container = UIView().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 18
            $0.layer.masksToBounds = true
            background.contentView.addSubview($0)
        }

        let textView = UITextView().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.font = .preferredFont(forTextStyle: .body)
            $0.isScrollEnabled = false
            $0.textContainerInset = UIEdgeInsets(
                top: 10,
                left: 10,
                bottom: 10,
                right: 10
            )
            $0.delegate = self
            container.addSubview($0)
        }

        let placeholderLabel = UILabel().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "Message"
            $0.textColor = .secondaryLabel
            $0.font = .preferredFont(forTextStyle: .body)
            container.addSubview($0)
        }

        let sendButton = UIButton().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setImage(
                UIImage(systemName: "arrow.up.circle.fill"),
                for: .normal
            )

            $0.addTarget(
                self,
                action: #selector(sendTapped),
                for: .touchUpInside
            )
            container.addSubview($0)
        }

        return UI(
            background: background,
            container: container,
            textView: textView,
            placeholderLabel: placeholderLabel,
            sendButton: sendButton
        )
    }

    func layout() {
        NSLayoutConstraint.activate([
            ui.background.topAnchor.constraint(equalTo: topAnchor),
            ui.background.leadingAnchor.constraint(equalTo: leadingAnchor),
            ui.background.trailingAnchor.constraint(equalTo: trailingAnchor),
            ui.background.bottomAnchor.constraint(equalTo: bottomAnchor),
            ui.container.topAnchor.constraint(
                equalTo: ui.background.contentView.topAnchor,
                constant: 8
            ),
            ui.container.leadingAnchor.constraint(
                equalTo: ui.background.contentView.leadingAnchor,
                constant: 12
            ),
            ui.container.trailingAnchor.constraint(
                equalTo: ui.background.contentView.trailingAnchor,
                constant: -12
            ),
            ui.container.bottomAnchor.constraint(
                equalTo: ui.background.contentView.safeAreaLayoutGuide
                    .bottomAnchor,
                constant: -8
            ),
            ui.sendButton.trailingAnchor.constraint(
                equalTo: ui.container.trailingAnchor,
                constant: -10
            ),
            ui.sendButton.bottomAnchor.constraint(
                equalTo: ui.container.bottomAnchor,
                constant: -8
            ),
            ui.sendButton.widthAnchor.constraint(equalToConstant: 32),
            ui.sendButton.heightAnchor.constraint(equalToConstant: 32),

            ui.textView.topAnchor.constraint(equalTo: ui.container.topAnchor),
            ui.textView.leadingAnchor.constraint(
                equalTo: ui.container.leadingAnchor
            ),
            ui.textView.trailingAnchor.constraint(
                equalTo: ui.sendButton.leadingAnchor,
                constant: -6
            ),
            ui.textView.bottomAnchor.constraint(
                equalTo: ui.container.bottomAnchor
            ),

            ui.placeholderLabel.leadingAnchor.constraint(
                equalTo: ui.textView.leadingAnchor,
                constant: 14
            ),
            ui.placeholderLabel.topAnchor.constraint(
                equalTo: ui.textView.topAnchor,
                constant: 10
            ),
            ui.placeholderLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: ui.textView.trailingAnchor
            ),
        ])

        textViewHeightConstraint = ui.textView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 40
        )
        textViewHeightConstraint?.isActive = true
    }

    func updateHeight() {
        guard ui.textView.bounds.width > 0 else { return }
        
        let targetSize = CGSize(
            width: ui.textView.bounds.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        let fitting = ui.textView.sizeThatFits(targetSize)

        let minH: CGFloat = 40
        let maxH: CGFloat = 140
        let clamped = min(max(fitting.height, minH), maxH)

        ui.textView.isScrollEnabled = fitting.height > maxH
        textViewHeightConstraint?.constant = clamped
        cachedHeight = clamped + 16 + safeAreaInsets.bottom
        invalidateIntrinsicContentSize()
    }

    func updateSendButtonState() {
        let text = (ui.textView.text ?? "").trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        ui.sendButton.isEnabled = !text.isEmpty
        ui.sendButton.alpha = ui.sendButton.isEnabled ? 1.0 : 0.35
    }
}
