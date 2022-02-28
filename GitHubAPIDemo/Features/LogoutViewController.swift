import UIKit
import Firebase
import FirebaseAuth
import RxCocoa
import RxSwift

extension NSNotification.Name {
    static let logout = Notification.Name("logout")
}

class LogoutViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    lazy var logOutButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 5

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    func bindViewModel() {
        logOutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                NotificationCenter.default.post(name: .logout, object: nil)
                
                self?.dismiss(animated: true, completion: .none)
            })
            .disposed(by: disposeBag)
    }
}

extension LogoutViewController {
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(logOutButton)
        
        NSLayoutConstraint.activate([
            logOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logOutButton.widthAnchor.constraint(equalToConstant: 100),
            logOutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}




