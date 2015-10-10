//
//  ViewController.swift
//  testTVOS
//
//  Created by Stephen Casella on 10/10/15.
//  Copyright © 2015 Stephen Casella. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let URL_BASE = "http://api.themoviedb.org/3/movie/popular?api_key=ff743742b3b6c89feb59dfc138b4c12f"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let defaultSize = CGSizeMake(280, 422)
    let focusSize = CGSizeMake(308, 464)
    var movies = [Movie]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        downloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func downloadData() {
        let url = NSURL(string: URL_BASE)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
             (data, response, error) -> Void in
            
            if error != nil {
                print(error.debugDescription)
            } else {
                do { let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? Dictionary<String, AnyObject>
                    
                    if let results = dict!["results"] as? [Dictionary<String, AnyObject>] {
                       
                        for obj in results {
                            let movie = Movie(movieDict: obj)
                            self.movies.append(movie)
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView.reloadData()
                        }
                    }
                    
                    
                } catch {
                    
                }
            }
        }
        
        task.resume()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as? MovieCell {
            
            let movie = movies[indexPath.row]
            cell.configureCell(movie)
            
            if cell.gestureRecognizers?.count == nil {
                let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                cell.addGestureRecognizer(tap)
            }
            
            return cell
            
        } else {
            
            return MovieCell()
        }
        
        return UICollectionViewCell()
    }
    
    
    
    func tapped(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? MovieCell {
            print("load next view controller")
        }
    }

    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(343, 535)
    }
    
    
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if let prev = context.previouslyFocusedView as? MovieCell {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                prev.movieImg.frame.size = self.defaultSize
            })
        }
        
        if let next = context.nextFocusedView as? MovieCell {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                next.movieImg.frame.size = self.focusSize
            })
        }
    }
    
    
}

