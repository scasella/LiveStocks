//
//  StockDetailController.swift
//  LiveStocks
//
//  Created by Stephen Casella on 10/29/15.
//  Copyright © 2015 Stephen Casella. All rights reserved.
//

import UIKit

class StockDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var isLineChart = true
    
    var feedNameArray = [String]()
    var feedImageURLArray = [UIImage]()
    var feedTimestampArray = [String]()
    var feedContentArray = [String]()
    
    var timer = NSTimer()
    
    var ticker = segueTicker
    
    var mappedURL = NSURL(string: "")
    
    var shouldUpdate = true
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chartImg: UIImageView!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var percentChangeLabel: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    
    @IBAction func changeToCandle(sender: UIButton) {
        isLineChart = false
        NSUserDefaults.standardUserDefaults().setObject(isLineChart, forKey: "isLineChart")
        displayChart(0, isLineType: isLineChart)
    }
    
    

    @IBAction func changeToLine(sender: UIButton) {
        isLineChart = true
        NSUserDefaults.standardUserDefaults().setObject(isLineChart, forKey: "isLineChart")
        displayChart(0, isLineType: isLineChart)
    }
    
    
    
    @IBAction func timeButtonChange(sender: UIButton) {
          displayChart(Int(sender.restorationIdentifier!)!, isLineType: isLineChart)
    }
 
    
    
    @IBAction func tickerTextSet(sender: UITextField) {
        
        if sender.text != "" {
        
        ticker = sender.text!.uppercaseStringWithLocale(NSLocale.currentLocale())
        
        tickerLabel.text = "\(ticker)"
        
        sender.text = ""
            
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "update", userInfo: nil, repeats: true)

        displayChart(0, isLineType: false)
        
        assignMappedURL()
        
        downloadData()
        
        downloadDataFeed()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissViewControllerAnimated(false) { () -> Void in
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("isLineChart") != nil {
            isLineChart =  NSUserDefaults.standardUserDefaults().objectForKey("isLineChart") as! Bool }
        
        loadingIndicator.startAnimating()
        
        tickerLabel.text = "\(ticker)"
        
        displayChart(0, isLineType: isLineChart)
        
        assignMappedURL()
        
        downloadData()
        
        downloadDataFeed()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "update", userInfo: nil, repeats: true)
        
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
    
    
    
    func downloadDataFeed() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //  let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            //let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            //dispatch_async(backgroundQueue, {
            
            let mappedURL = NSURL(string: "https://api.stocktwits.com/api/2/streams/symbol/\(self.ticker).json")
            
            if let data = NSData(contentsOfURL: mappedURL!) {
        
            
            do { let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
               
                if let items = jsonData!["messages"] as? NSArray {
                    
                    self.feedNameArray.removeAll()
                    self.feedContentArray.removeAll()
                    self.feedTimestampArray.removeAll()
                    self.feedImageURLArray.removeAll()
                    
                    for item in items {
                        
                        let body = item["body"]!
                            
                        self.feedContentArray.append(body as! String)
                        
                        let timestamp = item["created_at"]!
                        
                        self.feedTimestampArray.append(timestamp as! String)
                        
                        
                        let image = item["user"]!!["avatar_url_ssl"]!
                        
                        let smallData = NSData(contentsOfURL: NSURL(string: "\(image!)")!)
                  
                        if smallData != nil {
                        
                            self.feedImageURLArray.append(UIImage(data: smallData!)!)
                            
                        } else {
                           
                            self.feedImageURLArray.append(UIImage(named: "")!)
                        }
                            
                        let username = item["user"]!!["username"]!
                        
                        self.feedNameArray.append(username as! String)
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.loadingIndicator.stopAnimating()
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
    
    
    
    func update() {
        if shouldUpdate == true {
            downloadData()
        }
    }
    
    
    
    func assignMappedURL() {

        let mappedURLString = "https://api.import.io/store/data/7e762568-91f9-4433-976d-6061072ad558/_query?input/input=" + ticker + "&_user=269d78c6-495d-43df-899d-47320fc07fe4&_apikey=269d78c6495d43df899d47320fc07fe4886fa6efe4d7561df8557e1696cb76a1fef8f22d1807eda04e3cf5335799c8a1920d4d62f0801e9f5ecdb4b5901f7f4f5fa653f59f1b71fe22582aea9acc9f69"
        
        mappedURL = NSURL(string: mappedURLString)
    }
    
    
    
    func downloadData() {
        
      // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
        
            self.shouldUpdate = false
            
             if let data = NSData(contentsOfURL: self.mappedURL!) {
            
            do { let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                if let items = jsonData!["results"] as? NSArray {
                    
                    for item in items {
                        
                        let price = item["price"]!
                        
                        self.priceLabel.text = "\(price!)"
                
                        
                        let priceChange = item["amount_change"]! as! String
                        
                        self.priceChangeLabel.text = "\(priceChange)"
                       
                        
                        let percentChange = item["percent_change"]!
                        
                        self.percentChangeLabel.text = "\(percentChange!)"
                        
                        if Int(priceChange) < 0 {
                            self.priceChangeLabel.textColor = UIColor.redColor()
                            self.percentChangeLabel.textColor = UIColor.redColor()
                            self.arrowImg.image = UIImage(named: "redTri3.png")
                        } else {
                            self.priceChangeLabel.textColor = UIColor.greenColor()
                            self.percentChangeLabel.textColor = UIColor.greenColor()
                            self.arrowImg.image = UIImage(named: "greenTri2.png")
                        }
                    }
                        if items.count < 1 {
                            
                            self.timer.invalidate()
                            let alert = UIAlertController(title: "Error", message: "Please check ticker symbol", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        
                
                
                    }
                    
                   /* dispatch_async(dispatch_get_main_queue()) {
                        
                        
                        
                    } */
                }
                
            } catch {
                
                print("not a dictionary")
            }
        
             } else {
                self.timer.invalidate()
                let alert = UIAlertController(title: "Error", message: "Please check ticker symbol", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)

            }
   //     }
    }
    
    
    
}