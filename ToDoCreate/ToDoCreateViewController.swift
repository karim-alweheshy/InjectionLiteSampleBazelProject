import UIKit
import AppCore

public final class ToDoCreateViewController: UIViewController {
    private let repository: ToDoRepository

    private let titleField = UITextField()
    private let notesField = UITextView()
    private let duePicker = UIDatePicker()
    private let saveButton = UIButton(type: .system)

    public init(repository: ToDoRepository = ServiceLocator.shared.resolve()) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
        title = "Create To-Dooo"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Support dynamic instantiation via UIViewController.init()
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.repository = ServiceLocator.shared.resolve()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Create To-Do"
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
    }

    private func layout() {
        titleField.placeholder = "Title"
        titleField.borderStyle = .roundedRect
        notesField.layer.borderWidth = 1
        notesField.layer.borderColor = UIColor.separator.cgColor
        notesField.layer.cornerRadius = 8
        duePicker.datePickerMode = .dateAndTime
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleField, notesField, duePicker, saveButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            notesField.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    @objc private func saveTapped() {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else { return }
        var item = ToDoItem(title: title, notes: notesField.text)
        if duePicker.date.timeIntervalSinceNow > 0 { item.dueDate = duePicker.date }
        repository.add(item)
        navigationController?.popViewController(animated: true)
    }
}


