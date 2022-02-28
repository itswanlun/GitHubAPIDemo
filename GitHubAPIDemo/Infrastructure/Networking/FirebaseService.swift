import Foundation
import RxCocoa
import RxSwift
import Firebase
import FirebaseAuth

enum APIError: Error {
    case unknown
}

class FirebaseService {
    static let shared = FirebaseService()
    private init() { }
    
    func signUp(account: String, password: String) -> Single<Void> {
        return Single.create { (single) -> Disposable in
            Auth.auth().createUser(withEmail: account, password: password) { (user, error) in
                if let error = error {
                    single(.failure(error))
                } else if let _ = user {
                    single(.success(Void()))
                } else {
                    single(.failure(APIError.unknown))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func signIn(account: String, password: String) -> Single<Void> {
        return Single.create { (single) -> Disposable in
            Auth.auth().signIn(withEmail: account, password: password) { (user, error) in
                if let error = error {
                    single(.failure(error))
                } else if let _ = user {
                    single(.success(Void()))
                } else {
                    single(.failure(APIError.unknown))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func resetPassword(account: String) -> Single<Void> {
        return Single.create { (single) -> Disposable in
            Auth.auth().sendPasswordReset(withEmail: account, completion: { (error) in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(Void()))
                }
            })
            
            return Disposables.create()
        }
    }
}

