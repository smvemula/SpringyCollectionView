//
//  BookCVCell.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/1/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class BookCVCell: UICollectionViewCell {
    
    @IBOutlet var bookTitle: UILabel!
    @IBOutlet var bookCover: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
