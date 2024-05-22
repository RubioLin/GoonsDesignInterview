import UIKit

class SearchViewController: UIViewController {
    
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

extension SearchViewController: SearchControllerDelegate {
    func showAlert() {
        let alert = UIAlertController(title: "Oops!",
                                      message: "The data couldn't be read because it is missing.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.ownView.endRefreshing()
        }))
        
        present(alert, animated: true)
    }
    
    func push(item: RepositoryItemModel) {
        let controller = DetailViewController(item: item)
        navigationController?.pushViewController(controller, animated: true)
    }
}
