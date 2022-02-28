import Foundation
extension Optional where Wrapped: Collection  {
    var isEmptyOrNil: Bool {
        self?.isEmpty ?? true
    }
}
