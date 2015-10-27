//
//  ViewController.swift
//  testTVOS
//
//  Created by Stephen Casella on 10/10/15.
//  Copyright © 2015 Stephen Casella. All rights reserved.
//

import UIKit


var tickerArray = ["AAPL","GOOGL","KO","YHOO","BABA","AMZN","PEP","FXI","UUP","GLD","SLV","SPY"]

var tickerTable = [String]()

var priceArray = [Float]()

var changeArray = [Float]()

var percentChangeArray = [String]()


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var mappedURL = NSURL(string: "")
    
   var shouldUpdate = true
    
    @IBOutlet weak var stocksButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let defaultSize = CGSizeMake(421, 162)
    let focusSize = CGSizeMake(471, 212)
    var movies = [Movie]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        assignMappedURL()
  
        downloadData()
        // Do any additional setup after loading the view, typically from a nib.
        
         let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
        
      stocksButton.preferredFocusedView
        
    }
    
    
    
    func update() {
        if shouldUpdate == true {
            downloadData()
        }
    }
    
    
    
    func downloadData() {
        
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      //  let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        //let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        //dispatch_async(backgroundQueue, {
          self.shouldUpdate = false
    
                    let data = NSData(contentsOfURL: self.mappedURL!)
                        
                        do { let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            
                            if let items = jsonData["results"] as? NSArray {
                                
                                tickerTable.removeAll()
                                priceArray.removeAll()
                                changeArray.removeAll()
                                percentChangeArray.removeAll()
                                
                                for item in items {
                                    
                                    let ticker = item["symbol"]!
                                    
                                    tickerTable.append(ticker as! String)
                                    //NSUserDefaults.standardUserDefaults().setObject(tickerTable, forKey: "tickerTable")
                                    
                                    
                                    let price = item["price"]!
                                
                                    priceArray.append(price as! Float)
                                    //NSUserDefaults.standardUserDefaults().setObject(priceArray, forKey: "priceArray")
                                    
                                    
                                    let priceChange = item["amt_change"]!
                                    
                                    changeArray.append(Float(priceChange as! String)!)
                                    //NSUserDefaults.standardUserDefaults().setObject(changeArray, forKey: "changeArray")

                                    let percentChange = item["percent_change"]!
                                 
                                    percentChangeArray.append(percentChange as! String)
                                    //NSUserDefaults.standardUserDefaults().setObject(percentChangeArray, forKey: "percentChangeArray")
                                    
                                   
                                    
                                 
                                }
                                
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            
                                self.collectionView.reloadData()
                                self.collectionView.reloadInputViews()
                                   self.shouldUpdate = true
                                
                                }
                                
                            }
                
                       
                         
                        } catch {
                            
                            print("not a dictionary")
                            
                        }

               // })
    
        //})
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
        if let _ = gesture.view as? StockCell {
            print("load next view controller")
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
    

    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
       /* if let prev = context.previouslyFocusedView as? MovieCell {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                prev.movieImg.frame.size = self.defaultSize
            })
        }
        
          if let next = context.nextFocusedView as? MovieCell {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                next.movieImg.frame.size = self.focusSize
            })
        }*/
    }
    
    
    
    func assignMappedURL() {
        
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

