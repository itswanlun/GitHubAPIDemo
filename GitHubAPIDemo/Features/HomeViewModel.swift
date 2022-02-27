import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

class HomeViewModel {
    // MARK: - Private
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    let searchText: AnyObserver<String>
    let triggerNextPage: AnyObserver<String>
    
    // MARK: - Output
    var result = PublishSubject<[Section]>()
    let isFreshing: Observable<Bool>
    let isLoading: Observable<Bool>
    let page: Observable<Int>
    
    init() {
        let searchSubject = PublishSubject<String>()
        searchText = searchSubject.asObserver()
        
        let triggerNextPageSubject = PublishSubject<String>()
        triggerNextPage = triggerNextPageSubject.asObserver()
        
        let refresh = ActivityIndicator()
        isFreshing = refresh.asObservable()
        
        let indicator = ActivityIndicator()
        isLoading = indicator.asObservable()
        
        let pageSubject = BehaviorSubject<Int>(value: 1)
        page = pageSubject.asObservable()
        
        let profileResult = searchSubject.asObservable()
            .filter { !$0.isEmpty }
            .flatMapLatest { keyword in
                provider.rx.request(GitHub.searchRepositories(keyword, 1))
                    .map(Repositories.self)
                    .trackActivity(refresh)
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
        
        let nextProfileResult = triggerNextPageSubject.asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(pageSubject) { (keyword: $0, page: $1) }
            .flatMapLatest {
                provider.rx.request(GitHub.searchRepositories($0.keyword, $0.page + 1))
                    .map(Repositories.self)
                    .trackActivity(indicator)
                    .materialize()
            }
            .share()
            
        let nextprofileSuccessCondition = nextProfileResult.elements().filter { $0.items != nil }
        let nextprofileIsEndCondition = nextProfileResult.elements().filter { $0.items == nil }
        let nextprofileFailureCondition = nextProfileResult.errors()
        
        nextprofileSuccessCondition
            .map(convertToData)
            .withLatestFrom(result) { (current: $0, previous: $1) }
            .map { $1 + $0 }
            .bind(to: result)
            .disposed(by: disposeBag)
        
        nextprofileSuccessCondition
            .withLatestFrom(pageSubject)
            .map { $0 + 1 }
            .bind(to: pageSubject)
            .disposed(by: disposeBag)
        
        
        nextprofileIsEndCondition
            .subscribe()
            .disposed(by: disposeBag)
        
        nextprofileFailureCondition
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
