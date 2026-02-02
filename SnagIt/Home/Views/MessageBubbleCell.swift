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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _ = ui
        layout()
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, isMine: Bool) {
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
    }
}

extension MessageBubbleCell {
    fileprivate struct UI {
        let bubble: UIView
        let messageLabel: UILabel
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

        return UI(
            bubble: bubble,
            messageLabel: messageLabel
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

        NSLayoutConstraint.activate([
            ui.bubble.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 6
            ),
            ui.bubble.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -6
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
        ])

        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = false
    }
}
