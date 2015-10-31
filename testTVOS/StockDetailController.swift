//
//  StockDetailController.swift
//  LiveStocks
//
//  Created by Stephen Casella on 10/29/15.
//  Copyright © 2015 Stephen Casella. All rights reserved.
//

import UIKit

class StockDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var feedNameArray = [String]()
    var feedImageURLArray = [UIImage]()
    var feedTimestampArray = [String]()
    var feedContentArray = [String]()
    
    var ticker = segueTicker
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chartImg: UIImageView!
    
    

    @IBAction func timeButtonChange(sender: UIButton) {
          displayChart(Int(sender.restorationIdentifier!)!, isLineType: false)
    }
 
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayChart(0, isLineType: false)
        
        downloadData()
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedNameArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? StockFeedCell {
        
        cell.avatarImage.image = feedImageURLArray[indexPath.row]
        cell.nameLabel.text = feedNameArray[indexPath.row]
        cell.timestampLabel.text = feedTimestampArray[indexPath.row]
        cell.contentLabel.text = feedContentArray[indexPath.row]
        
            return cell
                
        }
        
        return StockFeedCell()
    }
    
    
    
    func downloadData() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //  let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            //let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            //dispatch_async(backgroundQueue, {
            
            let mappedURL = NSURL(string: "https://api.stocktwits.com/api/2/streams/symbol/\(self.ticker).json")
            
            let data = NSData(contentsOfURL: mappedURL!)
            
            do { let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                if let items = jsonData["messages"] as? NSArray {
                    
                    self.feedNameArray.removeAll()
                    self.feedContentArray.removeAll()
                    self.feedTimestampArray.removeAll()
                    self.feedImageURLArray.removeAll()
                    
                    for item in items {
                        
                        let body = item["body"]!
                            
                        self.feedContentArray.append(body as! String)
                        //NSUserDefaults.standardUserDefaults().setObject(tickerTable, forKey: "tickerTable")
                        
                        
                        let timestamp = item["created_at"]!
                        
                        self.feedTimestampArray.append(timestamp as! String)
                        //NSUserDefaults.standardUserDefaults().setObject(priceArray, forKey: "priceArray")
                        
                        
                        let image = item["user"]!!["avatar_url_ssl"]!
                        
                        let smallData = NSData(contentsOfURL: NSURL(string: "\(image!)")!)
                  
                        self.feedImageURLArray.append(UIImage(data: smallData!)!)
                        //NSUserDefaults.standardUserDefaults().setObject(changeArray, forKey: "changeArray")
                        
                        let username = item["user"]!!["username"]!
                        
                        self.feedNameArray.append(username as! String)
                        //NSUserDefaults.standardUserDefaults().setObject(percentChangeArray, forKey: "percentChangeArray")
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        
                        self.tableView.reloadData()
                       
                        
                    }
                    
                }
                
                
                
            } catch {
                
                print("not a dictionary")
                
            }
            
            // })
            
            //})
        }
        
        
        
    }
    
    
    
    func displayChart(time: Int, isLineType: Bool) {
        
    if isLineType == true {
        
        if time == 0 {
            
            let time = "1d"
            
            let type = "l"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(ticker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else if time == 1 {
            
            let time = "1y"
            
            let type = "l"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(ticker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else if time == 2 {
            
            let time = "5y"
            
            let type = "l"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(ticker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else {
            
            let time = "my"
            
            let type = "l"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(ticker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        }
            
        } else {
        
       
        if time == 0 {
            
            let time = "1d"
            
            let type = "c"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(ticker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else if time == 1 {
            
            let time = "1y"
            
            let type = "c"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(ticker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else if time == 2 {
            
            let time = "5y"
            
            let type = "c"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(ticker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else {
            
            let time = "my"
            
            let type = "c"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(ticker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
    }
        }
            }

    
}
