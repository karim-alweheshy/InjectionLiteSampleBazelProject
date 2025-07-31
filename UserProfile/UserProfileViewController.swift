//
//  UserProfileViewController.swift
//  UserProfile
//
//  Created by Karim Alweheshy on 31.07.25.
//

import UIKit
import Combine
import Inject

public class UserProfileViewController: UIViewController, ObservableObject {
    private var viewModel = UserProfileViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    private var tableView: UITableView!

    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "User Profile"
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Table view sections
    private enum Section: Int, CaseIterable {
        case profile
        case stats
        case preferences
        case actions
        
        var title: String {
            switch self {
            case .profile: return "Profile Information"
            case .stats: return "Usage Statistics"
            case .preferences: return "Preferences"
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
        title = "Profile"

        // Setup table view
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cells
        tableView.register(ProfileInfoCell.self, forCellReuseIdentifier: "ProfileInfoCell")
        tableView.register(StatsCell.self, forCellReuseIdentifier: "StatsCell")
        tableView.register(PreferenceCell.self, forCellReuseIdentifier: "PreferenceCell")
        tableView.register(ActionButtonCell.self, forCellReuseIdentifier: "ActionButtonCell")
        tableView.register(FavoriteFeatureCell.self, forCellReuseIdentifier: "FavoriteFeatureCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func editProfileTapped() {
        let editVC = EditProfileViewController()
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension UserProfileViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .profile:
            return 4 // Name, Email, Age, Join Date
        case .stats:
            return 3 // Sessions, Duration, Favorite Features
        case .preferences:
            return 3 // Notifications, Dark Mode, Language
        case .actions:
            return 1 // Edit Profile button
        }
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let profile = viewModel.userProfile
        
        switch sectionType {
        case .profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell", for: indexPath) as! ProfileInfoCell
            
            switch indexPath.row {
            case 0:
                cell.configure(title: "Name", value: profile.name, icon: "person.fill")
            case 1:
                cell.configure(title: "Email", value: profile.email, icon: "envelope.fill")
            case 2:
                cell.configure(title: "Age", value: "\(profile.age)", icon: "calendar")
            case 3:
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                cell.configure(title: "Member Since", value: formatter.string(from: profile.joinDate), icon: "clock.fill")
            default:
                break
            }
            
            return cell
            
        case .stats:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath) as! StatsCell
                cell.configure(title: "Total Sessions", value: "\(profile.stats.totalSessions)", icon: "chart.bar.fill", color: .systemBlue)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath) as! StatsCell
                let duration = Int(profile.stats.averageSessionDuration / 60)
                cell.configure(title: "Avg. Session Duration", value: "\(duration)m", icon: "timer", color: .systemGreen)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteFeatureCell", for: indexPath) as! FavoriteFeatureCell
                cell.configure(features: profile.stats.favoriteFeatures)
                return cell
            default:
                return UITableViewCell()
            }
            
        case .preferences:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceCell", for: indexPath) as! PreferenceCell
            
            switch indexPath.row {
            case 0:
                cell.configure(
                    title: "Notifications",
                    isOn: profile.preferences.notificationsEnabled,
                    icon: "bell.fill"
                ) { [weak self] isOn in
                    self?.viewModel.toggleNotifications()
                }
            case 1:
                cell.configure(
                    title: "Dark Mode",
                    isOn: profile.preferences.darkModeEnabled,
                    icon: "moon.fill"
                ) { [weak self] isOn in
                    self?.viewModel.toggleDarkMode()
                }
            case 2:
                cell.configure(
                    title: "Language",
                    value: profile.preferences.language,
                    icon: "globe"
                )
            default:
                break
            }
            
            return cell
            
        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionButtonCell", for: indexPath) as! ActionButtonCell
            cell.configure(title: "Edit Profile", color: .systemBlue) { [weak self] in
                self?.editProfileTapped()
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension UserProfileViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Section(rawValue: indexPath.section) else { return 44 }
        
        switch sectionType {
        case .stats where indexPath.row == 2: // Favorite features cell
            return 80
        case .actions:
            return 60
        default:
            return 50
        }
    }
}

// MARK: - Custom Cells

class ProfileInfoCell: UITableViewCell {
    private let iconImageView = UIImageView()
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
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.tintColor = .systemBlue
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(title: String, value: String, icon: String) {
        titleLabel.text = title
        valueLabel.text = value
        iconImageView.image = UIImage(systemName: icon)
    }
}

class StatsCell: UITableViewCell {
    private let iconImageView = UIImageView()
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
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(title: String, value: String, icon: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = color
    }
}

class PreferenceCell: UITableViewCell {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    private let valueLabel = UILabel()
    private var onToggle: ((Bool) -> Void)?
    
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
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.tintColor = .systemBlue
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(title: String, isOn: Bool, icon: String, onToggle: @escaping (Bool) -> Void) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        toggleSwitch.isOn = isOn
        toggleSwitch.isHidden = false
        valueLabel.isHidden = true
        self.onToggle = onToggle
    }
    
    func configure(title: String, value: String, icon: String) {
        titleLabel.text = title
        valueLabel.text = value
        iconImageView.image = UIImage(systemName: icon)
        toggleSwitch.isHidden = true
        valueLabel.isHidden = false
        self.onToggle = nil
    }
    
    @objc private func switchValueChanged() {
        onToggle?(toggleSwitch.isOn)
    }
}

class FavoriteFeatureCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "Favorite Features"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(features: [String]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for feature in features {
            let label = UILabel()
            label.text = feature
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .systemBlue
            label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let containerView = UIView()
            containerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
                label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
            ])
            
            stackView.addArrangedSubview(containerView)
        }
    }
}

class ActionButtonCell: UITableViewCell {
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(title: String, color: UIColor, onTap: @escaping () -> Void) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        self.onTap = onTap
    }
    
    @objc private func buttonTapped() {
        onTap?()
    }
}