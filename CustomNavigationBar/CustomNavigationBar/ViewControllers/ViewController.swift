//
//  ViewController.swift
//  CustomNavigationBar
//
//  Created by Jason Chen on 2019/9/9.
//  Copyright © 2019 Jason Chen. All rights reserved.
//

import UIKit

//
// MARK: - View Controller
//
class ViewController: UIViewController {

    //
    // MARK: - IBOutlets
    //
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var tpLogoImageView: UIImageView!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var bottomHeaderView: UIView!
    @IBOutlet weak var discriptionLabel: UILabel!
    
    //
    // MARK: - Constants
    //
    let maxHeaderHeight: CGFloat = 192
    let minHeaderHeight: CGFloat = 64
    let apiAccess = ApiAccess()
    let countlimitPerPage: Int = 20
    
    //
    // MARK: - Variables And Properties
    //
    var cellHeightsDictionary: [Int: CGFloat] = [:]
    /// The last known the scroll position. Initial is equal to 0.
    var previousScrollOffset: CGFloat = 0
    /// The last known height of the scroll view content. Initial is equal to 0.
    var previousScrollViewHeight: CGFloat = 0
    /// Array initialization of search results
    var searchResults: Plants?
    /// The last known the previous record count. Initial is equal to 0.
    var offset: Int = 0
    var isLoadNextPageing: Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //
    // MARK: - View Controller's life cycle
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 108
        self.tableView.rowHeight = UITableView.automaticDimension
        
        // Start with an initial value for the content size.
        self.previousScrollViewHeight = self.tableView.contentSize.height
        self.discriptionLabel.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        self.getPlants(offset)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var statusBarView: UIView
        if #available(iOS 13.0, *) {
            let tag = 38482458385
            if let statusBar = UIApplication.shared.keyWindow?.viewWithTag(tag) {
                statusBarView = statusBar
            } else {
                let statusBar = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBar.tag = tag
                UIApplication.shared.keyWindow?.addSubview(statusBar)
                statusBarView = statusBar
            }
        } else {
            statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as! UIView
        }
        statusBarView.backgroundColor = UIColor.init(red: 88 / 255, green: 144 / 255, blue: 253 / 255, alpha: 1)
    }
    
    //
    // MARK: - Private Method for API Search
    //
    func getPlants(_ offset: Int) {
        isLoadNextPageing = true
        TPActivityIndicator.showActivityIndicatory(message: "資料更新中...", showIndicator: true)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        apiAccess.getSearchResults(countLimitPerPage: countlimitPerPage, offset: offset) { [weak self] results, errorMessage in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            TPActivityIndicator.removeActivityIndicatory()
            
            if let results = results {
                self?.searchResults = results
                self!.isLoadNextPageing = false
                self!.tableView.reloadData()
            }
            
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
}

//
// MARK: - Table View Data Source
//
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeightsDictionary[indexPath.row] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = cellHeightsDictionary[indexPath.row]
        return height ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: Cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
        
        let plant = self.searchResults?.results[indexPath.row]
        cell.nameLabel.text = plant?.F_Name_Ch
        cell.locationLabel.text = plant?.F_Location ?? ""
        cell.featureLabel.text = plant?.F_Feature
        cell.plantsImageView?.image = UIImage(named: "default.jpg")
        if plant?.F_Pic01_URL?.count ?? 0 > 0 {
            let imageURL = NSURL(string: plant?.F_Pic01_URL ?? "")
            if let imagedData = try? Data(contentsOf: imageURL! as URL) {
                if let image = UIImage(data: imagedData) {
                    DispatchQueue.main.async {
                        cell.plantsImageView?.image = image
                    }
                }
            }
        }

        if self.canAppendData(indexPath) {
            let offset: Int = (self.searchResults?.offset ?? 0) + countlimitPerPage
            self.getPlants(offset)
        }
        return cell
    }
    
    func canAppendData(_ indexPath: IndexPath) -> Bool {
        let amountCount: Int = self.searchResults?.count ?? 0
        let offset: Int = (self.searchResults?.offset ?? 0) + countlimitPerPage
        let currentIndex: Int = indexPath.row
        let recordSetCount: Int = self.searchResults?.results.count ?? 0
        var recordSetIndex: Int = 0
        if recordSetCount > 0 {
            recordSetIndex = recordSetCount - 1
        }
        
        var canAppand = false
        if !isLoadNextPageing && offset < amountCount && currentIndex == recordSetIndex {
            canAppand = true
        }
        return canAppand
    }
}

//
// MARK: - Table View Delegate
//
extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Always update the previous values.
        defer {
            self.previousScrollViewHeight = scrollView.contentSize.height
            self.previousScrollOffset = scrollView.contentOffset.y
        }

        let heightDiff = scrollView.contentSize.height - self.previousScrollViewHeight
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        // If the scroll was caused by the height of the scroll view changing, we want to do nothing.
        guard heightDiff == 0 else {
            return
        }
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        let yPosition: CGFloat = scrollView.contentOffset.y
        let isScrollingDown = scrollDiff > 0 && yPosition > absoluteTop
        let isScrollingUp = scrollDiff < 0 && yPosition < absoluteBottom
        /*
         When we use UITableView.automaticDimension and after reloading the data, the scrollView contentOffset.y value
         will be incorrect. So, when the scrollView contentOffset.y is less than or equal to 8 and the scroll direction
         is scrolling up, we can think of it as scrolling to the top.
         Why use 8? Because we're scrolling the tableView more smoothly.
        */
        let isScrollToTop = yPosition <= 8 && isScrollingUp
        
        if canAnimateHeader(scrollView) {
            if isScrollingDown || isScrollToTop {
                // Calculate new header height.
                var newHeight = self.headerHeightConstraint.constant
                if isScrollingDown {
                    newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
                } else if isScrollingUp {
                    newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
                }
                
                // Header needs to animate.
                if newHeight != self.headerHeightConstraint.constant {
                    self.headerHeightConstraint.constant = newHeight
                    self.updateHeader()
                    self.setScrollPosition(self.previousScrollOffset)
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollview when header is collapsed.
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll.
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minHeaderHeight
        let percentage = openAmount / range
        let reductionPercentage = (percentage * 0.27) + 0.74
        
        var statusBarView: UIView
        if #available(iOS 13.0, *) {
            let tag = 38482458385
            if let statusBar = UIApplication.shared.keyWindow?.viewWithTag(tag) {
                statusBarView = statusBar
            } else {
                let statusBar = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBar.tag = tag
                UIApplication.shared.keyWindow?.addSubview(statusBar)
                statusBarView = statusBar
            }
        } else {
            statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as! UIView
        }
        statusBarView.backgroundColor = UIColor.init(red: 88 / 255,
                                                     green: 144 / 255,
                                                     blue: 253 / 255,
                                                     alpha: reductionPercentage)
        
        self.topImageView.alpha = reductionPercentage
        self.tpLogoImageView.alpha = percentage
        self.departmentLabel.alpha = percentage
        self.discriptionLabel.alpha = (1 - percentage)
    }
}
