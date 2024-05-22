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
        let refreshControlIsRefreshing: PassthroughSubject<Void, Never>
        let didSelectRowAt: PassthroughSubject<IndexPath, Never>
    }
    
    struct Output {
        let reloadRepositoryTableView: AnyPublisher<Void, Never>
        let urlIsInvalid: AnyPublisher<Void, Never>
        let pushDetailViewController: AnyPublisher<RepositoryItemModel?, Never>
    }
    
    private let reloadRepositoryTableView = CurrentValueSubject<Void, Never>(())
    private let urlIsInvalid = CurrentValueSubject<Void, Never>(())
    private let pushDetailViewController = CurrentValueSubject<RepositoryItemModel?, Never>(nil)
    
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
                self.query = ""
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
        
        let refreshControlIsRefreshing = PassthroughSubject<Void, Never>()
        refreshControlIsRefreshing
            .sink { [weak self] in
                guard let self = self else { return }
                guard query.isEmpty else { 
                    Task {
                        await self.searchRepository(query: self.query)
                        self.reloadRepositoryTableView.send()
                    }
                    return }
                self.urlIsInvalid.send()
            }
            .store(in: &cancellables)
        
        let didSelectRowAt = PassthroughSubject<IndexPath, Never>()
        didSelectRowAt
            .sink { [weak self] indexPath in
                guard let self = self else { return }
                pushDetailViewController.send(fetchRepositoryItem(indexPath: indexPath))
            }
            .store(in: &cancellables)
        
        input = Input(searchBarTextDidChange: searchBarTextDidChange,
                      searchBarTextRemove: searchBarTextRemove,
                      searchBarSearchButtonClicked: searchBarSearchButtonClicked,
                      refreshControlIsRefreshing: refreshControlIsRefreshing,
                      didSelectRowAt: didSelectRowAt)
        
        // Output
        
        output = Output(reloadRepositoryTableView: reloadRepositoryTableView.eraseToAnyPublisher(),
                        urlIsInvalid: urlIsInvalid.eraseToAnyPublisher(),
                        pushDetailViewController: pushDetailViewController.eraseToAnyPublisher())
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
        guard let avatarUrlString = item.owner.avatarUrl else { return nil }
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
