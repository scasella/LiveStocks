//
//  MovieCell.swift
//  testTVOS
//
//  Created by Stephen Casella on 10/10/15.
//  Copyright © 2015 Stephen Casella. All rights reserved.
//

import UIKit

class StockCell: UICollectionViewCell {
    
    
    @IBOutlet weak var ticker: UILabel!
    
    @IBOutlet weak var price: UILabel!
   
    @IBOutlet weak var priceChange: UILabel!

    @IBOutlet weak var percentageChange: UILabel!

    @IBOutlet weak var arrowImg: UIImageView!
    

}
