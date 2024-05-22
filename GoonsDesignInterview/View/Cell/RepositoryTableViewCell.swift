import UIKit
import SnapKit
import Combine

class RepositoryTableViewCell: UITableViewCell {

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        
        initializeView()
        subviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Element
    lazy var ownerIcon: UIImageView = {
        let v = UIImageView()
        v.clipsToBounds = true
        return v
    }()
    
    lazy var textView: UIView = {
        return UIView()
    }()
    
    lazy var repositoryNameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return v
    }()
    
    lazy var descriptionLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 14)
        v.numberOfLines = 0
        return v
    }()
    
    lazy var separator: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    // MARK: - Property
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Method
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func initializeView() {
        contentView.addSubview(ownerIcon)
        contentView.addSubview(textView)
        contentView.addSubview(separator)
        textView.addSubview(repositoryNameLabel)
        textView.addSubview(descriptionLabel)
    }
    
    private func subviewLayout() {
        ownerIcon.snp.makeConstraints {
            $0.size.equalTo(80)
            $0.top.bottom.equalToSuperview().inset(8).priority(999)
            $0.left.equalToSuperview().inset(8)
        }
        
        textView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.right.equalToSuperview().inset(8)
            $0.left.equalTo(ownerIcon.snp.right).offset(8)
        }
        
        repositoryNameLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(repositoryNameLabel.snp.bottom).offset(4)
            $0.bottom.left.right.equalToSuperview()
        }
        
        separator.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.right.equalToSuperview()
            $0.left.equalToSuperview().inset(16)
        }
        
        ownerIcon.layer.cornerRadius = 40
    }
    
    func config(item: RepositoryItemModel) {
        repositoryNameLabel.text = item.fullName
        descriptionLabel.text = item.description
    }
    
    func configIcon(data: Data?) {
        guard let data = data else {
            self.ownerIcon.image = UIImage(systemName: "questionmark.app")
            return }
        DispatchQueue.main.async {
            self.ownerIcon.image = UIImage(data: data)
        }
    }
}
