import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Init
    init(item: RepositoryItemModel) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        print(self.item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Element
    private var ownView: DetailView!
    
    // MARK: - Property
    private let item: RepositoryItemModel!
    
    // MARK: - Method
    override func loadView() {
        super.loadView()
        setupOwnView()
    }
    
    private func setupOwnView() {
        let viewModel = DetailViewModel(item: item)
        ownView = DetailView(viewModel: viewModel)
        ownView.delegate = self
        view = ownView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .black
        title = item.fullName!.components(separatedBy: "/")[0]
    }
}


extension DetailViewController: DetailViewControllerDelegate {
    
}
