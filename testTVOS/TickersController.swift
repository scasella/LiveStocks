//
//  TickersController.swift
//  LiveStocks
//
//  Created by Stephen Casella on 10/31/15.
//  Copyright © 2015 Stephen Casella. All rights reserved.
//

import UIKit

class TickersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    @IBAction func tickerFieldDone(sender: UITextField) {
        if sender.text != "" {
        tickerArray.append(sender.text!.uppercaseStringWithLocale(NSLocale.currentLocale()))
        NSUserDefaults.standardUserDefaults().setObject(tickerArray, forKey: "tickerArray")
        tableView.reloadData()
        sender.text = nil
        }
    }
    
    
    
    override func viewDidLoad() {
        dismissViewControllerAnimated(false) { () -> Void in
        }
    }
    
    
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if let prev = context.previouslyFocusedView as? TickerCell {
            prev.deleteLabel.hidden = true }
        
        if let next = context.nextFocusedView as? TickerCell {
            next.deleteLabel.hidden = false
        }
        
            
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tickerArray.removeAtIndex(indexPath.row)
         NSUserDefaults.standardUserDefaults().setObject(tickerArray, forKey: "tickerArray")
        tableView.reloadData()
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickerArray.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? TickerCell {

            
            cell.label.text = tickerArray[indexPath.row]
            
            return cell
            
        }
        
        return TickerCell()
    }

    

}
