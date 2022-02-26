import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct Section {
    var header: String = ""
    var items: [Item]
}

struct Profile {
    var name: String
    var avatarURL: String
}

extension Section: SectionModelType {
    typealias Item = Profile
     
    init(original: Section, items: [Item]) {
        self = original
        self.items = items
    }
}

