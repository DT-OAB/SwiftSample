//
//  NewsSourceDetailViewController.swift
//  News
//
//  Created by Brendan GUEGAN on 11/10/16.
//  Copyright © 2016 OAB. All rights reserved.
//

import UIKit

class NewsSourceDetailViewController: UIViewController {

    var manager: BusinessManager? {
        didSet {
            update()
        }
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var articlesTableView: UITableView!
    
    var newsSource: NewsSource? {
        didSet {
            update()
        }
    }
    
    var articles = [Article]()
    
    private func update() {
        guard let newsSource = newsSource else { return }
        name?.text = newsSource.name
        category?.text = newsSource.category.rawValue
        language?.text = newsSource.language.rawValue
        descriptionLabel?.text = newsSource.description
        articlesTableView?.reloadData()
        
        
        manager?.getArticles(for: newsSource, sorted: .latest) { [weak self] articles, error in
            guard let sself = self else { return }
            if let error = error {
                print("Error while getting articles: \(error)")
            }
            DispatchQueue.main.sync {
                sself.articles.removeAll()
                if let articles = articles {
                    sself.articles.append(contentsOf: articles)
                }
                if sself.isViewLoaded {
                    sself.articlesTableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NewsSourceDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCellIdentifier", for: indexPath)
        if let cell = cell as? NewsSourceArticleTableViewCell {
            cell.article = articles[indexPath.row]
        }
        return cell
    }
}
