import Foundation
import RxCocoa
import RxSwift
import RxSwiftExt

class LoginViewModel {
    // MARK: - Private
    private let disposeBag = DisposeBag()
    // MARK: - Input
    var loginButtonTapped: AnyObserver<(String, String)>
    // MARK: - Output
    var loginSuccess = PublishSubject<Void>()
    var loginFailure = PublishSubject<Error>()
    
    init() {
        let loginButtonTappedSubject = PublishSubject<(String, String)>()
        loginButtonTapped = loginButtonTappedSubject.asObserver()

        let loginUpResult = loginButtonTappedSubject.asObservable()
            .flatMapLatest { account, password in
                FirebaseService.shared.signIn(account: account, password: password)
                    .asObservable()
                    .materialize()
            }
            .share()
        
        let profileSuccessCondition = loginUpResult.elements()
        let profileFailureCondition = loginUpResult.errors()
        
        profileSuccessCondition
            .bind(to: loginSuccess.asObserver())
            .disposed(by: disposeBag)

        profileFailureCondition
            .bind(to: loginFailure.asObserver())
            .disposed(by: disposeBag)
    }
}

