import UIKit
import AppCore

public protocol AuthService {
    func login(username: String, password: String, completion: @escaping (Bool) -> Void)
    var isAuthenticated: Bool { get }
}

public final class MockAuthService: AuthService {
    public private(set) var isAuthenticated: Bool = false
    public init() {}
    public func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isAuthenticated = !username.isEmpty && !password.isEmpty
            completion(self.isAuthenticated)
        }
    }
}

public final class LoginViewController: UIViewController {
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let authService: AuthService

    public init(authService: AuthService = ServiceLocator.shared.resolve()) {
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
        title = "Login"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        usernameField.placeholder = "Username"
        usernameField.borderStyle = .roundedRect
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [usernameField, passwordField, loginButton, statusLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func loginTapped() {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        authService.login(username: username, password: password) { [weak self] success in
            self?.statusLabel.text = success ? "Success" : "Failed"
        }
    }
}


