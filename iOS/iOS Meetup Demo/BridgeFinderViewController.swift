//
//  BridgeFinderViewController.swift
//  iOS Meetup Demo
//
//  Created by Mathieu White on 2017-04-11.
//  Copyright © 2017 Lixar I.T. All rights reserved.
//

import UIKit
import SwiftyHue

class BridgeFinderViewController: UIViewController {
    @IBOutlet fileprivate var bridgeResultsTableView: UITableView!
    @IBOutlet fileprivate var loadingView: UIView!
    @IBOutlet fileprivate var titleLabel: UILabel!

    fileprivate let presenter = BridgeFinderPresenter()
    fileprivate var bridges = [HueBridge]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSubviews()
        presenter.presentable = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = bridgeResultsTableView.indexPathForSelectedRow {
            bridgeResultsTableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

private extension BridgeFinderViewController {
    func configureSubviews() {
        configureNavigationBar()
        configureTableView()
        configureLoadingView()
    }

    func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }

    func configureTableView() {
        let nib = UINib(nibName: BridgeFinderTableViewCell.nibName, bundle: nil)
        bridgeResultsTableView.register(nib, forCellReuseIdentifier: BridgeFinderTableViewCell.reuseIdentifier)
        bridgeResultsTableView.rowHeight = UITableViewAutomaticDimension
        bridgeResultsTableView.estimatedRowHeight = BridgeFinderTableViewCell.estimatedHeight
        bridgeResultsTableView.tableFooterView = UIView()
    }

    func configureLoadingView() {
        showLoading(true)
    }

    func showLoading(_ loading: Bool) {
        loadingView.isHidden = !loading
    }
}

extension BridgeFinderViewController: BridgeFinderPresentable {
    func update(with state: BridgeFinderState) {
        switch state {
        case .success(let bridges):
            self.bridges = bridges
            titleLabel.text = NSLocalizedString("Select Your Bridge", comment: "")
            bridgeResultsTableView.reloadData()
            showLoading(false)
        case .empty:
            titleLabel.text = NSLocalizedString("No Results", comment: "")
            showLoading(false)
        case .loading:
            showLoading(true)
        }
    }
}

extension BridgeFinderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bridges.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bridge = bridges[indexPath.row]
        let identifier = BridgeFinderTableViewCell.reuseIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                       for:indexPath) as? BridgeFinderTableViewCell else {
                                                        fatalError()
        }

        cell.update(bridge)
        return cell
    }
}

extension BridgeFinderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bridge = bridges[indexPath.row]

        let presenter = BridgeAuthenticatorPresenter(bridge: bridge, authenticator: nil)
        let viewController = BridgeAuthenticatorViewController(presenter: presenter)

        navigationController?.pushViewController(viewController, animated: true)
    }
}
