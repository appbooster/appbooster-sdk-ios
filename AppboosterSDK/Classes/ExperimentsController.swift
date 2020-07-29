//
//  ExperimentsController.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit

class ExperimentCell: UITableViewCell {

  private var checkImageView: UIImageView!
  private var stackView: UIStackView!
  private var currentLabel: UILabel!
  private var descriptionLabel: UILabel!
  private var keyLabel: UILabel!

  func configure(_ option: AppboosterExperimentOption) {
    descriptionLabel.text = option.description
    keyLabel.text = "\(option.value)"
//    currentLabel.isHidden = true
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    checkImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    checkImageView.image = UIImage(named: "checkbox")
    contentView.addSubview(checkImageView)
    checkImageView.translatesAutoresizingMaskIntoConstraints = false
    checkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
    checkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    checkImageView.setContentHuggingPriority(UILayoutPriority(rawValue: 255), for: .horizontal)

    stackView = UIStackView()
    stackView.spacing = 2
    stackView.axis = .vertical
    contentView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.leadingAnchor.constraint(equalTo: checkImageView.trailingAnchor, constant: 20).isActive = true
    stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
    stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true

    currentLabel = UILabel()
    currentLabel.text = "Current option"
    currentLabel.textColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    currentLabel.font = .systemFont(ofSize: 13)
    stackView.addArrangedSubview(currentLabel)

    descriptionLabel = UILabel()
    descriptionLabel.textColor = .black
    descriptionLabel.font = .systemFont(ofSize: 17)
    stackView.addArrangedSubview(descriptionLabel)

    keyLabel = UILabel()
    keyLabel.textColor = UIColor.black.withAlphaComponent(0.4)
    keyLabel.font = .systemFont(ofSize: 13)
    stackView.addArrangedSubview(keyLabel)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class ExperimentsController: UITableViewController {

  // MARK: - Constants

  private let controllerTitle: String = "A/B-tests"
  private let tableTitle: String = "In debug mode, you can:\n1. See all available experiments for this app build\n2. View all options as users see them.\n\nAVAILABLE EXPERIMENTS"
  private let backgroundColor: UIColor = UIColor(red: 237/255, green: 237/255, blue: 241/255, alpha: 1)
  private let black20: UIColor = UIColor.black.withAlphaComponent(0.2)
  private let black40: UIColor = UIColor.black.withAlphaComponent(0.4)

  // MARK: - Private Properties

  private var experiments: [AppboosterExperiment] = State.experiments {
    didSet {
      State.experiments = experiments
      selectedIndexPaths = getSelectedIndexPaths()
    }
  }
  private var selectedIndexPaths: [IndexPath] = []
  private var arrows: [UIImageView] = []

  var hiddenSections: Set<Int> = []

  // MARK: UITableViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    addCloseButton()
    configureNavigationBar()
    configureTableView()
    configureTableViewHeaderView()

    for index in 0 ..< experiments.count {
      hiddenSections.insert(index)
    }
  }

  // MARK: UITableViewDataSource

  override func numberOfSections(in tableView: UITableView) -> Int {
    return experiments.count
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if hiddenSections.contains(section) {
        return 0
    }

    return experiments[section].options.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "\(ExperimentCell.self)", for: indexPath)

    let option = experiments[indexPath.section].options[indexPath.row]
    if let experimentCell = cell as? ExperimentCell {
      experimentCell.configure(option)
    }

    return cell
  }

