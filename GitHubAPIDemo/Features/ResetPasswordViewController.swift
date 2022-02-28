import UIKit
import Firebase
import FirebaseAuth
import RxCocoa
import RxSwift

class ResetPasswordViewController: UIViewController {
    // MARK: - Private
    private let viewModel: ResetPasswordViewModel
    private let disposeBag = DisposeBag()
    
    lazy var resetPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Rest Password"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 40)
        
        return label
    }()
    
    lazy var accountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.returnKeyType = .done
 
        return textField
    }()
    
    lazy var restPasswordButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        return stackView
    }()
    
    init(viewModel: ResetPasswordViewModel = ResetPasswordViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    func bindViewModel() {
        restPasswordButton.rx.tap
            .withLatestFrom(accountTextField.rx.text.orEmpty)
            .bind(to: viewModel.resetPasswordButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.resetPasswordSuccess.asObservable()
            .subscribe(onNext:  { [weak self] _ in
                let alertController = UIAlertController(title: "Check Your Email", message: "Please check the email", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "continue", style: .cancel, handler: { _ in self?.dismiss(animated: true, completion: .none) })
                
                alertController.addAction(defaultAction)
                
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.resetPasswordFailure.asObservable()
            .subscribe(onNext:{ [weak self] error in
                
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension ResetPasswordViewController {
    func setupUI() {
        view.backgroundColor = .white
        setupNavigation()
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(resetPasswordLabel)
        stackView.addArrangedSubview(accountTextField)
        stackView.addArrangedSubview(restPasswordButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func setupNavigation() {
        let image = UIImage(systemName: "multiply")
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.tintColor = .darkGray

        button.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true, completion: .none)
            })
            .disposed(by: disposeBag)
    }
}

