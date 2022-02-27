import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxSwiftExt

class HomeViewController: UIViewController {
    // MARK: - Private
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    private let refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = UISearchBar.Style.default
        search.placeholder = "Please enter keyword"
        
        return search
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: String(describing: SearchResultCell.self))
        
        return tableView
    }()
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    func bindViewModel() {
        let dataSource = RxTableViewSectionedReloadDataSource<Section>(
            configureCell: { dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultCell.self), for: indexPath) as? SearchResultCell else {
                    return UITableViewCell()
                }
                
                cell.nameLabel.text = item.name
                
                if let url = URL(string: item.avatarURL) {
                    cell.accountImageView.setImage(url: url)
                }
                
                return cell
            })
        
        viewModel.result.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text)
            .compactMap { $0 }
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .withLatestFrom(searchBar.rx.text)
            .compactMap { $0 }
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom(offset: 40)
            .withLatestFrom(searchBar.rx.text)
            .compactMap { $0 }
            .bind(to: viewModel.triggerNextPage)
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
    func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.titleView = searchBar
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
}
