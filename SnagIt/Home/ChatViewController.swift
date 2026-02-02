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
        Message(text: "XO XO XO", isMine: true, date: Date())
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
}

private extension ChatViewController {
     struct UI {
        let tableView: UITableView
        let inputBar: UIView
    }

     func createUI() -> UI {

        let tableView = UITableView().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.separatorStyle = .none
            $0.keyboardDismissMode = .interactive
            $0.backgroundColor = .clear
            $0.dataSource = self
            $0.delegate = self
            $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            view.addSubview($0)
        }

        let inputView = MessageInputBar().configure {
            $0.backgroundColor = .secondarySystemBackground
            $0.frame.size.height = 54
            view.addSubview($0)
        }

        return UI(
            tableView: tableView,
            inputBar: inputView
        )
    }

    func layout() {
        NSLayoutConstraint.activate([
            ui.tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            ui.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ui.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ui.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
