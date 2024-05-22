import UIKit
import SnapKit
import Combine
import CombineCocoa

protocol DetailViewControllerDelegate: AnyObject {
    
}

class DetailView: UIView {
    
    // MARK: - Init
    init(viewModel: DetailViewModel) {
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
    lazy var avatarIcon: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "folder.badge.questionmark.ar"))
        return v
    }()
    
    lazy var fullNameLabel: UILabel = {
        let v = UILabel()
        v.text = "TEST"
        v.font = UIFont.systemFont(ofSize: 24)
        return v
    }()
    
    lazy var languageLabel: UILabel = {
        let v = UILabel()
        v.text = "TEST"
        v.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return v
    }()
    
    lazy var starsLabel: UILabel = {
        let v = UILabel()
        v.text = "TEST"
        v.font = UIFont.systemFont(ofSize: 14)
        return v
    }()
    
    lazy var watchersLabel: UILabel = {
        let v = UILabel()
        v.text = "TEST"
        v.font = UIFont.systemFont(ofSize: 14)
        return v
    }()
    
    lazy var forksLabel: UILabel = {
        let v = UILabel()
        v.text = "TEST"
        v.font = UIFont.systemFont(ofSize: 14)
        return v
    }()
    
    lazy var issuesLabel: UILabel = {
        let v = UILabel()
        v.text = "TEST"
        v.font = UIFont.systemFont(ofSize: 14)
        return v
    }()
    
    // MARK: - Property
    weak var delegate: DetailViewControllerDelegate?
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: DetailViewModel
    
    // MARK: - Method
    override func layoutSubviews() {
        super.layoutSubviews()
        subviewLayout()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    private func initializeView() {
        addSubview(avatarIcon)
        addSubview(fullNameLabel)
        addSubview(languageLabel)
        addSubview(starsLabel)
        addSubview(watchersLabel)
        addSubview(forksLabel)
        addSubview(issuesLabel)
    }
    
    private func subviewLayout() {
        avatarIcon.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.left.right.equalToSuperview().inset(12)
            $0.height.equalTo(avatarIcon.snp.width)
        }
        
        fullNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(avatarIcon.snp.bottom).offset(48)
        }
        
        languageLabel.snp.makeConstraints {
            $0.top.equalTo(fullNameLabel.snp.bottom).offset(48)
            $0.left.equalToSuperview().inset(12)
            $0.right.lessThanOrEqualTo(starsLabel)
        }
        
        starsLabel.snp.makeConstraints {
            $0.top.equalTo(fullNameLabel.snp.bottom).offset(48)
            $0.right.equalToSuperview().inset(12)
        }
        
        watchersLabel.snp.makeConstraints {
            $0.top.equalTo(starsLabel.snp.bottom).offset(12)
            $0.right.equalToSuperview().inset(12)
        }
        
        forksLabel.snp.makeConstraints {
            $0.top.equalTo(watchersLabel.snp.bottom).offset(12)
            $0.right.equalToSuperview().inset(12)
        }
        
        issuesLabel.snp.makeConstraints {
            $0.top.equalTo(forksLabel.snp.bottom).offset(12)
            $0.right.equalToSuperview().inset(12)
        }
        
    }
    
    private func bind(viewModel: DetailViewModel) {
        viewModel.output.config
            .sink { [weak self] item in
                guard let self = self else { return }
                guard let item = item else { return }
                DispatchQueue.main.async {
                    self.fullNameLabel.text = item.fullName ?? ""
                    self.languageLabel.text = "Written in \(item.language ?? "")"
                    self.starsLabel.text = "\(item.stargazersCount ?? 0) stars"
                    self.watchersLabel.text = "\(item.watchersCount ?? 0) watchers"
                    self.forksLabel.text = "\(item.forksCount ?? 0) forks"
                    self.issuesLabel.text = "\(item.openIssuesCount ?? 0) open issues"
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.ownerAvatarData
            .sink { [weak self] data in
                guard let self = self,
                      let data = data else { return }
                DispatchQueue.main.async {
                    self.avatarIcon.image = UIImage(data: data)
                }
            }
            .store(in: &cancellables)
    }
}
