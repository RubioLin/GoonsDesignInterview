import UIKit

class SearchController: UIViewController {
    
    // MARK: - Init
    
    // MARK: - Element
    private var ownView: SearchView!
    
    // MARK: - Property
    
    // MARK: - Method
    override func loadView() {
        super.loadView()
        setupOwnView()
    }
    
    private func setupOwnView() {
        let viewModel = SearchViewModel()
        ownView = SearchView(viewModel: viewModel)
        ownView.delegate = self
        view = ownView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        title = "Repository Search"
    }
}

extension SearchController: SearchControllerDelegate {
    
}
