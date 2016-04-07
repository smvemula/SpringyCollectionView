//
//  LoadingCVCell.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/1/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class LoadingCVCell: UICollectionViewCell {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var loadMessageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
