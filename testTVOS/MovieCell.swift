//
//  MovieCell.swift
//  testTVOS
//
//  Created by Stephen Casella on 10/10/15.
//  Copyright © 2015 Stephen Casella. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var movieLbl: UILabel!
    
    func configureCell(movie: Movie) {
        if let title = movie.title {
            movieLbl.text = title
        }
        
        if let path = movie.posterPath {
            
            let url = NSURL(string: path)!
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
               
                let data = NSData(contentsOfURL: url)!
                
                    dispatch_async(dispatch_get_main_queue()) {
                        let img = UIImage(data: data)
                        self.movieImg.image = img
                }
                
            }
        }
    }

}
