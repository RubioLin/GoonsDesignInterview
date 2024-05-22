import Foundation

struct RepositoryModel: Codable {
    var items: [RepositoryItemModel]
}

struct RepositoryItemModel: Codable {
    var fullName: String?
    var description: String?
    var language: String?
    var stargazersCount: Int?
    var watchersCount: Int?
    var forksCount: Int?
    var openIssuesCount: Int?
    var owner: RepositoryItemOwnerModel
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case description
        case language
        case owner
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
    }
}

struct RepositoryItemOwnerModel: Codable {
    var avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }
}
