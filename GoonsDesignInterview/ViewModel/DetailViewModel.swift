import Foundation
import Combine

class DetailViewModel {
    
    // MARK: - Init
    var input: Input!
    var output: Output!
    
    struct Input {
        
    }
    
    struct Output {
        let config: AnyPublisher<RepositoryItemModel?, Never>
        let ownerAvatarData: AnyPublisher<Data?, Never>
    }
    
    private let config = CurrentValueSubject<RepositoryItemModel?, Never>(nil)
    private let ownerAvatarData = CurrentValueSubject<Data?, Never>(nil)
    
    init(item: RepositoryItemModel) {
        self.item = item
        
        Task {
            config.send(item)
            await fetchOwnerIcon()
        }
        
        // output
        
        output = Output(config: config.eraseToAnyPublisher(),
                        ownerAvatarData: ownerAvatarData.eraseToAnyPublisher())
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Property
    private var cancellables = Set<AnyCancellable>()
    private let apiMangaer = APIManager()
    private var item: RepositoryItemModel
    
    // MARK: - Method
    func fetchOwnerIcon() async {
        guard let avatarUrlString = config.value!.owner.avatarUrl else { return }
        guard let request = apiMangaer.createRequest(url: avatarUrlString) else { return }
        let ownerAvatarData = await apiMangaer.operateRequest(request: request)
        self.ownerAvatarData.send(ownerAvatarData)
    }

}
