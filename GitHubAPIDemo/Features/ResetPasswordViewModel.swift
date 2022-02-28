import Foundation
import UIKit
import Firebase
import FirebaseAuth
import RxCocoa
import RxSwift

class ResetPasswordViewModel {
    // MARK: - Private
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    var resetPasswordButtonTapped: AnyObserver<(String)>
    
    // MARK: - Output
    var resetPasswordSuccess = PublishSubject<Void>()
    var resetPasswordFailure = PublishSubject<Error>()
    
    init() {
        let resetPasswordButtonTappedSubject = PublishSubject<(String)>()
        resetPasswordButtonTapped = resetPasswordButtonTappedSubject.asObserver()
        
        let resetPasswordResult = resetPasswordButtonTappedSubject.asObservable()
            .flatMapLatest { account in
                FirebaseService.shared.resetPassword(account: account)
                    .asObservable()
                    .materialize()
            }
            .share()
        
        let resetPasswordSuccessCondition = resetPasswordResult.elements()
        let resetPasswordFailureCondition = resetPasswordResult.errors()
        
        resetPasswordSuccessCondition
            .bind(to: resetPasswordSuccess.asObserver())
            .disposed(by: disposeBag)

        resetPasswordFailureCondition
            .bind(to: resetPasswordFailure.asObserver())
            .disposed(by: disposeBag)
    }
}
