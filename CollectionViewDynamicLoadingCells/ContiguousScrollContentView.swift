//
//  ContiguousScrollContentView.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/19/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class ContiguousScrollContentView: UIView, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var CV1: UICollectionView!
    @IBOutlet var CV2: UICollectionView!
    @IBOutlet var CV3: UICollectionView!
    @IBOutlet var yForCV1: NSLayoutConstraint!
    @IBOutlet var yForCV2: NSLayoutConstraint!
    @IBOutlet var yForCV3: NSLayoutConstraint!
    @IBOutlet var heightForCV1: NSLayoutConstraint!
    
    var collectionViewStack = [UICollectionView]()
    
    var prevCategory: Int?
    var currentCategory: Int = 0
    var nextCategory: Int?
    
    var imagesArray = ["pollination-image","place-value-image","fiction-vs-nonfiction-image","gravity-image","managing-frustration-image","map-skills-image","oceans-image","poetry-image","water-cycle-image"]
    
    //View life cycle methods
    
    func loadInitialData() {
        
        self.addSetUpForCollectionView(self.CV1)
        self.addSetUpForCollectionView(self.CV2)
        self.addSetUpForCollectionView(self.CV3)
        
        self.heightForCV1.constant = self.frame.size.height - 20
        self.yForCV1.constant = 0
        self.yForCV2.constant = self.yForCV1.constant + self.heightForCV1.constant
        self.yForCV3.constant = self.yForCV2.constant + self.heightForCV1.constant
        
        if MyNetwork.instance().categories.count == 0 {
            MyAPIs.getSections({
                self.loadSection({
                    self.collectionViewStack.insert(self.CV1, atIndex: 0)
                    self.collectionViewStack.insert(self.CV2, atIndex: 1)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.stopLoading()
                        self.CV2.reloadData()
                    })
                })
                self.nextCategory = 1
            })
        }
    }
    
    //
    
    func performScrollAnimationToSectionInCollectionView(cv: UICollectionView) {
        cv.scrollRectToVisible(CGRectMake(0, 0, cv.frame.size.width, cv.frame.size.height) , animated: false)
        self.stopLoading()
    }
    
    func performScrollBackAnimationToSectionInCollectionView(cv: UICollectionView) {
        cv.scrollRectToVisible(CGRectMake(0, cv.contentSize.height - (cv.frame.size.height), cv.frame.size.width, cv.frame.size.height) , animated: false)
        self.stopLoading()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.performScrollBackAnimationToSectionInCollectionView(self.collectionViewStack.first!)
        self.collectionViewStack.first!.removeObserver(self, forKeyPath: "contentSize")
    }
    
    let stretchyLayout = StretchyHeaderSpringyCollectionViewLayout()
    let defaultLayout = UICollectionViewFlowLayout()
    
    func addSetUpForCollectionView(cv: UICollectionView) {
        
        // Create a new instance of our stretchy layout and set the
        // default size for our header (for when it's not stretched)
        
        stretchyLayout.headerReferenceSize = CGSizeMake(self.frame.size.width, 200)
        defaultLayout.headerReferenceSize = CGSizeMake(self.frame.size.width, 200)
        //[stretchyLayout setHeaderReferenceSize:[DeviceUtil getSize:CGSizeMake(944, HEADER_HEIGHT) iPhoneSize:CGSizeMake(320, HEADER_HEIGHT_IPHONE)]];
        cv.directionalLockEnabled = false
        stretchyLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        defaultLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        // Set our custom layout & insets
        
        //cv.collectionViewLayout = stretchyLayout
        //cv.collectionViewLayout = defaultLayout
        
        cv.decelerationRate = UIScrollViewDecelerationRateFast
        
        cv.registerNib(UINib(nibName: "RowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        cv.registerNib(UINib(nibName: "CategoryHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "section")
    }

    func updateCategorySelector() {
        self.CV1.hidden = false
        self.CV2.hidden = false
        self.CV3.hidden = false
    }
    
    var loadingNewData = false
    var scrollingToSection = false
    func reachedEndOfSection() -> Bool {
        let current = MyNetwork.instance().categories[self.currentCategory]
        if current.fetchedAllRows {
            return true
        }
        return false
    }
    
    func fullLoadComplete() -> Bool {
        return self.currentCategory + 1 == MyNetwork.instance().categories.count
    }
    
    func getMoreRowsIn(cv: UICollectionView, section: Int) {
        let current = MyNetwork.instance().categories[section]
        if !current.fetchedAllRows {
            MyAPIs.getData(section, completion: {
                if self.currentCategory == section {
                    self.getMoreRowsIn(cv, section: section)
                }
                dispatch_async(dispatch_get_main_queue(), {
                    var indexPathsToLoad = [NSIndexPath]()
                    if current.currentIndex != current.nextIndex {
                        for index in current.currentIndex...current.rows.count - 1 {
                            indexPathsToLoad.append(NSIndexPath(forRow: index, inSection: 0))
                        }
                        current.currentIndex = current.rows.count
                    } else if current.currentIndex < current.rows.count - 1 {
                        current.currentIndex += 1
                        indexPathsToLoad.append(NSIndexPath(forRow: current.currentIndex, inSection: 0))
                    } else if current.currentIndex == current.rows.count - 1 {
                        indexPathsToLoad.append(NSIndexPath(forRow: current.currentIndex, inSection: 0))
                    }
                    if indexPathsToLoad.count > 0 && self.currentCategory == section {
                        cv.insertItemsAtIndexPaths(indexPathsToLoad)
                    }
                })
            })
        } else {
            self.loadingNewData = false
        }
    }
    
    func loadSection(block : ()->()) {
        var cv: UICollectionView
        
        if self.collectionViewStack.count == 0 {
            cv = self.CV1
        } else if self.collectionViewStack.count == 2 {
            cv = self.collectionViewStack[1]
        } else {
            cv = self.collectionViewStack[2]
        }
        
        let current = MyNetwork.instance().categories[self.currentCategory]
        if current.fetchedAllRows {
            self.stopLoading()
            //self.yForCollectionView.constant = 0
            cv.reloadData()
            self.performScrollAnimationToSectionInCollectionView(cv)
            block()
            dispatch_async(dispatch_get_main_queue(), {
                self.scrollingToSection = true
            })
        } else {
            var stoppedLoading = false
            if current.rows.count >= 3 {
                stoppedLoading = true
                block()
            } else {
                self.startLoading()
            }
            MyAPIs.getData(self.currentCategory, completion: {
                let current = MyNetwork.instance().categories[self.currentCategory]
                
                current.currentIndex = current.rows.count
                self.loadingNewData = false
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopLoading()
                    
                    if self.currentCategory == 0 {
                        self.updateCategorySelector()
                        cv.reloadData()
                        self.getMoreRowsIn(cv, section: self.currentCategory)
                        block()
                    } else {
                        cv.reloadData()
                        if !stoppedLoading {
                            block()
                        }
                        self.getMoreRowsIn(cv, section: self.currentCategory)
                    }
                })
            })
        }
    }
    
    func loadNewData(isdownScroll: Bool, section: Int?) {
        self.loadingNewData = true
        self.scrollingToSection = true
        
        if let isJump = section {
            self.currentCategory = isJump
            
            let current = MyNetwork.instance().categories[self.currentCategory]
            if current.rows.count > 0 {
                self.getMoreRowsIn(CV1, section: self.currentCategory)
                self.performScrollAnimationToSectionInCollectionView(CV1)
            } else {
                self.startLoading()
                self.loadSection({})
            }
        } else {
            
            if isdownScroll {
                self.currentCategory += 1
                
                self.loadSection({
                    if self.currentCategory + 1 < MyNetwork.instance().categories.count {
                        self.nextCategory = self.currentCategory + 1
                    } else {
                        self.nextCategory = nil
                    }
                    self.prevCategory = self.currentCategory - 1
                    self.scrollDownAnimation({
                        self.collectionViewStack.last!.reloadData()
                        self.performScrollAnimationToSectionInCollectionView(self.collectionViewStack.last!)
                    })
                })
            } else {
                self.currentCategory -= 1
                self.scrollUpAnimation({
                    if self.currentCategory - 1 >= 0 {
                        self.prevCategory = self.currentCategory - 1
                    } else {
                        self.prevCategory = nil
                    }
                    self.nextCategory = self.currentCategory + 1
                    
                    self.collectionViewStack.first!.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
                    self.collectionViewStack.first!.reloadData()
                })
            }
        }
        
    }
    
    func getBackToNormal(cv: UICollectionView, completion:()->()) {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            cv.alpha = 1.0
            
            }, completion: { (finished:Bool) -> Void in
                completion()
        })
    }
    
    func scrollUpAnimation(completion: ()-> ()) {
        
        var shouldUpdate = true
        
        if self.collectionViewStack[0] == self.CV1 && self.collectionViewStack.count == 3 {
            self.CV3.alpha = 0.0
            self.yForCV1.constant = 0
            self.yForCV2.constant = self.frame.size.height
            if self.currentCategory == 0 {
                self.yForCV3.constant = 2*self.frame.size.height
                self.collectionViewStack.removeLast()
                shouldUpdate = false
            } else {
                self.yForCV3.constant = -self.frame.size.height
            }
        } else if self.collectionViewStack[0] == self.CV2 {
            self.CV1.alpha = 0.0
            self.yForCV1.constant = -self.frame.size.height
            self.yForCV3.constant = self.frame.size.height
            self.yForCV2.constant = 0
        } else {//CV3
            self.CV2.alpha = 0.0
            self.yForCV2.constant = -self.frame.size.height
            self.yForCV1.constant = self.frame.size.height
            self.yForCV3.constant = 0
        }
        
        if shouldUpdate {
            let bottom = self.collectionViewStack.removeLast()
            self.collectionViewStack.insert(bottom, atIndex: 0)
        }
        
        UIView.animateWithDuration(0.5,
                                   animations: { () -> Void in
                                    self.layoutIfNeeded() // Animate from constraints
            }, completion: { (finished:Bool) -> Void in
                self.userInteractionEnabled = true
                self.scrollingToSection = false
                self.CV1.alpha = 1.0
                self.CV2.alpha = 1.0
                self.CV3.alpha = 1.0
                completion()
        })
    }
    
    func scrollDownAnimation(completion: ()-> ()) {
        
        if self.collectionViewStack.count == 2 {
            self.yForCV3.constant = self.frame.size.height
            self.yForCV2.constant = 0
            self.yForCV1.constant = -self.frame.size.height - 20
            self.collectionViewStack.insert(CV3, atIndex: 2)
        } else {
            if self.collectionViewStack[0] == self.CV1 && self.collectionViewStack.count == 3 {
                self.CV1.alpha = 0.0
                self.yForCV1.constant = self.frame.size.height
                self.yForCV3.constant = 0
                self.yForCV2.constant = -self.frame.size.height - 20
            } else if self.collectionViewStack[0] == self.CV2 {
                self.CV2.alpha = 0.0
                self.yForCV1.constant = 0
                self.yForCV3.constant = -self.frame.size.height - 20
                self.yForCV2.constant = self.frame.size.height
            } else {//CV3
                self.CV3.alpha = 0.0
                self.yForCV1.constant = -self.frame.size.height - 20
                self.yForCV3.constant = self.frame.size.height
                self.yForCV2.constant = 0
            }
            let top = self.collectionViewStack.removeAtIndex(0)
            self.collectionViewStack.insert(top, atIndex: 2)
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.layoutIfNeeded() // Animate from constraints
            }, completion: { (finished:Bool) -> Void in
                self.userInteractionEnabled = true
                self.scrollingToSection = false
                self.CV1.alpha = 1.0
                self.CV2.alpha = 1.0
                self.CV3.alpha = 1.0
                completion()
        })
    }
    
    var shouldLoadUp : Bool?
    
}