  // MARK: UITableViewDelegate

  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    return 66
  }

  override func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
    return getHeaderView(for: section)
  }

  override func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
    let experiment = experiments[indexPath.section]
    if let index = State.debugTests.firstIndex(where: { test in test.key == experiment.key }) {
      State.debugTests.remove(at: index)
    }
    let test = AppboosterTest(key: experiment.key, value: experiment.options[indexPath.row].value)
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

  private func configureNavigationBar() {
    title = controllerTitle
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.backgroundColor = .white
    navigationController?.navigationBar.isTranslucent = false
  }

  private func configureTableView() {
    tableView.register(ExperimentCell.self, forCellReuseIdentifier: "\(ExperimentCell.self)")
    tableView.tableFooterView = UIView(frame: .zero)
    tableView.backgroundColor = backgroundColor
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 0)
  }

  private func configureTableViewHeaderView() {
    let headerView = UIView()
    headerView.frame = CGRect(x: 0, y: 0, width: 200, height: 88)
    headerView.backgroundColor = backgroundColor

    let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.5))
    topBorder.backgroundColor = black20
    headerView.addSubview(topBorder)

    let headerTitleLabel = UILabel()
    headerTitleLabel.text = tableTitle
    headerTitleLabel.textColor = black40
    headerTitleLabel.font = .systemFont(ofSize: 13)
    headerTitleLabel.numberOfLines = 0
    headerView.addSubview(headerTitleLabel)
    headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    headerTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
    headerTitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
    headerTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
    headerTitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true

    tableView.tableHeaderView = headerView
  }

  private func getHeaderView(for section: Int) -> UIView {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 66))
    headerView.backgroundColor = .white

    let nameLabel = UILabel()
    nameLabel.text = experiments[section].name
    nameLabel.textColor = .black
    nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    headerView.addSubview(nameLabel)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
    nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12).isActive = true

    let keyLabel = UILabel()
    keyLabel.text = experiments[section].key
    keyLabel.textColor = black40
    keyLabel.font = .systemFont(ofSize: 13)
    headerView.addSubview(keyLabel)
    keyLabel.translatesAutoresizingMaskIntoConstraints = false
    keyLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
    keyLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -14).isActive = true

    let arrowImageView = UIImageView(image: UIImage(named: "arrow"))
    headerView.addSubview(arrowImageView)
    arrowImageView.translatesAutoresizingMaskIntoConstraints = false
    arrowImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
    arrowImageView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
    arrowImageView.tag = section
    arrows.append(arrowImageView)

    let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.5))
    topBorder.backgroundColor = black20
    headerView.addSubview(topBorder)

    let bottomBorder = UIView(frame: CGRect(x: 0, y: 66, width: tableView.frame.width, height: 0.5))
    bottomBorder.backgroundColor = black20
    headerView.addSubview(bottomBorder)

    let sectionButton = UIButton()
    sectionButton.tag = section
    sectionButton.addTarget(
      self,
      action: #selector(hideSection(_:)),
      for: .touchUpInside
    )
    headerView.addSubview(sectionButton)
    sectionButton.frame = headerView.frame

    return headerView
  }

  @objc
  private func hideSection(_ sender: UIButton) {
    let section = sender.tag

    func indexPathsForSection() -> [IndexPath] {
      var indexPaths = [IndexPath]()

      for row in 0 ..< experiments[section].options.count {
        indexPaths.append(IndexPath(row: row, section: section))
      }

      return indexPaths
    }

    let rotatedValue: CGFloat

    if hiddenSections.contains(section) {
      rotatedValue = .pi / 2
      hiddenSections.remove(section)
      tableView.insertRows(at: indexPathsForSection(), with: .fade)
    } else {
      rotatedValue = -(.pi / 2)
      hiddenSections.insert(section)
      tableView.deleteRows(at: indexPathsForSection(), with: .fade)
    }
    if let arrowImageView = arrows.first(where: { $0.tag == section }) {
      UIView.animate(withDuration: 0.3) {
        arrowImageView.transform = arrowImageView.transform.rotated(by: rotatedValue)
      }
    }
  }

  private func getSelectedIndexPaths() -> [IndexPath] {
    var indexPaths: [IndexPath] = []

    var section: Int = 0
    var row: Int = 0

    for (index, experiment) in experiments.enumerated() {
      if let test = State.debugTests.first(where: { test in test.key == experiment.key }),
        let experimentRow = experiment.options.firstIndex(where: { option in option.value == test.value }) {
        section = index
        row = experimentRow
      } else if let test = State.tests.first(where: { test in test.key == experiment.key }),
        let experimentRow = experiment.options.firstIndex(where: { option in option.value == test.value }) {
        section = index
        row = experimentRow
      }
      indexPaths.append(IndexPath(row: row, section: section))
    }

    return indexPaths
  }
}
