//
//  HomeViewController.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import UIKit

final class ChatViewController: UIViewController {

    private var isObservingKeyboard = false

    private struct Message: Identifiable {
        let id = UUID()
        let text: String
        let isMine: Bool
        let date: Date
    }

    private lazy var ui = createUI()
    private var messages: [Message] = [
        Message(text: "lol lol lol 😆", isMine: false, date: Date()),
        Message(text: "XO XO XO", isMine: true, date: Date()),
    ]

    override var inputAccessoryView: UIView? { ui.inputBar }
    override var canBecomeFirstResponder: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        _ = ui
        layout()
        updateInsetsForKeyboard(overlapHeight: 0)
        scrollToBottom(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        startObservingKeyboardIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyboard()
    }

}

extension ChatViewController {
    fileprivate struct UI {
        let tableView: UITableView
        let inputBar: MessageInputBar
    }

    fileprivate func createUI() -> UI {

        let tableView = UITableView().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.separatorStyle = .none
            $0.keyboardDismissMode = .interactive
            $0.backgroundColor = .clear
            $0.dataSource = self
            $0.delegate = self
            $0.register(
                MessageBubbleCell.self,
                forCellReuseIdentifier: MessageBubbleCell.reuseID
            )
            view.addSubview($0)
        }

        let inputView = MessageInputBar()

        inputView.onSend = { [weak self] text in
            self?.appendMyMessage(text)
        }
        return UI(
            tableView: tableView,
            inputBar: inputView
        )
    }

    fileprivate func layout() {
        NSLayoutConstraint.activate([
            ui.tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            ui.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ui.tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            ui.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    fileprivate func appendMyMessage(_ text: String) {
        messages.append(Message(text: text, isMine: true, date: Date()))
        ui.tableView.reloadData()
        scrollToBottom(animated: true)
    }

    fileprivate func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.ui.tableView.layoutIfNeeded()
            let last = IndexPath(row: self.messages.count - 1, section: 0)
            self.ui.tableView.scrollToRow(
                at: last,
                at: .bottom,
                animated: animated
            )
        }
    }

    private func startObservingKeyboardIfNeeded() {
        guard !isObservingKeyboard else { return }
        isObservingKeyboard = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        updateInsetsForKeyboard(overlapHeight: 0)
    }

    private func stopObservingKeyboard() {
        guard isObservingKeyboard else { return }
        isObservingKeyboard = false
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleKeyboardWillChangeFrame(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let endFrameValue = userInfo[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue
        else { return }

        let endFrameScreen = endFrameValue.cgRectValue
        let endFrame = view.convert(endFrameScreen, from: nil)
        let overlap = max(0, view.bounds.maxY - endFrame.minY)
        updateInsetsForKeyboard(overlapHeight: overlap)
        scrollToBottom(animated: false)
    }

    @objc private func handleKeyboardWillHide(_ note: Notification) {
        updateInsetsForKeyboard(overlapHeight: 0)
    }

    private func updateInsetsForKeyboard(overlapHeight: CGFloat) {
        ui.tableView.contentInset.bottom = overlapHeight
        ui.tableView.verticalScrollIndicatorInsets = UIEdgeInsets(
            top: .zero,
            left: .zero,
            bottom: overlapHeight,
            right: .zero
        )
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        messages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let msg = messages[indexPath.row]
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: MessageBubbleCell.reuseID,
                for: indexPath
            ) as! MessageBubbleCell

        cell.configure(text: msg.text, isMine: msg.isMine)
        return cell
    }
}
