import Foundation

struct Repositories: Codable {
    let items: [Item]?
}

struct Item: Codable {
    let name: String
    let owner: Owner
}

struct Owner: Codable {
    let avatarURL: String

    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
    }
}

