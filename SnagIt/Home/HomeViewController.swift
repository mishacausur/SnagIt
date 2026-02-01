//
//  HomeViewController.swift
//  SnagIt
//
//  Created by Misha Causur on 29.01.2026.
//

import UIKit

final class HomeViewController: UIViewController {

    private lazy var ui = createUI()

    override var inputAccessoryView: UIView? { ui.inputBar }
    override var canBecomeFirstResponder: Bool { true }

    override func viewDidLoad() {
        view.backgroundColor = .red
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
}

extension HomeViewController {
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
            view.addSubview($0)
        }
        let inputView = UIView().configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        return UI(
            tableView: tableView,
            inputBar: inputView
        )
    }

    func layout() {

    }
}
