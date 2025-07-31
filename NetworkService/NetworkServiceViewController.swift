//
//  NetworkServiceViewController.swift
//  NetworkService
//
//  Created by Karim Alweheshy on 31.07.25.
//

import UIKit
import Combine
import Inject

public class NetworkServiceViewController: UIViewController, ObservableObject {
    private let apiService = MockAPIService()
    
    private var tableView: UITableView!
    private var cancellables = Set<AnyCancellable>()

    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "Network Service"
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Table view sections
    private enum Section: Int, CaseIterable {
        case networkStatus
        case stats
        case users
        case requestHistory
        case actions
        
        var title: String {
            switch self {
            case .networkStatus: return "Network Status"
            case .stats: return "API Statistics"
            case .users: return "Users"
            case .requestHistory: return "Recent Requests"
            case .actions: return "Actions"
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Network Service"
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cells
        tableView.register(NetworkStatusCell.self, forCellReuseIdentifier: "NetworkStatusCell")
        tableView.register(NetworkStatCell.self, forCellReuseIdentifier: "NetworkStatCell")
        tableView.register(NetworkUserCell.self, forCellReuseIdentifier: "NetworkUserCell")
        tableView.register(RequestHistoryCell.self, forCellReuseIdentifier: "RequestHistoryCell")
        tableView.register(NetworkActionCell.self, forCellReuseIdentifier: "NetworkActionCell")
        tableView.register(EmptyStateCell.self, forCellReuseIdentifier: "EmptyStateCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        apiService.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func fetchUsers() {
        apiService.fetchUsers()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching users: \(error)")
                    }
                },
                receiveValue: { response in
                    print("Fetched \(response.data.count) users")
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateUserStatus(user: UserData, status: UserStatus) {
        apiService.updateUserStatus(userId: user.id, status: status)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error updating user: \(error)")
                    }
                },
                receiveValue: { response in
                    print("Updated user: \(response.data.name)")
                }
            )
            .store(in: &cancellables)
    }
    
    private func showAddUserAlert() {
        let alert = UIAlertController(title: "Add New User", message: "Enter user information", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Department"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let email = alert.textFields?[1].text, !email.isEmpty,
                  let department = alert.textFields?[2].text, !department.isEmpty else {
                return
            }
            
            self?.createUser(name: name, email: email, department: department)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func createUser(name: String, email: String, department: String) {
        apiService.createUser(name: name, email: email, department: department)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error creating user: \(error)")
                    }
                },
                receiveValue: { response in
                    print("Created user: \(response.data.name)")
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension NetworkServiceViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .networkStatus:
            return 1
        case .stats:
            return 4 // Total, Success Rate, Failed, Avg Response
        case .users:
            return max(apiService.users.count, 1) // At least 1 for empty state
        case .requestHistory:
            return max(min(apiService.requests.count, 5), 1) // Show max 5, at least 1 for empty state
        case .actions:
            return 3 // Fetch Users, Add User, Clear History
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .networkStatus:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkStatusCell", for: indexPath) as! NetworkStatusCell
            cell.configure(isOnline: apiService.isOnline) { [weak self] in
                self?.apiService.toggleNetworkStatus()
            }
            return cell
            
        case .stats:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkStatCell", for: indexPath) as! NetworkStatCell
            let stats = apiService.networkStats
            
            switch indexPath.row {
            case 0:
                cell.configure(title: "Total Requests", value: "\(stats.totalRequests)", color: .systemBlue)
            case 1:
                cell.configure(title: "Success Rate", value: String(format: "%.1f%%", stats.successRate), color: .systemGreen)
            case 2:
                cell.configure(title: "Failed Requests", value: "\(stats.failedRequests)", color: .systemRed)
            case 3:
                cell.configure(title: "Avg Response", value: String(format: "%.2fs", stats.averageResponseTime), color: .systemOrange)
            default:
                break
            }
            
            return cell
            
        case .users:
            if apiService.users.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyStateCell", for: indexPath) as! EmptyStateCell
                cell.configure(message: "No users available. Tap 'Fetch Users' to load data.")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkUserCell", for: indexPath) as! NetworkUserCell
                let user = apiService.users[indexPath.row]
                cell.configure(user: user) { [weak self] newStatus in
                    self?.updateUserStatus(user: user, status: newStatus)
                }
                return cell
            }
            
        case .requestHistory:
            if apiService.requests.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyStateCell", for: indexPath) as! EmptyStateCell
                cell.configure(message: "No requests yet")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RequestHistoryCell", for: indexPath) as! RequestHistoryCell
                let request = apiService.requests[indexPath.row]
                cell.configure(request: request)
                return cell
            }
            
        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkActionCell", for: indexPath) as! NetworkActionCell
            
