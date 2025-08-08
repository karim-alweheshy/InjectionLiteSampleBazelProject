import UIKit
import AppCore
import ToDoList
import Reminders
import Sharing

public final class ToDoDetailViewController: UIViewController, ToDoDetailViewControllerProtocol {
    private let repository: ToDoRepository
    private let toDoId: UUID

    public static func initWithToDoId(_ id: UUID) -> UIViewController {
        ToDoDetailViewController(id: id)
    }

    public init(id: UUID, repository: ToDoRepository = ServiceLocator.shared.resolve()) {
        self.repository = repository
        self.toDoId = id
        super.init(nibName: nil, bundle: nil)
        title = "To-Do Details"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let titleLabel = UILabel()
    private let notesLabel = UILabel()
    private let dueLabel = UILabel()
    private let reminderLabel = UILabel()
    private let sharedLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    private let reminderButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
        reload()
    }

    private func layout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, notesLabel, dueLabel, reminderLabel, sharedLabel, completeButton, reminderButton, shareButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        completeButton.setTitle("Toggle Complete", for: .normal)
        reminderButton.setTitle("Set Reminder", for: .normal)
        shareButton.setTitle("Share", for: .normal)
        completeButton.addTarget(self, action: #selector(toggleComplete), for: .touchUpInside)
        reminderButton.addTarget(self, action: #selector(openReminder), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(openShare), for: .touchUpInside)
    }

    private func reload() {
        guard let item = repository.item(withId: toDoId) else { return }
        titleLabel.text = "Title: \(item.title)"
        notesLabel.text = "Notes: \(item.notes)"
        if let due = item.dueDate { dueLabel.text = "Due: \(DateFormatter.localizedString(from: due, dateStyle: .medium, timeStyle: .short))" } else { dueLabel.text = "Due: -" }
        if let rd = item.reminderDate { reminderLabel.text = "Reminder: \(DateFormatter.localizedString(from: rd, dateStyle: .medium, timeStyle: .short))" } else { reminderLabel.text = "Reminder: -" }
        sharedLabel.text = "Shared With: \(item.sharedWith.joined(separator: ", "))"
        completeButton.setTitle(item.isCompleted ? "Mark Incomplete" : "Mark Complete", for: .normal)
    }

    @objc private func toggleComplete() {
        let item = repository.item(withId: toDoId)
        repository.markCompleted(id: toDoId, completed: !(item?.isCompleted ?? false))
        reload()
    }

    @objc private func openReminder() {
        if let cls = NSClassFromString("Reminders.ReminderViewController") as? UIViewController.Type {
            let vc = (cls as! ReminderViewControllerProtocol.Type).initWithToDoId(toDoId)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func openShare() {
        if let cls = NSClassFromString("Sharing.ShareViewController") as? UIViewController.Type {
            let vc = (cls as! ShareViewControllerProtocol.Type).initWithToDoId(toDoId)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


