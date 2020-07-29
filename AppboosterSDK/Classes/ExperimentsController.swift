//
//  ExperimentsController.swift
//  AppboosterSDK
//
//  Created by Appbooster on 22/07/2020.
//  Copyright © 2020 Appbooster. All rights reserved.
//

import UIKit

private let controllerTitle: String = "A/B-tests"
private let tableTitle: String = "In debug mode, you can:\n1. See all available experiments for this app build\n2. View all options as users see them.\n\nAVAILABLE EXPERIMENTS"
private let reloadTitle: String = "For the changes to take effect, you must restart the app."
private let resetTitle: String = "The debug values of the experiments will be cleared and the settings received from the server will be returned."
private let currentOption: String = "Current option"
private let backgroundColor: UIColor = UIColor(red: 237/255, green: 237/255, blue: 241/255, alpha: 1)
private let blue: UIColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
private let black20: UIColor = UIColor.black.withAlphaComponent(0.2)
private let black40: UIColor = UIColor.black.withAlphaComponent(0.4)

class ExperimentCell: UITableViewCell {

  private var checkImageView: UIImageView!
  private var stackView: UIStackView!
  private var currentLabel: UILabel!
  private var descriptionLabel: UILabel!
  private var keyLabel: UILabel!

  func configure(
    with option: AppboosterExperimentOption,
    isCurrent: Bool,
    isSelected: Bool
  ) {
    descriptionLabel.text = option.description
    keyLabel.text = "\(option.value)"
    currentLabel.isHidden = !isCurrent
    let imageName = isSelected ? "checkbox-fill" : "checkbox"
    checkImageView.image = UIImage(named: imageName)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    checkImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
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
    currentLabel.text = currentOption
    currentLabel.textColor = blue
    currentLabel.font = .systemFont(ofSize: 13)
    stackView.addArrangedSubview(currentLabel)

    descriptionLabel = UILabel()
    descriptionLabel.textColor = .black
    descriptionLabel.font = .systemFont(ofSize: 17)
    descriptionLabel.numberOfLines = 0
    stackView.addArrangedSubview(descriptionLabel)

    keyLabel = UILabel()
    keyLabel.textColor = black40
    keyLabel.font = .systemFont(ofSize: 13)
    stackView.addArrangedSubview(keyLabel)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class ExperimentsController: UITableViewController {

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
      let isCurrent = State.tests.first(where: {
        $0.key == experiments[indexPath.section].key &&
          $0.value == option.value
      }) != nil
      let isSelected = State.debugTests.first(where: {
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
    if let index = State.debugTests.firstIndex(where: { test in test.key == experiment.key }) {
      State.debugTests.remove(at: index)
    }
    let test = AppboosterTest(key: experiment.key, value: experiment.options[indexPath.row].value)
    State.debugTests.append(test)

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
    let resetButton = UIBarButtonItem(
      title: "Reset",
      style: .plain,
      target: self,
      action: #selector(reset)
    )
    let reloadButton = UIBarButtonItem(
      title: "Reload",
      style: .done,
      target: self,
      action: #selector(reload)
    )
    navigationItem.rightBarButtonItems = [reloadButton, resetButton]
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
      State.debugTests.removeAll()
    }
    alertController.addAction(cancel)
    alertController.addAction(action)
    present(alertController, animated: true)
  }

  @objc
  private func reload() {
    let alertController = UIAlertController(title: reloadTitle, message: nil, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(action)
    present(alertController, animated: true)
  }

  private func configureNavigationBar() {
    addNavigationBarButtons()
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
