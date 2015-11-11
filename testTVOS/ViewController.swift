//
//  ViewController.swift
//  testTVOS
//
//  Created by Stephen Casella on 10/10/15.
//  Copyright © 2015 Stephen Casella. All rights reserved.
//

import UIKit

var segueTicker = ""

var tickerArray = ["AAPL"]

var tickerTable = [String]()

var priceArray = [Float]()

var changeArray = [Float]()

var percentChangeArray = [String]()


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var mappedURL = NSURL(string: "")
    
    //var shouldUpdate = true
    
    var timer = NSTimer()
    
    @IBOutlet weak var stocksButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    let defaultSize = CGSizeMake(421, 162)
    let focusSize = CGSizeMake(471, 212)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    

    override func viewWillAppear(animated: Bool) {
        
        tickerTable.removeAll()
        priceArray.removeAll()
        changeArray.removeAll()
        percentChangeArray.removeAll()
        
        if NSUserDefaults.standardUserDefaults().objectForKey("tickerArray") != nil {
            tickerArray = NSUserDefaults.standardUserDefaults().objectForKey("tickerArray") as! [String]
        }
        
        collectionView.reloadData()
        collectionView.reloadInputViews()
        stocksButton.preferredFocusedView
        
        if tickerArray.count != 0 {
            
        emptyLabel.hidden = true
        loadingIndicator.startAnimating()
        
        assignMappedURL()
  
        downloadData()
        // Do any additional setup after loading the view, typically from a nib.
        
         timer = NSTimer.scheduledTimerWithTimeInterval(6.0, target: self, selector: "downloadData", userInfo: nil, repeats: true)
        } else {
            emptyLabel.hidden = false
        }
        
    }
    
    
   /* func update() {
        if shouldUpdate == true {
            downloadData()
        }
    }*/
    
    
    
    func downloadData() {
        
  //  shouldUpdate = false
        
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
      //  let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        //let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        //dispatch_async(backgroundQueue, {
    
    
  
                        if let data = NSData(contentsOfURL: self.mappedURL!) {
    
                        do { let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                            
                            
                            if let items = jsonData!["results"] as? NSArray {
                                
                                if items.count < 1 {
                                    
                                    self.timer.invalidate()
                                    let alert = UIAlertController(title: "Error", message: "Please check ticker symbol or internet connection", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                } else {
                                
                                   tickerTable.removeAll()
                                    priceArray.removeAll()
                                    changeArray.removeAll()
                                    percentChangeArray.removeAll()
                                
                                if tickerArray.count == 1 {
                                    
                                    let ticker = items[0]["symbol"]!
                                    tickerTable.append(ticker as! String)
                                    
                                    let price = items[0]["price"]!
                                    priceArray.append(price as! Float)
                                    
                                    let priceChange = items[0]["amt_change"]!
                                    changeArray.append(Float(priceChange as! String)!)
                                    
                                    let percentChange = items[0]["percent_change"]!
                                    percentChangeArray.append(percentChange as! String)

                                    } else {
                                
                                for item in items {
                                    
                                    let ticker = item["symbol"]!
                                    tickerTable.append(ticker as! String)
                                    
                                    let price = item["price"]!
                                    priceArray.append(price as! Float)
                                  
                                    let priceChange = item["amt_change"]!
                                    changeArray.append(Float(priceChange as! String)!)
                                   
                                    let percentChange = item["percent_change"]!
                                    percentChangeArray.append(percentChange as! String)
                                    
                                }
                                
                                }
                                }
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.loadingIndicator.stopAnimating()
                                        self.collectionView.reloadData()
                                        //self.shouldUpdate = true
                                        
                                        
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

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as? StockCell {
           
            cell.ticker.text = tickerTable[indexPath.row]
            cell.price.text = "\(priceArray[indexPath.row])"
            cell.priceChange.text = "\(changeArray [indexPath.row])"
            cell.percentageChange.text = percentChangeArray[indexPath.row]
            
            
            if changeArray[indexPath.row] < 0.0 {
                
                cell.priceChange.textColor = UIColor(red:0.93, green:0.29, blue:0.29, alpha:1.0)
                cell.percentageChange.textColor = UIColor(red:0.93, green:0.29, blue:0.29, alpha:1.0)

                cell.arrowImg.image = UIImage(named: "redTri3.png")
                
            } else if changeArray[indexPath.row] > 0 {
                
                cell.priceChange.textColor = UIColor(red:0.07, green:0.73, blue:0.60, alpha:1.0)
                cell.percentageChange.textColor = UIColor(red:0.07, green:0.73, blue:0.60, alpha:1.0)
                
                cell.arrowImg.image = UIImage(named: "greenTri2.png")
                
            } else {
                
                cell.priceChange.textColor = UIColor.blackColor()
                cell.percentageChange.textColor = UIColor.blackColor()
                
                cell.arrowImg.image = nil
                
                
            }
        
            if cell.gestureRecognizers?.count == nil {
                let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                cell.addGestureRecognizer(tap)
            }
            
            
            return cell
            
        } else {
            
            return StockCell()
        }
    
    }
    
    
    
    func tapped(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? StockCell {
           segueTicker = cell.ticker.text!
           performSegueWithIdentifier("detailSegue", sender: self)
        }
    }

    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickerTable.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(480, 225)
    }
    

    
       /* override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
   if let prev = context.previouslyFocusedView as? StockCell {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                prev.view.frame.size = self.defaultSize
            })
        }
        
          if let next = context.nextFocusedView as? StockCell {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                next.view.frame.size = self.focusSize
            })
        }
    }*/
    
    
    
    func assignMappedURL() {
        
        if tickerArray.count == 1 {
            
        let mappedURLString = "https://api.import.io/store/data/2df912a7-82b9-41a9-b1a6-97b0a078e4fb/_query?input/input=" + tickerArray[0] + "%2C%20afb&_user=269d78c6-495d-43df-899d-47320fc07fe4&_apikey=269d78c6495d43df899d47320fc07fe4886fa6efe4d7561df8557e1696cb76a1fef8f22d1807eda04e3cf5335799c8a1920d4d62f0801e9f5ecdb4b5901f7f4f5fa653f59f1b71fe22582aea9acc9f69"
            
         mappedURL = NSURL(string: mappedURLString)
            
        } else {
        
        let percentScreen = "%2C%20"
        
        var urlText = ""
        
        var counter = 0
        
        for x in tickerArray {
            
            if counter == 0 {
                urlText =  "\(x)"
                counter++
                
            } else {
                
                urlText = "\(urlText)" + "\(percentScreen)" + "\(x)"
                
            }
        }
        
        //Format URL for API, call API, return summary to summaryArray
        let encodedURL = urlText
        /*.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!*/
        
        let mappedURLString = "https://api.import.io/store/data/383a210c-0f39-477c-9c73-40717af1ba8b/_query?input/input=" + encodedURL + "&_user=269d78c6-495d-43df-899d-47320fc07fe4&_apikey=269d78c6495d43df899d47320fc07fe4886fa6efe4d7561df8557e1696cb76a1fef8f22d1807eda04e3cf5335799c8a1920d4d62f0801e9f5ecdb4b5901f7f4f5fa653f59f1b71fe22582aea9acc9f69"
        
        mappedURL = NSURL(string: mappedURLString)
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        timer.invalidate()
    }
    
}

