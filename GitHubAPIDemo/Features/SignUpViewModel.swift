import Foundation
import RxCocoa
import RxSwift
import RxSwiftExt

class SignUpViewModel {
    // MARK: - Private
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    var signUpButtonTapped: AnyObserver<(String, String)>
    
    // MARK: - Output
    var signUpSuccess = PublishSubject<Void>()
    var signUpFailure = PublishSubject<Error>()
    
    init() {
        let signUpButtonTappedSubject = PublishSubject<(String, String)>()
        signUpButtonTapped = signUpButtonTappedSubject.asObserver()
        
        let signUpResult = signUpButtonTappedSubject.asObservable()
            .flatMapLatest { account, password in
                FirebaseService.shared.signUp(account: account, password: password)
                    .asObservable()
                    .materialize()
            }
            .share()
        
        let profileSuccessCondition = signUpResult.elements()
        let profileFailureCondition = signUpResult.errors()
        
        profileSuccessCondition
            .bind(to: signUpSuccess.asObserver())
            .disposed(by: disposeBag)

        profileFailureCondition
            .bind(to: signUpFailure.asObserver())
            .disposed(by: disposeBag)
    }
}

