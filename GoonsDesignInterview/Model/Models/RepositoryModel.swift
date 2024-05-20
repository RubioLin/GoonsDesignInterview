import Foundation

struct RepositoryModel: Codable {
    var items: [RepositoryItemModel]
}

struct RepositoryItemModel: Codable {
    var full_name: String?
    var description: String?
    var owner: RepositoryItemOwnerModel
}

struct RepositoryItemOwnerModel: Codable {
    var avatar_url: String?
}
