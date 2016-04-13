//
//  BookCVCell.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/1/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class BookCVCell: UICollectionViewCell, BookCoverDelegate {
    
    @IBOutlet var bookTitle: UILabel!
    @IBOutlet var bookCover: UIImageView!
    
    var book: Book? {
        didSet {
            if let _ = self.book {
                book!.delegate = self
                book!.isBookVisible = true
                self.bookTitle.text = book!.title
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let exists = self.book {
            exists.isBookVisible = true
        }
    }
    
    func updateCover() {
        dispatch_async(dispatch_get_main_queue(), {
            if let exists = self.book?.imageData {
                self.bookCover.image = UIImage(data: exists)
            }
        })
    }
    
    override func prepareForReuse() {
        if let _ = self.book {
            self.book!.isBookVisible = false
            self.book!.delegate = nil
        }
        self.bookCover.image = nil
    }

}
