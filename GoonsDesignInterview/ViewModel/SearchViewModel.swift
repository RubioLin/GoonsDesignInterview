import Foundation
import Combine

class SearchViewModel {
    
    // MARK: - Init
    var input: Input!
    var output: Output!
    
    struct Input {
        let searchBarTextDidChange: PassthroughSubject<String, Never>
        let searchBarTextRemove: PassthroughSubject<Void, Never>
        let searchBarSearchButtonClicked: PassthroughSubject<Void, Never>
    }
    
    struct Output {
        let reloadRepositoryTableView: AnyPublisher<Void, Never>
    }
    
    private let reloadRepositoryTableView = CurrentValueSubject<Void, Never>(())
    
    init() {
        
        // Input
        let searchBarTextDidChange = PassthroughSubject<String, Never>()
        searchBarTextDidChange
            .sink { [weak self] text in
                guard let self = self else { return }
                self.query = text
            }
            .store(in: &cancellables)
        
        let searchBarTextRemove = PassthroughSubject<Void, Never>()
        searchBarTextRemove
            .sink { [weak self] in
                guard let self = self else { return }
                self.items.removeAll()
                self.reloadRepositoryTableView.send()
            }
            .store(in: &cancellables)
        
        let searchBarSearchButtonClicked = PassthroughSubject<Void, Never>()
        searchBarSearchButtonClicked
            .sink { [weak self] in
                guard let self = self else { return }
                Task {
                    await self.searchRepository(query: self.query)
                    self.reloadRepositoryTableView.send()
                }
            }
            .store(in: &cancellables)
        
        input = Input(searchBarTextDidChange: searchBarTextDidChange,
                      searchBarTextRemove: searchBarTextRemove,
                      searchBarSearchButtonClicked: searchBarSearchButtonClicked)
        
        // Output
        
        output = Output(reloadRepositoryTableView: self.reloadRepositoryTableView.eraseToAnyPublisher())
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Property
    private var cancellables = Set<AnyCancellable>()
    private let apiMangaer = APIManager()
    private var query: String = ""
    private var page: Int = 1
    private var items: [RepositoryItemModel] = []
    // TODO: - 要做更新頁面 往下拉到底要 load 第二頁 page = 2
    
    // MARK: - Method
    private func searchRepository(query: String) async {
        var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")
        urlComponents?.queryItems = [URLQueryItem(name: "q", value: query),
                                     URLQueryItem(name: "page", value: self.page.description)]
        guard let url = urlComponents?.url else { return }
        guard let request = apiMangaer.createRequest(url: url.absoluteString) else { return }
        
        let repository = await apiMangaer.operateRequest(request: request, type: RepositoryModel.self)
        
        items = repository?.items ?? []
    }
    
    func fetchOwnerIcon(indexPath: IndexPath) async -> Data? {
        let item = items[indexPath.row]
        guard let avatarUrlString = item.owner.avatar_url else { return nil }
        guard let request = apiMangaer.createRequest(url: avatarUrlString) else { return nil }
        return await apiMangaer.operateRequest(request: request)
    }
    
    func numberOfRepositoryItem() -> Int {
        items.count
    }
    
    func fetchRepositoryItem(indexPath: IndexPath) -> RepositoryItemModel {
        items[indexPath.row]
    }
}
