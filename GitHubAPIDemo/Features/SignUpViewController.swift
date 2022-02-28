import UIKit
import Firebase
import FirebaseAuth
import RxCocoa
import RxSwift

class SignUpViewController: UIViewController {
    // MARK: - Private
    private let viewModel: SignUpViewModel
    private let disposeBag = DisposeBag()
    
    lazy var signUpLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign Up"
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
    
    lazy var signUpButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    init(viewModel: SignUpViewModel = SignUpViewModel()) {
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
        
        signUpButton.rx.tap
            .withLatestFrom(accountInfo)
            .bind(to: viewModel.signUpButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.signUpSuccess.asObservable()
            .subscribe(onNext:  { [weak self] _ in
                let alertController = UIAlertController(title: "Success", message: "Your account has been created", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "continue", style: .cancel, handler: { _ in self?.dismiss(animated: true, completion: .none) })
                
                alertController.addAction(defaultAction)
                
                self?.present(alertController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.signUpFailure.asObservable()
            .subscribe(onNext:{ [weak self] error in
                
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self?.present(alertController, animated: true, completion: nil)
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

extension SignUpViewController {
    func setupUI() {
        view.backgroundColor = .white
        setupNavigation()
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(signUpLabel)
        stackView.addArrangedSubview(accountTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(signUpButton)
        
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

