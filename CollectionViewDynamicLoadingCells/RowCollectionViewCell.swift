//
//  RowCollectionViewCell.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/1/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class RowCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var booksRow: UICollectionView!
    @IBOutlet var title: UILabel!
    
    var row: Row! {
        didSet {
            self.title.text = row.title
            self.booksRow.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.booksRow.decelerationRate = UIScrollViewDecelerationRateFast
        self.booksRow.registerNib(UINib(nibName: "BookCVCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        if let customFlowLayout = self.booksRow.collectionViewLayout as? THSpringyFlowLayout {
            customFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        }
    }

}

extension RowCollectionViewCell {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var  cell: BookCVCell? = collectionView.dequeueReusableCellWithReuseIdentifier ("cell",
                                                                                                   forIndexPath:indexPath) as? BookCVCell
        
        if (cell == nil)
        {
            let nib:Array = NSBundle.mainBundle().loadNibNamed("BookCVCell", owner: self, options: nil)
            cell = nib[0] as? BookCVCell
        }
        
        cell?.book = self.row.books[indexPath.row]
        cell?.bookCover.backgroundColor = self.getRandomColor()
        
        return cell!
    }
    
    
    func getRandomColor() -> UIColor{
    
    let randomRed:CGFloat = CGFloat(drand48())
    
    let randomGreen:CGFloat = CGFloat(drand48())
    
    let randomBlue:CGFloat = CGFloat(drand48())
    
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    
    }
    
    func collectionView(collectionView : UICollectionView,layout  collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        return CGSizeMake(112*0.75 + 10, 112)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.row.books.count
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            
        var yOffset = targetContentOffset.memory.y > scrollView.contentOffset.y ? targetContentOffset.memory.y - scrollView.contentOffset.y : scrollView.contentOffset.y - targetContentOffset.memory.y
        yOffset = targetContentOffset.memory.y > scrollView.contentOffset.y ? targetContentOffset.memory.y - yOffset*0.5 : targetContentOffset.memory.y + yOffset*0.5
        
        //print("target offset \(targetContentOffset.memory.y), contentOffset: \(scrollView.contentOffset.y), NEW contentOffset: \(yOffset)")
        
        if yOffset < scrollView.contentSize.height - scrollView.frame.size.height {
            
            //Tell the scroll view to land on our page
            targetContentOffset.memory.y = yOffset
        }
    }
}
