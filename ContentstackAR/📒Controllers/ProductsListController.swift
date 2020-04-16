//
//  ProductsListController.swift
//  ContentstackAR
//
//  Created by Uttam Ukkoji on 19/06/18.
//  Copyright © 2018 Contentstack. All rights reserved.
//

import UIKit
import Contentstack
import QuickLook
class ProductsListController: UITableViewController {

    var productList = [Any]()
    var sourceView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(ProductsListController.loadData), for: UIControl.Event.valueChanged)
        self.loadData()
        // Do any additional setup after loading the view.
    }
    
    @objc func loadData()  {
        self.refreshControl?.beginRefreshing()
        APIManager.fetchProducts📦🎁💼 {[weak self] (products) in
            guard let slf = self else {return}
            DispatchQueue.main.async {
                slf.refreshControl?.endRefreshing()
                slf.productList = products
                slf.tableView.reloadData()
            }
        }
    }
}

extension ProductsListController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "productCellIdentifier", for: indexPath)
        if let product : Entry = self.productList[indexPath.row] as? Entry {
            productCell.textLabel?.text = product.title
        }
        return productCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let product : Entry = self.productList[indexPath.row] as? Entry {
            let modelAsset = product.asset(forKey: "model")
                print(modelAsset)
            if let url = URL(string: modelAsset.url) {
                self.activityIndicator.center = self.view.center
                self.activityIndicator.startAnimating()
                self.activityIndicator.hidesWhenStopped = true
                self.tableView.addSubview(self.activityIndicator)
                self.tableView.isScrollEnabled = false
                APIManager.downloadUSDZfile(url: url) { [weak self] in
                    guard let slf = self else {return}
                    DispatchQueue.main.async {
                        slf.activityIndicator.stopAnimating()
                        slf.tableView.isScrollEnabled = true
                        slf.performSegue(withIdentifier: "showAR", sender: APIManager.pathForDictionary.appendingPathComponent(url.lastPathComponent))
                    }
                }
            }
        }
//        let previewController = QLPreviewController()
//        previewController.dataSource = self
//        previewController.delegate = self
//        self.sourceView = tableView.cellForRow(at: indexPath)!
//        self.present(previewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let arViewController = segue.destination as? ViewController {
            if let modelName = sender as? URL {
                arViewController.modelPath = modelName
            }
        }
    }
    
}

extension ProductsListController : QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
         return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let fileURL = Bundle.main.url(forResource: "art.scnassets/teapot", withExtension: "usdz")!
        return fileURL as QLPreviewItem
    }
    
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        return self.sourceView
    }
}
