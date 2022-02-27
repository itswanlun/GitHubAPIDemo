import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

class HomeViewModel {
    // MARK: - Private
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    let searchText: AnyObserver<String>
    
    // MARK: - Output
    var result = PublishSubject<[Section]>()
    let isLoading: Observable<Bool>
    
    init() {
        let searchSubject = PublishSubject<String>()
        searchText = searchSubject.asObserver()
        
        let indicator = ActivityIndicator()
        isLoading = indicator.asObservable()
        
        let profileResult = searchSubject.asObservable()
            .filter { !$0.isEmpty }
            .flatMapLatest { keyword in
                provider.rx.request(GitHub.searchRepositories(keyword, 1))
                    .map(Repositories.self)
                    .trackActivity(indicator)
                    .materialize()
            }
            .share()
        
        let profileSuccessCondition = profileResult.elements().filter { $0.items != nil }
        let profileIsEndCondition = profileResult.elements().filter { $0.items == nil }
        let profileFailureCondition = profileResult.errors()
        
        profileSuccessCondition
            .map(convertToData)
            .bind(to: result)
            .disposed(by: disposeBag)
        
        profileIsEndCondition
            .subscribe()
            .disposed(by: disposeBag)
        
        profileFailureCondition
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func convertToData(_ profile: Repositories) -> [Section] {
        if let profileItems = profile.items {
            let items = profileItems.map { Profile(name: $0.name, avatarURL: $0.owner.avatarURL) }
            let data = [Section(items: items)]
            
            return data
        }
        return []
    }
}
