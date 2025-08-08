import UIKit
import AppCore

public protocol ReminderViewControllerProtocol where Self: UIViewController {
    static func initWithToDoId(_ id: UUID) -> UIViewController
}

public final class ReminderViewController: UIViewController, ReminderViewControllerProtocol {
    private let repository: ToDoRepository
    private let toDoId: UUID
    private let picker = UIDatePicker()
    private let saveButton = UIButton(type: .system)

    public static func initWithToDoId(_ id: UUID) -> UIViewController { ReminderViewController(id: id) }

    public init(id: UUID, repository: ToDoRepository = ServiceLocator.shared.resolve()) {
        self.repository = repository
        self.toDoId = id
        super.init(nibName: nil, bundle: nil)
        title = "Set Reminder"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        picker.datePickerMode = .dateAndTime
        saveButton.setTitle("Save Reminder", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [picker, saveButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

    @objc private func saveTapped() {
        repository.setReminder(id: toDoId, date: picker.date)
        navigationController?.popViewController(animated: true)
    }
}


