import Foundation
import RxSwift
import RxCocoa
import Moya

let provider = MoyaProvider<GitHub>()

enum GitHub {
    case searchRepositories(String, Int)
}

extension GitHub: TargetType {
    var baseURL: URL { URL(string: "https://api.github.com")! }
    var path: String {
        switch self {
        case .searchRepositories:
            return "/search/repositories"
        }
    }
    var method: Moya.Method {
        return .get
    }
    var task: Task {
        switch self {
        case .searchRepositories(let keyword, let page):
            return .requestParameters(parameters: ["q": keyword, "page": page], encoding: URLEncoding.default)
        }
    }
    var validationType: ValidationType {
        return .none
    }
    var sampleData: Data {
        return Data()
    }
    var headers: [String: String]? {
        return nil
    }
}

