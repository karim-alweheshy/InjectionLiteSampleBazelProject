import UIKit
import AppCore

public protocol ShareViewControllerProtocol where Self: UIViewController {
    static func initWithToDoId(_ id: UUID) -> UIViewController
}

public final class ShareViewController: UIViewController, ShareViewControllerProtocol {
    private let repository: ToDoRepository
    private let toDoId: UUID
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)

    public static func initWithToDoId(_ id: UUID) -> UIViewController { ShareViewController(id: id) }

    public init(id: UUID, repository: ToDoRepository = ServiceLocator.shared.resolve()) {
        self.repository = repository
        self.toDoId = id
        super.init(nibName: nil, bundle: nil)
        title = "Share To-Do"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        textField.placeholder = "Enter member emails separated by commas"
        textField.borderStyle = .roundedRect
        addButton.setTitle("Share", for: .normal)
        addButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [textField, addButton])
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

    @objc private func shareTapped() {
        let members = textField.text?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        repository.share(id: toDoId, members: members)
        navigationController?.popViewController(animated: true)
    }
}


