import UIKit
import AppCore

public protocol FeatureFlagsService {
    func isEnabled(_ key: String) -> Bool
}

public final class InMemoryFeatureFlagsService: FeatureFlagsService {
    private let flags: [String: Bool]
    public init(flags: [String: Bool]) { self.flags = flags }
    public func isEnabled(_ key: String) -> Bool { flags[key] ?? false }
}

public final class SettingsViewController: UITableViewController {
    private let featureFlags: FeatureFlagsService

    public init(featureFlags: FeatureFlagsService = ServiceLocator.shared.resolve()) {
        self.featureFlags = featureFlags
        super.init(style: .insetGrouped)
        title = "Settings"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func numberOfSections(in tableView: UITableView) -> Int { 2 }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        if indexPath.section == 0 {
            cell.textLabel?.text = "Dark Mode"
            cell.detailTextLabel?.text = featureFlags.isEnabled("dark_mode") ? "On" : "Off"
        } else {
            cell.textLabel?.text = "Experimental Charts"
            cell.detailTextLabel?.text = featureFlags.isEnabled("exp_charts") ? "On" : "Off"
        }
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let vc = SettingDetailViewController(title: "Dark Mode", description: "This is a demo detail screen for Dark Mode setting.")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = SettingDetailViewController(title: "Experimental Charts", description: "This flag toggles experimental chart rendering in Analytics.")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


