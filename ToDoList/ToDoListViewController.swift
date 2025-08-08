import UIKit
import AppCore

public final class ToDoListViewController: UITableViewController {
    private let repository: ToDoRepository
    private var items: [ToDoItem] = []

    public init(repository: ToDoRepository = ServiceLocator.shared.resolve()) {
        self.repository = repository
        super.init(style: .insetGrouped)
        title = "Family To-Dos"
        tabBarItem = UITabBarItem(title: "To-Dos", image: UIImage(systemName: "checklist"), selectedImage: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func reload() {
        items = repository.allItems()
        tableView.reloadData()
    }

    @objc private func addTapped() {
        if let cls = NSClassFromString("ToDoCreate.ToDoCreateViewController") as? UIViewController.Type {
            let vc = cls.init()
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.notes
        cell.accessoryType = item.isCompleted ? .checkmark : .disclosureIndicator
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        if let cls = NSClassFromString("ToDoDetail.ToDoDetailViewController") as? UIViewController.Type {
            let vc = (cls as! ToDoDetailViewControllerProtocol.Type).initWithToDoId(item.id)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// Protocol to bridge initializer with parameter across NSClassFromString
public protocol ToDoDetailViewControllerProtocol where Self: UIViewController {
    static func initWithToDoId(_ id: UUID) -> UIViewController
}


