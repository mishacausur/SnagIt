//
//  HomeViewController.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import UIKit

final class ChatViewController: UIViewController {

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
        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
}

extension ChatViewController {
    fileprivate struct UI {
        let tableView: UITableView
        let inputBar: UIView
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

        let inputView = MessageInputBar().configure {
            $0.backgroundColor = .secondarySystemBackground
            $0.frame.size.height = 54
            view.addSubview($0)
        }

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
        DispatchQueue.main.async {
            let last = IndexPath(row: self.messages.count - 1, section: 0)
            self.ui.tableView.scrollToRow(
                at: last,
                at: .bottom,
                animated: animated
            )
        }
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
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell.reuseID,
            for: indexPath
        ) as! MessageBubbleCell

        cell.configure(text: msg.text, isMine: msg.isMine)
        return cell
    }
}
