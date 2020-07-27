//
//  ExperimentsController.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit

class ExperimentsController: UITableViewController {

  // MARK: - Private Properties

  private let cellId: String = "cell"
  private var experiments: [AppboosterExperiment] = State.experiments {
    didSet {
      State.experiments = experiments
      selectedIndexPaths = getSelectedIndexPaths()
    }
  }
  private var selectedIndexPaths: [IndexPath] = []

  // MARK: UITableViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    addCloseButton()
    title = "Experiments"

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    tableView.tableFooterView = UIView(frame: .zero)

    loadData()
  }

  // MARK: UITableViewDataSource

  override func tableView(_ tableView: UITableView,
                          titleForHeaderInSection section: Int) -> String? {
    return experiments[section].key
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return experiments.count
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return experiments[section].values.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    cell.textLabel?.text = "\(experiments[indexPath.section].values[indexPath.row])"
    cell.accessoryType = selectedIndexPaths.contains(indexPath) ? .checkmark : .none

    return cell
  }

  // MARK: UITableViewDelegate

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    let experiment = experiments[indexPath.section]
    if let index = State.debugTests.firstIndex(where: { test in test.key == experiment.key }) {
      State.debugTests.remove(at: index)
    }
    let test = AppboosterTest(key: experiment.key, value: experiment.values[indexPath.row])
    State.debugTests.append(test)

    tableView.deselectRow(at: indexPath, animated: true)
    tableView.reloadSections([indexPath.section], with: .automatic)
  }

  // MARK: Private Methods

  private func addCloseButton() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "Close",
      style: .plain,
      target: self,
      action: #selector(close)
    )
  }

  @objc
  private func close() {
    dismiss(animated: true)
  }

  private func loadData() {
    // TODO
  }

  private func getSelectedIndexPaths() -> [IndexPath] {
    var indexPaths: [IndexPath] = []

    var section: Int = 0
    var row: Int = 0

    for (index, experiment) in experiments.enumerated() {
      if let test = State.debugTests.first(where: { test in test.key == experiment.key }),
        let experimentRow = experiment.values.firstIndex(where: { value in value == test.value }) {
        section = index
        row = experimentRow
      } else if let test = State.tests.first(where: { test in test.key == experiment.key }),
        let experimentRow = experiment.values.firstIndex(where: { value in value == test.value }) {
        section = index
        row = experimentRow
      }
      indexPaths.append(IndexPath(row: row, section: section))
    }

    return indexPaths
  }
}
