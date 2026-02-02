//
//  MessageBubbleCell.swift
//  SnagIt
//
//  Created by Misha Causur on 02.02.2026.
//

import UIKit

final class MessageBubbleCell: UITableViewCell {

    static let reuseID = "MessageBubbleCell"

    private lazy var ui = createUI()
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var statusLeadingConstraint: NSLayoutConstraint?
    private var statusTrailingConstraint: NSLayoutConstraint?
    private var bubbleToBottomConstraint: NSLayoutConstraint?
    private var bubbleToStatusConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _ = ui
        layout()
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, isMine: Bool, statusText: String?) {
        ui.messageLabel.text = text

        if isMine {
            ui.bubble.backgroundColor = .systemBlue
            ui.messageLabel.textColor = .white

            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = true
        } else {
            ui.bubble.backgroundColor = .tertiarySystemFill
            ui.messageLabel.textColor = .label

            trailingConstraint?.isActive = false
            leadingConstraint?.isActive = true
        }

        let shouldShowStatus = isMine && (statusText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ui.statusLabel.isHidden = !shouldShowStatus
        ui.statusLabel.text = shouldShowStatus ? statusText : nil

        if shouldShowStatus {
            bubbleToBottomConstraint?.isActive = false
            bubbleToStatusConstraint?.isActive = true
            statusLeadingConstraint?.isActive = false
            statusTrailingConstraint?.isActive = true
        } else {
            bubbleToStatusConstraint?.isActive = false
            bubbleToBottomConstraint?.isActive = true
            statusTrailingConstraint?.isActive = false
            statusLeadingConstraint?.isActive = false
        }
    }
}

extension MessageBubbleCell {

    fileprivate struct UI {
        let bubble: UIView
        let messageLabel: UILabel
        let statusLabel: UILabel
    }

    func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    fileprivate func createUI() -> UI {

        let bubble = UIView().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 20
            $0.layer.masksToBounds = true
            contentView.addSubview($0)
        }

        let messageLabel = UILabel().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            $0.font = .preferredFont(forTextStyle: .body)
            bubble.addSubview($0)
        }

        let statusLabel = UILabel().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .preferredFont(forTextStyle: .caption2)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
            contentView.addSubview($0)
        }

        return UI(
            bubble: bubble,
            messageLabel: messageLabel,
            statusLabel: statusLabel
        )
    }

    fileprivate func layout() {
        leadingConstraint = ui.bubble.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 14
        )
        trailingConstraint = ui.bubble.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -14
        )

        statusLeadingConstraint = ui.statusLabel.leadingAnchor.constraint(
            equalTo: ui.bubble.leadingAnchor
        )
        statusTrailingConstraint = ui.statusLabel.trailingAnchor.constraint(
            equalTo: ui.bubble.trailingAnchor
        )

        bubbleToBottomConstraint = ui.bubble.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -6
        )
        bubbleToStatusConstraint = ui.bubble.bottomAnchor.constraint(
            equalTo: ui.statusLabel.topAnchor,
            constant: -4
        )

        NSLayoutConstraint.activate([
            ui.bubble.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 6
            ),
            ui.bubble.widthAnchor.constraint(
                lessThanOrEqualTo: contentView.widthAnchor,
                multiplier: 0.75
            ),

            ui.messageLabel.topAnchor.constraint(
                equalTo: ui.bubble.topAnchor,
                constant: 10
            ),
            ui.messageLabel.bottomAnchor.constraint(
                equalTo: ui.bubble.bottomAnchor,
                constant: -10
            ),
            ui.messageLabel.leadingAnchor.constraint(
                equalTo: ui.bubble.leadingAnchor,
                constant: 12
            ),
            ui.messageLabel.trailingAnchor.constraint(
                equalTo: ui.bubble.trailingAnchor,
                constant: -12
            ),
            ui.statusLabel.topAnchor.constraint(
                equalTo: ui.bubble.bottomAnchor,
                constant: 2
            ),
            ui.statusLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -6
            ),
        ])

        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = false
        bubbleToBottomConstraint?.isActive = true
        bubbleToStatusConstraint?.isActive = false
        ui.statusLabel.isHidden = true
    }
}
