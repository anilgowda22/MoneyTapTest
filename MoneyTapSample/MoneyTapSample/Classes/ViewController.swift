//
//  ViewController.swift
//  MoneyTapSample
//
//  Created by Batman on 25/06/18.
//  Copyright © 2018 AnilKumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableViewWikiList: UITableView!
    @IBOutlet weak var searchBarObject: UISearchBar!
    @IBOutlet weak var warningLabel: UILabel!

    var wikiListArray = [AnyObject]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewWikiList.isHidden = true
        self.warningLabel.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    @objc func didReceiveWikiResponse (responseModel : NetworkResponseModel) {
        if responseModel.status == true && responseModel.error == nil && responseModel.responseData != nil {
            if let userInfoDict = responseModel.responseData as? Dictionary <String, Any>  {

       //-------------- Parsing JSON using Decoder------------//
//                if let userInfoDict = responseModel.data  {
//                    let response = try! JSONDecoder().decode(WikiResponse.self, from: userInfoDict)
//                    print(response)
//                }

                if let pages = userInfoDict["query"] {
                    let result = (pages as! [String : AnyObject])
                    wikiListArray = result["pages"] as! [AnyObject]

                    self.tableViewWikiList.isHidden = false
                    self.warningLabel.isHidden = true
                    self.tableViewWikiList.delegate = self
                    self.tableViewWikiList.dataSource = self
                    self.tableViewWikiList.reloadData()
                } else {
                    let alert = UIAlertController(title: "Error", message: "Please enter valid text", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
//                    warningLabel.text = "No search found"
                }
            }
        }
    }
}

//MARK: - TableView
extension ViewController :UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return wikiListArray.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : MTWikiListTableViewCell = tableView .dequeueReusableCell(withIdentifier: "MTWikiListTableViewCell") as! MTWikiListTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        let pagesData : Dictionary <String, Any> = wikiListArray[indexPath.row] as! Dictionary <String, Any>

        if let tempThumbNailDict : Dictionary <String, Any> = pagesData["thumbnail"] as? Dictionary<String, Any>  {
            if let tempSourceStr = tempThumbNailDict["source"] {
                cell.thumbNailImageView.image = UIImage.init(url: URL.init(string: tempSourceStr as! String))
            }
        }
        if let tempTermsDict : Dictionary <String, Any> = pagesData["terms"] as? Dictionary<String, Any>  {
            if let tempDescriptionStr : [String] = tempTermsDict["description"] as? [String] {
                cell.subHeadLineLabel.text = tempDescriptionStr[0]
            }
        }
        cell.headLineLabel.text = pagesData["title"] as? String

        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let pagesData : Dictionary <String, Any> = wikiListArray[indexPath.row] as! Dictionary <String, Any>

        let wikiPageViewController = MTWikiPageViewController.storyboardInstance()
        wikiPageViewController?.titleString = (pagesData["title"] as? String)!
        self.navigationController?.pushViewController(wikiPageViewController!, animated: true)
    }
}
//MARK: - SearchBar
extension ViewController : UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()

        let searchBarText =  searchBar.text ?? "+"
        let finalText =  searchBarText.replacingOccurrences(of: " ", with: "+")

        let requestData = NetworkRequestModel()
        requestData.url = "\(Contants.WebServices.contentUrl)\(finalText)&gpslimit=10"
        requestData.requestType = RequestType.GET
        requestData.headerField = .json
        requestData.requestParam = nil
        NetworkOperation.callWebserviceWith(requestModel: requestData, target: self, callBack: #selector(self.didReceiveWikiResponse(responseModel:)))
    }
}

//MARK: - StoresViewController Storyboard Intializer.

extension MTWikiPageViewController
{
    static func storyboardInstance() -> MTWikiPageViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "MTWikiPageViewController") as? MTWikiPageViewController
    }
}

//MARK: - FETCHING IMAGE
extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }

        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}

struct WikiResponse : Decodable {
    let batchcomplete     : Int
    let query    : DataQuery
}

struct DataQuery : Decodable{
    let pages : [DataWithPages]
    let redirects : [DataWithRedirects]
    init(from decoder: Decoder) throws {
        self.pages = []
        self.redirects = []
    }
}

struct DataWithRedirects : Decodable {
    let from    : NSString?
    let index  : NSInteger?
    let to    : NSString?
    init(from decoder: Decoder) throws {
        self.from = ""
        self.index = nil
        self.to = ""
    }
}


struct DataWithPages : Decodable {
    let ns    : Int?
    let index  : Int?
    let pageid    : Int?
    let terms    : DateWithTerms?
    let thumbnail  : DataWithThumbNail?
    let title    : NSString?
    init(from decoder: Decoder) throws {
        self.ns = nil
        self.index = nil
        self.pageid = nil
        self.title = ""
        self.terms = nil
        self.thumbnail = nil
    }
}

struct DataWithThumbNail : Decodable {
    let height    : Int?
    let source  : String?
    let width    : Int?
}

struct DateWithTerms {
    let description = [String].self
}

//  performSegue(withIdentifier: Constants.SegueID.loginToHome, sender: self)
//                let storeView = VSLStoresViewController.storyboardInstance()
//                self.navigationController?.pushViewController(storeView!, animated: true)
