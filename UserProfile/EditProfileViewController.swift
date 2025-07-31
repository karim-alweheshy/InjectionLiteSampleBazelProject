//
//  EditProfileViewController.swift
//  UserProfile
//
//  Created by Karim Alweheshy on 31.07.25.
//

import UIKit
import Combine

class EditProfileViewController: UIViewController {
    private var viewModel = UserProfileViewModel()
    
    private var tableView: UITableView!
    private var nameTextField: UITextField!
    private var emailTextField: UITextField!
    private var ageTextField: UITextField!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadCurrentValues()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Edit Profile"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Create individual publishers for each text field
        let namePublisher = createTextFieldPublisher(for: nameTextField)
        let emailPublisher = createTextFieldPublisher(for: emailTextField)  
        let agePublisher = createTextFieldPublisher(for: ageTextField)
        
        // Combine and validate
        Publishers.CombineLatest3(namePublisher, emailPublisher, agePublisher)
            .map { name, email, age in
                !name.isEmpty && !email.isEmpty && !age.isEmpty && Int(age) != nil
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isValid
            }
            .store(in: &cancellables)
    }
    
    private func createTextFieldPublisher(for textField: UITextField?) -> AnyPublisher<String, Never> {
        guard let textField = textField else {
            return Just("").eraseToAnyPublisher()
        }
        
        return NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)
            .compactMap { $0.object as? UITextField }
            .filter { $0 == textField }
            .map { $0.text ?? "" }
            .prepend(textField.text ?? "")
            .eraseToAnyPublisher()
    }
    
    private func loadCurrentValues() {
        let profile = viewModel.userProfile
        nameTextField?.text = profile.name
        emailTextField?.text = profile.email
        ageTextField?.text = String(profile.age)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let ageText = ageTextField.text,
              let age = Int(ageText) else {
            return
        }
        
        viewModel.updateProfile(name: name, email: email, age: age)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension EditProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // Name, Email, Age
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Personal Information"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
        
        switch indexPath.row {
        case 0:
            nameTextField = cell.configure(placeholder: "Name", keyboardType: .default)
            return cell
        case 1:
            emailTextField = cell.configure(placeholder: "Email", keyboardType: .emailAddress)
            return cell
        case 2:
            ageTextField = cell.configure(placeholder: "Age", keyboardType: .numberPad)
            return cell
        default:
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension EditProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - TextFieldCell

class TextFieldCell: UITableViewCell {
    private let textField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(placeholder: String, keyboardType: UIKeyboardType) -> UITextField {
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        return textField
    }
}