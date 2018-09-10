//
//  SearchViewController.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/6/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import RxGesture
import RxDataSources

class SearchViewController: UIViewController, BindableType {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var searchTableView: UITableView!
    
    var viewModel: SearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.searchBar.text = ""
    }
    
    fileprivate typealias SuggestSectionModel = SectionModel<String, String>
    fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(
        configureCell: { (dataSource, tableView, indexPath, data) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(for: indexPath) as SearchCell
            cell.selectionStyle = .none
            cell.fillData(history: data)
            return cell
        },
        titleForHeaderInSection: { dataSource, sectionIndex in
            return ""
        }
    )
    
    func configView() {
        //config tableView
        searchTableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
        searchTableView.do {
            $0.estimatedRowHeight = 80
            $0.rowHeight = UITableViewAutomaticDimension
            $0.register(cellType: SearchCell.self)
            $0.register(headerFooterViewType: SearchHeader.self)
            $0.separatorStyle = .none
        }
        searchTableView.rx
            .anyGesture(.swipe([.up, .down]))
            .when(.recognized)
            .subscribe(onNext: { [unowned self] _ in
                self.dismissKeyboard()
            })
            .disposed(by: rx.disposeBag)
    }
    
    func bindViewModel() {
        let input = SearchViewModel.Input(
            loadTrigger: Driver.just(()),
            searchTrigger: searchBar.rx.searchButtonClicked.asDriver() ,
            selectTrigger: searchTableView.rx.itemSelected.asDriverOnErrorJustComplete(),
            keywordTrigger: searchBar.rx.text.orEmpty.asDriver(),
            cancelTrigger: cancelButton.rx.tap.asDriver()
        )
        let output = viewModel.transform(input)
        output.sectionedSuggest
            .map { $0.map { section in
                    SuggestSectionModel(model: section.header, items: section.productList)
                }
            }
            .drive(searchTableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        output.fetchData
            .drive()
            .disposed(by: rx.disposeBag)
        output.loadResult
            .drive()
            .disposed(by: rx.disposeBag)
        output.cancelTriggerResult
            .drive()
            .disposed(by: rx.disposeBag)
        output.toCollectionResult
            .drive()
            .disposed(by: rx.disposeBag)
    }
}

extension SearchViewController: StoryboardSceneBased {
    static let sceneStoryboard = Storyboards.search
}

extension SearchViewController: UITableViewDelegate {
    private struct ConstantData {
        static let sectionHeader = 40
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(ConstantData.sectionHeader)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(SearchHeader.self)
        header?.fillData(sectionName: dataSource.sectionModels[section].model)
        return header
    }
}

extension SearchViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
