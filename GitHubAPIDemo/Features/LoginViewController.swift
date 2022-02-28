import UIKit
import Firebase
import FirebaseAuth
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
    // MARK: - Private
    private let viewModel: LoginViewModel
    private let disposeBag = DisposeBag()
    
    lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 50)
        
        return label
    }()
    
    lazy var accountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.returnKeyType = .next
        textField.tag = 1
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.tag = 2
        return textField
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var restPasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
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
        let accountInfo = Observable.combineLatest(accountTextField.rx.text.orEmpty.asObservable(), passwordTextField.rx.text.orEmpty.asObservable()) { account, number in
            return (account, number)
        }
        
        loginButton.rx.tap
            .withLatestFrom(accountInfo)
            .bind(to: viewModel.loginButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.loginSuccess.asObservable()
            .subscribe(onNext:  { [weak self] _ in
                let viewController = TabBarController()
                viewController.modalPresentationStyle = .fullScreen
                
                self?.present(viewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.loginFailure.asObservable()
            .subscribe(onNext:{ [weak self] error in
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = SignUpViewController()
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.navigationBar.tintColor = .white
                self?.present(navigationController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        restPasswordButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = ResetPasswordViewController()
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.navigationBar.tintColor = .white
                self?.present(navigationController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.logout)
            .subscribe(onNext: { notification in
                self.accountTextField.text = ""
                self.passwordTextField.text = ""
            })
            .disposed(by: disposeBag)
        
        accountTextField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                let nextTag = self.accountTextField.tag + 1
                if let nextResponder = self.accountTextField.superview?.viewWithTag(nextTag) {
                    nextResponder.becomeFirstResponder()
                } else {
                    self.accountTextField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension LoginViewController {
    func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(loginLabel)
        stackView.addArrangedSubview(accountTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(restPasswordButton)
        
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            restPasswordButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 10),
            restPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            restPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            restPasswordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
}

