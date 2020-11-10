//
//  ExperimentsController.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit

class ExperimentsController: UITableViewController {

  // MARK: - Constants

  private let controllerTitle: String = "A/B-tests"
  private let tableTitle: String = "In debug mode, you can:\n1. See all available experiments for this app build\n2. View all options as users see them.\n\nAVAILABLE EXPERIMENTS"
  private let resetTitle: String = "The debug values of the experiments will be cleared and the settings received from the server will be returned."

  private let backgroundColor: UIColor = UIColor(red: 237/255, green: 237/255, blue: 241/255, alpha: 1)
  private let black20: UIColor = UIColor.black.withAlphaComponent(0.2)
  private let black40: UIColor = UIColor.black.withAlphaComponent(0.4)

  // MARK: - Private Properties

  private var experiments: [AppboosterExperiment] = State.experiments {
    didSet {
      State.experiments = experiments
    }
  }
  private var arrows: [UIImageView] = []
  private var hiddenSections: Set<Int> = []
  private var experimentsObserver: NSObjectProtocol?

  // MARK: UITableViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    configureNavigationBar()
    configureTableView()
    configureTableViewHeaderView()

    for index in 0 ..< experiments.count {
      hiddenSections.insert(index)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    experimentsObserver = NotificationCenter.default.addObserver(
      forName: Notification.Name("AllExperimentsReceived"),
      object: nil,
      queue: .main) { [weak self] notification in
        guard let self = self else { return }

        self.tableView.reloadData()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if let experimentsObserver = experimentsObserver {
      NotificationCenter.default.removeObserver(experimentsObserver)
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
      let isCurrent = State.experimentsValues.first(where: {
        $0.key == experiments[indexPath.section].key &&
          $0.value == option.value
      }) != nil
      let isSelected = State.debugExperimentsValues.first(where: {
        $0.key == experiments[indexPath.section].key &&
          $0.value == option.value
      }) != nil
      experimentCell.configure(
        with: option,
        isCurrent: isCurrent,
        isSelected: isSelected
      )
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
    if let index = State.debugExperimentsValues.firstIndex(where: { experimentValue in experimentValue.key == experiment.key }) {
      State.debugExperimentsValues.remove(at: index)
    }
    let experimentValue = AppboosterExperimentValue(key: experiment.key, value: experiment.options[indexPath.row].value, optionId: nil)
    State.debugExperimentsValues.append(experimentValue)

    tableView.deselectRow(at: indexPath, animated: true)
    tableView.reloadSections([indexPath.section], with: .automatic)
  }

  // MARK: Private Methods

  private func addNavigationBarButtons() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "Close",
      style: .plain,
      target: self,
      action: #selector(close)
    )
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Reset",
      style: .plain,
      target: self,
      action: #selector(reset)
    )
  }

  @objc
  private func close() {
    dismiss(animated: true)
  }

  @objc
  private func reset() {
    let alertController = UIAlertController(title: resetTitle, message: nil, preferredStyle: .actionSheet)
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let action = UIAlertAction(title: "Reset", style: .default) { _ in
      State.debugExperimentsValues.removeAll()
      self.tableView.reloadData()
    }
    alertController.addAction(cancel)
    alertController.addAction(action)
    present(alertController, animated: true)
  }

  private func configureNavigationBar() {
    addNavigationBarButtons()
    title = controllerTitle
    if #available(iOS 11.0, *) {
      navigationController?.navigationBar.prefersLargeTitles = true
    }
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

    var arrowImage: UIImage?

    let bundle = Bundle(for: AppboosterSDK.self)
    if let bundleURL = bundle.resourceURL?.appendingPathComponent("AppboosterSDK.bundle") {
      let resourceBundle = Bundle(url: bundleURL)
      arrowImage = UIImage(named: "arrow", in: resourceBundle, compatibleWith: nil)
    }

    let arrowImageView = UIImageView(image: arrowImage)
    headerView.addSubview(arrowImageView)
    arrowImageView.translatesAutoresizingMaskIntoConstraints = false
    arrowImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
    arrowImageView.widthAnchor.constraint(equalToConstant: 8).isActive = true

    arrowImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
    arrowImageView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
    arrowImageView.tag = section
    arrows.append(arrowImageView)
    rotate(imageView: arrowImageView, isRotated: hiddenSections.contains(section))

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

    let isRotated: Bool

    if hiddenSections.contains(section) {
      isRotated = false
      hiddenSections.remove(section)
      tableView.insertRows(at: indexPathsForSection(), with: .fade)
    } else {
      isRotated = true
      hiddenSections.insert(section)
      tableView.deleteRows(at: indexPathsForSection(), with: .fade)
    }
    arrows.forEach { arrow in
      if arrow.tag == section {
        rotate(imageView: arrow, isRotated: isRotated)
      }
    }
  }

  private func rotate(imageView: UIImageView, isRotated: Bool) {
    UIView.animate(withDuration: 0.3) {
      imageView.transform = isRotated
        ? .identity
        : CGAffineTransform(rotationAngle: .pi / 2)
    }
  }
}
