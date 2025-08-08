import UIKit

public final class SettingDetailViewController: UIViewController {
    private let titleText: String
    private let descriptionText: String

    public init(title: String, description: String) {
        self.titleText = title
        self.descriptionText = description
        super.init(nibName: nil, bundle: nil)
        self.title = title + "lol"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.numberOfLines = 0
        label.text = descriptionText
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])
    }
}