            switch indexPath.row {
            case 0:
                cell.configure(title: "Fetch Users", color: .systemBlue, icon: "arrow.clockwise") { [weak self] in
                    self?.fetchUsers()
                }
            case 1:
                cell.configure(title: "Add New User", color: .systemGreen, icon: "person.badge.plus") { [weak self] in
                    self?.showAddUserAlert()
                }
            case 2:
                cell.configure(title: "Clear History", color: .systemRed, icon: "trash") { [weak self] in
                    self?.apiService.clearRequestHistory()
                }
            default:
                break
            }
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension NetworkServiceViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Section(rawValue: indexPath.section) else { return 44 }
        
        switch sectionType {
        case .networkStatus:
            return 60
        case .users:
            return apiService.users.isEmpty ? 80 : 70
        case .requestHistory:
            return apiService.requests.isEmpty ? 80 : 65
        case .actions:
            return 50
        default:
            return 44
        }
    }
}

// MARK: - Custom Cells

class NetworkStatusCell: UITableViewCell {
    private let statusLabel = UILabel()
    private let statusIndicator = UIView()
    private let toggleButton = UIButton(type: .system)
    private var onToggle: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusIndicator.layer.cornerRadius = 6
        
        toggleButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        toggleButton.layer.cornerRadius = 8
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        
        contentView.addSubview(statusLabel)
        contentView.addSubview(statusIndicator)
        contentView.addSubview(toggleButton)
        
        NSLayoutConstraint.activate([
            statusIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 12),
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            toggleButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(isOnline: Bool, onToggle: @escaping () -> Void) {
        statusLabel.text = isOnline ? "Online" : "Offline"
        statusLabel.textColor = isOnline ? .systemGreen : .systemRed
        statusIndicator.backgroundColor = isOnline ? .systemGreen : .systemRed
        
        toggleButton.setTitle(isOnline ? "Go Offline" : "Go Online", for: .normal)
        toggleButton.backgroundColor = (isOnline ? UIColor.systemRed : UIColor.systemGreen).withAlphaComponent(0.1)
        toggleButton.setTitleColor(isOnline ? .systemRed : .systemGreen, for: .normal)
        
        self.onToggle = onToggle
    }
    
    @objc private func toggleTapped() {
        onToggle?()
    }
}

class NetworkStatCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textAlignment = .right
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

class NetworkUserCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let departmentLabel = UILabel()
    private let statusButton = UIButton(type: .system)
    private var onStatusChange: ((UserStatus) -> Void)?
    private var currentUser: UserData?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        departmentLabel.translatesAutoresizingMaskIntoConstraints = false
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emailLabel.font = .systemFont(ofSize: 14)
        emailLabel.textColor = .secondaryLabel
        departmentLabel.font = .systemFont(ofSize: 14)
        departmentLabel.textColor = .secondaryLabel
        
        statusButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        statusButton.layer.cornerRadius = 6
        statusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(departmentLabel)
        contentView.addSubview(statusButton)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusButton.leadingAnchor, constant: -8),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusButton.leadingAnchor, constant: -8),
            
            departmentLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 2),
            departmentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            departmentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            departmentLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusButton.leadingAnchor, constant: -8),
            
            statusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            statusButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configure(user: UserData, onStatusChange: @escaping (UserStatus) -> Void) {
        nameLabel.text = user.name
        emailLabel.text = user.email
        departmentLabel.text = user.department
        
        statusButton.setTitle(user.status.displayName, for: .normal)
        let statusColor = colorForStatus(user.status)
        statusButton.backgroundColor = statusColor.withAlphaComponent(0.1)
        statusButton.setTitleColor(statusColor, for: .normal)
        
        self.currentUser = user
        self.onStatusChange = onStatusChange
    }
    
    private func colorForStatus(_ status: UserStatus) -> UIColor {
        switch status.color {
        case "green": return .systemGreen
        case "red": return .systemRed
        case "orange": return .systemOrange
        default: return .systemGray
        }
    }
    
    @objc private func statusButtonTapped() {
        guard let user = currentUser else { return }
        
        let alert = UIAlertController(title: "Change Status", message: "Select new status for \(user.name)", preferredStyle: .actionSheet)
        
        for status in UserStatus.allCases {
            let action = UIAlertAction(title: status.displayName, style: .default) { [weak self] _ in
                self?.onStatusChange?(status)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = statusButton
            popoverController.sourceRect = statusButton.bounds
        }
        
        if let viewController = self.findViewController() {
            viewController.present(alert, animated: true)
        }
    }
}

class RequestHistoryCell: UITableViewCell {
    private let methodLabel = UILabel()
    private let endpointLabel = UILabel()
    private let timeLabel = UILabel()
    private let statusIndicator = UIView()
    private let responseTimeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        endpointLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        responseTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        methodLabel.font = .systemFont(ofSize: 12, weight: .bold)
        methodLabel.textColor = .systemBlue
        methodLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        methodLabel.textAlignment = .center
        methodLabel.layer.cornerRadius = 4
        methodLabel.layer.masksToBounds = true
        
        endpointLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        responseTimeLabel.font = .systemFont(ofSize: 12)
        responseTimeLabel.textColor = .secondaryLabel
        responseTimeLabel.textAlignment = .right
        
        statusIndicator.layer.cornerRadius = 3
        
        contentView.addSubview(methodLabel)
        contentView.addSubview(endpointLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(statusIndicator)
        contentView.addSubview(responseTimeLabel)
        
        NSLayoutConstraint.activate([
            methodLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            methodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            methodLabel.widthAnchor.constraint(equalToConstant: 50),
            methodLabel.heightAnchor.constraint(equalToConstant: 20),
            
            endpointLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            endpointLabel.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 8),
            endpointLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusIndicator.leadingAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: endpointLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 8),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusIndicator.trailingAnchor.constraint(equalTo: responseTimeLabel.leadingAnchor, constant: -8),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 6),
            statusIndicator.heightAnchor.constraint(equalToConstant: 6),
            
            responseTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            responseTimeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            responseTimeLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(request: APIRequest) {
        methodLabel.text = request.method.rawValue
        endpointLabel.text = request.endpoint
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: request.timestamp)
        
        let statusColor = colorForStatus(request.status)
        statusIndicator.backgroundColor = statusColor
        
        if let responseTime = request.responseTime {
            responseTimeLabel.text = String(format: "%.2fs", responseTime)
        } else {
            responseTimeLabel.text = "-"
        }
    }
    
    private func colorForStatus(_ status: RequestStatus) -> UIColor {
        switch status.color {
        case "green": return .systemGreen
        case "red": return .systemRed
        case "orange": return .systemOrange
        default: return .systemGray
        }
    }
}

class NetworkActionCell: UITableViewCell {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let button = UIButton(type: .system)
    private var onTap: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(title: String, color: UIColor, icon: String, onTap: @escaping () -> Void) {
        titleLabel.text = title
        titleLabel.textColor = color
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = color
        self.onTap = onTap
    }
    
    @objc private func buttonTapped() {
        onTap?()
    }
}

class EmptyStateCell: UITableViewCell {
    private let messageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        contentView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(message: String) {
        messageLabel.text = message
    }
}

// MARK: - Helper Extensions

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}