//MARK: CollectionViewDelegate & Datasource Methods
extension ContiguousScrollContentView {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var  cell: RowCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier ("cell",
                                                                                                   forIndexPath:indexPath) as? RowCollectionViewCell
        
        if (cell == nil)
        {
            let nib:Array = NSBundle.mainBundle().loadNibNamed("RowCollectionViewCell", owner: self, options: nil)
            cell = nib[0] as? RowCollectionViewCell
        }
        
        
        switch collectionView {
        case self.collectionViewStack[0]:
            if self.collectionViewStack.count == 2 {
                cell?.row = MyNetwork.instance().categories[self.currentCategory].rows[indexPath.row]
            } else {
                cell?.row = MyNetwork.instance().categories[self.prevCategory!].rows[indexPath.row]
            }
        case self.collectionViewStack[1]:
            if self.collectionViewStack.count == 2 {
                cell?.row = MyNetwork.instance().categories[self.nextCategory!].rows[indexPath.row]
            } else {
                cell?.row = MyNetwork.instance().categories[self.currentCategory].rows[indexPath.row]
            }
        case self.collectionViewStack[2]:
            cell?.row = MyNetwork.instance().categories[self.nextCategory!].rows[indexPath.row]
        default: break
        }
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            switch collectionView {
            case self.collectionViewStack[0]:
                if let headerView = self.collectionViewStack[0].dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "section", forIndexPath: indexPath) as? CategoryHeaderView {
                    if self.collectionViewStack.count == 2 {
                        headerView.sectionTitle.text = MyNetwork.instance().categories[self.currentCategory].title
                        headerView.image.image = UIImage(named: self.imagesArray[self.currentCategory])
                    } else {
                        headerView.sectionTitle.text = MyNetwork.instance().categories[self.prevCategory!].title
                        headerView.image.image = UIImage(named: self.imagesArray[self.prevCategory!])
                    }
                    
                    return headerView
                }
            case self.collectionViewStack[1]:
                if let headerView = self.collectionViewStack[1].dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "section", forIndexPath: indexPath) as? CategoryHeaderView {
                    if self.collectionViewStack.count == 2 {
                        headerView.sectionTitle.text = MyNetwork.instance().categories[self.nextCategory!].title
                        headerView.image.image = UIImage(named: self.imagesArray[self.nextCategory!])
                    } else {
                        headerView.sectionTitle.text = MyNetwork.instance().categories[self.currentCategory].title
                        headerView.image.image = UIImage(named: self.imagesArray[self.currentCategory])
                    }
                    
                    return headerView
                }
            case self.collectionViewStack[2]:
                if let headerView = self.collectionViewStack[2].dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "section", forIndexPath: indexPath) as? CategoryHeaderView {
                    if let _ = self.nextCategory {
                        headerView.sectionTitle.text = MyNetwork.instance().categories[self.nextCategory!].title
                        headerView.image.image = UIImage(named: self.imagesArray[self.nextCategory!])
                    }
                    
                    return headerView
                }
            default:
                return CategoryHeaderView(frame: CGRectZero)
            }
        }
        
        return CategoryHeaderView(frame: CGRectZero)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if MyNetwork.instance().categories.count > 0 {
            return 1
        }
        return 0
    }
    
    
    func collectionView(collectionView : UICollectionView,layout  collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        
        return CGSizeMake(self.CV1.frame.size.width, 150)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if MyNetwork.instance().categories.count > 0 {
            switch collectionView {
            case self.collectionViewStack[0]:
                if self.collectionViewStack.count == 2 {
                    return MyNetwork.instance().categories[self.currentCategory].rows.count
                }
                return MyNetwork.instance().categories[self.prevCategory!].rows.count
            case self.collectionViewStack[1]:
                if self.collectionViewStack.count == 2 {
                    return MyNetwork.instance().categories[self.nextCategory!].rows.count
                }
                return MyNetwork.instance().categories[self.currentCategory].rows.count
            case self.collectionViewStack[2]:
                if let _ = self.nextCategory {
                    return MyNetwork.instance().categories[self.nextCategory!].rows.count
                }
            default: break
            }
        }
        
        return 0
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.scrollingToSection = false
    }
    
    
    //ScrollViewMethods
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        //print("target offset \(targetContentOffset.memory.y), contentOffset: \(scrollView.contentOffset.y)")
        if scrollView.contentOffset.y <= -100 && targetContentOffset.memory.y == 0 {
            if let _ = self.prevCategory {
                self.shouldLoadUp = false
                self.userInteractionEnabled = false
            }
            //didUpdateConstraint = true
        } else if targetContentOffset.memory.y == scrollView.contentSize.height - scrollView.frame.size.height && targetContentOffset.memory.y + 100 <= scrollView.contentOffset.y && self.reachedEndOfSection() && !self.fullLoadComplete() {
            if let _ = self.nextCategory {
                self.shouldLoadUp = true
                self.userInteractionEnabled = false
            }
        } else {
            
            var yOffset = targetContentOffset.memory.y > scrollView.contentOffset.y ? targetContentOffset.memory.y - scrollView.contentOffset.y : scrollView.contentOffset.y - targetContentOffset.memory.y
            yOffset = targetContentOffset.memory.y > scrollView.contentOffset.y ? targetContentOffset.memory.y - yOffset*0.7 : targetContentOffset.memory.y + yOffset*0.7
            
            //print("target offset \(targetContentOffset.memory.y), contentOffset: \(scrollView.contentOffset.y), NEW contentOffset: \(yOffset)")
            
            if yOffset < scrollView.contentSize.height - scrollView.frame.size.height {
                
                //Tell the scroll view to land on our page
                targetContentOffset.memory.y = yOffset
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //print("content offset Y: \(scrollView.contentOffset.y) alpha: \((scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height))/70)")
        
        
        if let _ = self.prevCategory {
            if scrollView.contentOffset.y < 0 {
                
                let multiplier = (scrollView.contentOffset.y*(-1))/100
                
                if self.collectionViewStack[0] == self.CV1 {
                    self.yForCV1.constant = -self.frame.size.height - 20 + 70*multiplier
                } else if self.collectionViewStack[0] == self.CV2 {
                    self.yForCV2.constant = -self.frame.size.height - 20 + 70*multiplier
                } else {//CV3
                    self.yForCV3.constant = -self.frame.size.height - 20 + 70*multiplier
                }
            }
        }
        
        if let _ = self.nextCategory {
            if self.reachedEndOfSection() {
                
                let multiplier = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height))/100
                
                if self.collectionViewStack[0] == self.CV1 {
                    if self.collectionViewStack.count == 2 {
                        self.yForCV2.constant = self.frame.size.height - 70*multiplier
                    } else {
                        self.yForCV3.constant = self.frame.size.height - 70*multiplier//self.yForCV2.constant + self.heightForCV1.constant - 80*multiplier
                    }
                } else if self.collectionViewStack[0] == self.CV2 {
                    self.yForCV1.constant = self.frame.size.height - 70*multiplier
                } else {//CV3
                    self.yForCV2.constant = self.frame.size.height - 70*multiplier
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if let doExists = self.shouldLoadUp {
            self.loadNewData(doExists, section: nil)
            self.shouldLoadUp = nil
        }
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        /*if !decelerate
         {
         let currentIndex = floor(scrollView.contentOffset.y / scrollView.bounds.size.height);
         
         let offset = CGPointMake(0, scrollView.bounds.size.height * currentIndex)
         
         scrollView.setContentOffset(offset, animated: true)
         }
         
         var counterDict = [Int: Int]()
         for each in self.browseContentView.indexPathsForVisibleItems() {
         if let exists = counterDict[each.section] {
         counterDict[each.section] = exists + 1
         } else {
         counterDict[each.section] = 1
         }
         }
         
         var (section, occurence) = (0,0)
         for (key, value) in counterDict {
         if value > occurence {
         (section, occurence) = (key, value)
         }
         }
         
         if self.currentCategory != section && !self.scrollingToSection {
         self.categorySelector.selectedSegmentIndex = section
         let current = MyNetwork.instance().categories[section]
         self.currentCategory = section
         if current.rows.count == 0 {
         self.loadNewData(section)
         } else if !current.fetchedAllRows {
         self.getMoreRowsIn(section)
         } else {
         self.counter.text = "MAX"
         }
         self.categoryTitleLabel.text = current.title
         }*/
        
        //print("title for section is \(self.availableCategories[section])")
    }
}
