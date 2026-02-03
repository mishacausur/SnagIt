//
//  HomeViewController.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import UIKit

final class ChatViewController: UIViewController {

    private struct Message: Identifiable {
        enum Status {
            case sending
            case sent
            case failed

            var description: String {
                switch self {
                case .sending: return "Sending..."
                case .sent: return "Sent"
                case .failed: return "Failed"
                }
            }
        }
        let id = UUID()
        let text: String
        let isMine: Bool
        let date: Date
        var status: Status = .sent
    }

    private let chatService = ChatService()
    private var incomingTask: Task<Void, Never>?
    private var sendTasks: [UUID: Task<Void, Never>] = [:]
    private var isObservingKeyboard = false
    private lazy var ui = createUI()
    private var messages: [Message] = [
        Message(text: "lol lol lol 😆", isMine: false, date: Date()),
        Message(text: "XO XO XO", isMine: true, date: Date()),
        Message(text: "LOOOL", isMine: false, date: Date()),
    ]

    override var inputAccessoryView: UIView? { ui.inputBar }
    override var canBecomeFirstResponder: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Friend"
        _ = ui
        layout()
        updateInsetsForKeyboard(overlapHeight: 0)
        scrollToBottom(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        startObservingKeyboardIfNeeded()
        startIncomingIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyboard()
        incomingTask?.cancel()
        incomingTask = nil
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
        var msg = Message(text: text, isMine: true, date: Date())
        msg.status = .sending
        messages.append(msg)

        ui.tableView.reloadData()
        scrollToBottom(animated: true)

        startSend(for: msg.id)
    }

    private func startSend(for messageId: UUID) {
        sendTasks[messageId]?.cancel()
        sendTasks[messageId] = Task { [weak self] in
            guard let self else { return }

            guard
                let text = self.messages.first(where: { $0.id == messageId })?
                    .text
            else { return }

            do {
                try await self.chatService.send(text)
                await MainActor.run {
                    self.setStatus(.sent, for: messageId)
                }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.setStatus(.failed, for: messageId)
                }
            }
        }
    }

    private func setStatus(_ status: Message.Status, for messageId: UUID) {
        guard let idx = messages.firstIndex(where: { $0.id == messageId })
        else { return }
        messages[idx].status = status
        ui.tableView.reloadData()
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
    
    private func startIncomingIfNeeded() {
        guard incomingTask == nil else { return }

        incomingTask = Task { [weak self] in
            guard let self else { return }

            for await text in await self.chatService.incomingMessage() {
                if Task.isCancelled { break }

                await MainActor.run {
                    var msg = Message(text: text, isMine: false, date: Date())
                    msg.status = .sent
                    self.messages.append(msg)
                    self.ui.tableView.reloadData()
                    self.scrollToBottom(animated: true)
                }
            }
        }
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
        guard
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: MessageBubbleCell.reuseID,
                    for: indexPath
                ) as? MessageBubbleCell
        else {
            return UITableViewCell()
        }
        cell.configure(
            text: msg.text,
            isMine: msg.isMine,
            statusText: msg.isMine ? msg.status.description : nil
        )
        return cell
    }
}
