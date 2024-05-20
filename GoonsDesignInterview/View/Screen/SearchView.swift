import UIKit
import SnapKit
import Combine
import CombineCocoa

protocol SearchControllerDelegate: AnyObject {
    func showAlert()
}

class SearchView: UIView {

    // MARK: - Init
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        backgroundColor = .white
        initializeView()
        bind(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Element
    lazy var searchBar: UISearchBar = {
        let v = UISearchBar()
        v.placeholder = "請輸入關鍵字搜尋"
        return v
    }()
    
    lazy var repositoryTableView: UITableView = {
        let v = UITableView()
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = UITableView.automaticDimension
        v.separatorStyle = .none
        v.sectionHeaderTopPadding = 0
        v.delegate = self
        v.dataSource = self
        v.register(RepositoryTableViewCell.self, forCellReuseIdentifier: "RepositoryTableViewCell")
        return v
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.backgroundColor = .gray
        v.color = .white
        return v
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let v = UIRefreshControl()
        return v
    }()
    
    // MARK: - Property
    weak var delegate: SearchControllerDelegate?
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: SearchViewModel
    
    // MARK: - Method
    override func layoutSubviews() {
        super.layoutSubviews()
        subviewLayout()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    private func initializeView() {
        addSubview(repositoryTableView)
        addSubview(activityIndicatorView)
        repositoryTableView.addSubview(refreshControl)
    }
    
    private func subviewLayout() {
        activityIndicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        repositoryTableView.snp.makeConstraints {
            $0.top.left.right.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bind(viewModel: SearchViewModel) {
        searchBar.textDidChangePublisher
            .sink { text in
                guard !text.isEmpty else {
                    viewModel.input.searchBarTextRemove.send()
                    return }
                viewModel.input.searchBarTextDidChange.send(text)
            }
            .store(in: &cancellables)
        
        searchBar.searchButtonClickedPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.activityIndicatorView.startAnimating()
                viewModel.input.searchBarSearchButtonClicked.send()
                self.searchBar.resignFirstResponder()
            }
            .store(in: &cancellables)
        
        refreshControl.isRefreshingPublisher
            .sink { isRefreshing in
                guard isRefreshing else { return }
                viewModel.input.refreshControlIsRefreshing.send()
            }
            .store(in: &cancellables)
        
        viewModel.output.reloadRepositoryTableView
            .sink { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.repositoryTableView.reloadData()
                    self.activityIndicatorView.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.urlIsInvalid
            .sink { [weak self] in
                self?.delegate?.showAlert()
            }
            .store(in: &cancellables)
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
}

// MARK: - UITableView
extension SearchView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchBar
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRepositoryItem()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryTableViewCell", for: indexPath) as? RepositoryTableViewCell else { return UITableViewCell() }
        
        cell.config(item: viewModel.fetchRepositoryItem(indexPath: indexPath))
        Task {
            await cell.configIcon(data: viewModel.fetchOwnerIcon(indexPath: indexPath))
        }
        
        return cell
    }
    
    // 讓 header 可以跟著滑動
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == repositoryTableView {
            let offsetY = scrollView.contentOffset.y
            let searchBarHeight = searchBar.frame.size.height
            if offsetY <= searchBarHeight && offsetY >= 0 {
                scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
            } else if offsetY >= searchBarHeight {
                scrollView.contentInset = UIEdgeInsets(top: -searchBarHeight, left: 0, bottom: 0, right: 0)
            }
        }
    }
}
