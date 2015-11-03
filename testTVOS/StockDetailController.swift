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
   // var feedTimestampArray = [String]()
    var feedContentArray = [String]()
    
    var timer = NSTimer()
    
    var mappedURL = NSURL(string: "")
    
    //var shouldUpdate = true
    
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
            
        priceLabel.text = ""
        priceChangeLabel.text = ""
        percentChangeLabel.text = ""
        arrowImg.image = nil

        
        segueTicker = sender.text!.uppercaseStringWithLocale(NSLocale.currentLocale())
        
        tickerLabel.text = "\(segueTicker)"
        
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
        
        tickerLabel.text = "\(segueTicker)"
        
        displayChart(0, isLineType: isLineChart)
        
        assignMappedURL()
        
        downloadData()
      
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
        self.downloadDataFeed()
        
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "downloadData", userInfo: nil, repeats: true)
        
        let timer2 = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "downloadDataFeed", userInfo: nil, repeats: true)
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedImageURLArray.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? StockFeedCell {
        
        cell.avatarImage.image = feedImageURLArray[indexPath.row]
        cell.nameLabel.text = feedNameArray[indexPath.row]
        //cell.timestampLabel.text = feedTimestampArray[indexPath.row]
        cell.contentLabel.text = feedContentArray[indexPath.row]
        
            return cell
                
        }
        
        return StockFeedCell()
    }
    
    
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if let prev = context.previouslyFocusedView as? StockFeedCell {
            prev.nameLabel.textColor = UIColor.whiteColor()
             prev.contentLabel.textColor = UIColor.whiteColor()
             //prev.timestampLabel.textColor = UIColor.whiteColor()
        }
        
        if let next = context.nextFocusedView as? StockFeedCell {
            next.nameLabel.textColor = UIColor.blackColor()
            next.contentLabel.textColor = UIColor.blackColor()
            //next.timestampLabel.textColor = UIColor.blackColor()
        }
        
        
    }

    
    
    func downloadDataFeed() {
        
        
        self.feedNameArray.removeAll()
        self.feedContentArray.removeAll()
        // self.feedTimestampArray.removeAll()
        self.feedImageURLArray.removeAll()
        
      //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //  let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            //let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            //dispatch_async(backgroundQueue, {
            
            let mappedURL = NSURL(string: "https://api.stocktwits.com/api/2/streams/symbol/\(segueTicker).json")
            
            if let data = NSData(contentsOfURL: mappedURL!) {
        
            
            do { let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
               
                if let items = jsonData!["messages"] as? NSArray {
                    
                    for item in items {
                        
                        let body = (item["body"]! as! String).stringByReplacingOccurrencesOfString("&#39;", withString: "'").stringByReplacingOccurrencesOfString("&quot;", withString: "'").stringByReplacingOccurrencesOfString("&amp;", withString: "&")
                        
                        self.feedContentArray.append(body)
                        
                        //let rawVal = (item["created_at"]! as! String).componentsSeparatedByString("T")
                        
                        //let formattedVal = rawVal[1]
                        
                       // let finalVal = formattedVal.stringByReplacingOccurrencesOfString("Z", withString: "")
                        
                       // self.feedTimestampArray.append(finalVal)
                        
                        let image = item["user"]!!["avatar_url_ssl"]!
                        
                        let smallData = NSData(contentsOfURL: NSURL(string: "\(image!)")!)
                  
                       // if smallData != nil {
                        
                            self.feedImageURLArray.append(UIImage(data: smallData!)!)
                            
                       // } else {
                           
                           // self.feedImageURLArray.append(UIImage(named: "")!)
                        //}
                            
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
            
      //  }
        
        
    }
    
    
    
    func displayChart(time: Int, isLineType: Bool) {
        
    if isLineType == true {
        
        if time == 0 {
            
            let time = "1d"
            
            let type = "l"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(segueTicker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else if time == 1 {
            
            let time = "1y"
            
            let type = "l"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(segueTicker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else if time == 2 {
            
            let time = "5y"
            
            let type = "l"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(segueTicker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else {
            
            let time = "my"
            
            let type = "l"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(segueTicker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        }
            
        } else {
        
       
        if time == 0 {
            
            let time = "1d"
            
            let type = "c"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(segueTicker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else if time == 1 {
            
            let time = "1y"
            
            let type = "c"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(segueTicker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else if time == 2 {
            
            let time = "5y"
            
            let type = "c"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(segueTicker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
        } else {
            
            let time = "my"
            
            let type = "c"
            
            let data = NSData(contentsOfURL: NSURL(string: "http://chart.finance.yahoo.com/z?s=\(segueTicker)&t=\(time)&q=\(type)&l=on&z=l")!)
            
            self.chartImg.image = UIImage(data: data!)
            
            
    }
        }
            }
    
    
    
  /* func update() {
        if shouldUpdate == true {
            downloadData()
        }
   } */
    
    
    
    func assignMappedURL() {

        let mappedURLString = "https://api.import.io/store/data/383a210c-0f39-477c-9c73-40717af1ba8b/_query?input/input=" + segueTicker + "%2C%20afb&_user=269d78c6-495d-43df-899d-47320fc07fe4&_apikey=269d78c6495d43df899d47320fc07fe4886fa6efe4d7561df8557e1696cb76a1fef8f22d1807eda04e3cf5335799c8a1920d4d62f0801e9f5ecdb4b5901f7f4f5fa653f59f1b71fe22582aea9acc9f69"
        
        mappedURL = NSURL(string: mappedURLString)
    }
    
    
    
    func downloadData() {
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
        
            //self.shouldUpdate = false
            
             if let data = NSData(contentsOfURL: self.mappedURL!) {
            
            do { let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                if let items = jsonData!["results"] as? NSArray {
                    
                    if items.count < 1 {
                        
                        self.timer.invalidate()
                        let alert = UIAlertController(title: "Error", message: "Please check ticker symbol", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil) } else {
                    
                    
                        let price = items[0]["price"]!
                        //self.priceLabel.text = "\(price!)"
                        
                        let priceChange = items[0]["amt_change"]!
                        //self.priceChangeLabel.text = "\(priceChange!)"
                        
                        let percentChange = items[0]["percent_change"]!
                        //self.percentChangeLabel.text = "\(percentChange!)"
                        
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.priceLabel.text = "$\(price!)"
                            self.priceChangeLabel.text = "\(priceChange!)"
                            self.percentChangeLabel.text = "\(percentChange!)"
                
                        if Float(items[0]["amt_change"]! as! String) < 0.0 {
                            self.priceChangeLabel.textColor = UIColor(red:0.93, green:0.29, blue:0.29, alpha:1.0)
                            self.percentChangeLabel.textColor = UIColor(red:0.93, green:0.29, blue:0.29, alpha:1.0)
                            self.arrowImg.image = UIImage(named: "redTri3.png")
                        } else {
                            self.priceChangeLabel.textColor = UIColor(red:0.07, green:0.73, blue:0.60, alpha:1.0)
                            self.percentChangeLabel.textColor = UIColor(red:0.07, green:0.73, blue:0.60, alpha:1.0)
                            self.arrowImg.image = UIImage(named: "greenTri2.png")
                           // self.shouldUpdate = true
                        }
                         // print("others")
                        }

                         }
                
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
         }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        timer.invalidate()
    }
    
    
}