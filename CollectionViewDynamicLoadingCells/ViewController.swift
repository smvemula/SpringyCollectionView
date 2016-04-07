//
//  ViewController.swift
//  CollectionViewDynamicLoadingCells
//
//  Created by Manoj Vemula on 4/1/16.
//  Copyright © 2016 Manoj Vemula. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var browseContentView: UICollectionView!
    @IBOutlet var loadMoreLabel: UILabel!
    @IBOutlet var categoryTitleLabel: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var categorySelector: UISegmentedControl!
    var  loadingCell: LoadingCVCell?
    
    var currentSection = 0
    var rowMaxLimit = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 20 : 10
    var rowMinLimit = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 6 : 3
    
    var dataRows = [String : [String]]()
    var categories = [String]()
    var availableCategories = ["Rcmd", "Pop", "Audio", "R2ME", "Video", "Art", "New", "Lists"]
    //var availableCategories = ["Recommended", "Popular", "Audio Books", "Read To Me", "Educational Video", "Articles", "New On Epic!", "Reading Lists"]
    
    @IBAction func didSelectedNewCategory(selector: UISegmentedControl) {
        self.scrollingToSection = true
        self.loadSection(selector.selectedSegmentIndex, block: {
            if let attributes = self.browseContentView.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: selector.selectedSegmentIndex)) {
                //self.browseContentView.scrollRectToVisible(CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y - 260, attributes.frame.size.width, self.browseContentView.frame.size.height) , animated: true)
                self.browseContentView.scrollRectToVisible(CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y - 220, attributes.frame.size.width, self.browseContentView.frame.size.height) , animated: true)
                self.currentSection = selector.selectedSegmentIndex
                self.categoryTitleLabel.text = self.availableCategories[self.currentSection]
                self.browseContentView.userInteractionEnabled = true
                if !self.fullLoadComplete() {
                    self.loadMoreLabel.text = "Load \(self.availableCategories[self.categories.count]) Category"
                } else {
                    self.loadMoreLabel.text = "No More Books"
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Create a new instance of our stretchy layout and set the
        // default size for our header (for when it's not stretched)
        let stretchyLayout = StretchyHeaderSpringyCollectionViewLayout()
        stretchyLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 200)
        //[stretchyLayout setHeaderReferenceSize:[DeviceUtil getSize:CGSizeMake(944, HEADER_HEIGHT) iPhoneSize:CGSizeMake(320, HEADER_HEIGHT_IPHONE)]];
        self.browseContentView.directionalLockEnabled = false
        stretchyLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        // Set our custom layout & insets
        self.browseContentView.collectionViewLayout = stretchyLayout
        
        self.browseContentView.decelerationRate = UIScrollViewDecelerationRateFast

        self.browseContentView.registerNib(UINib(nibName: "RowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.browseContentView.registerNib(UINib(nibName: "LoadingCVCell", bundle: nil), forCellWithReuseIdentifier: "load")
        
        /*if let customFlowLayout = self.browseContentView.collectionViewLayout as? THSpringyFlowLayout {
            customFlowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        }*/
        
        self.categorySelector.removeAllSegments()
        for (index, item) in self.availableCategories.enumerate() {
            //self.categorySelector.setTitle(item, forSegmentAtIndex: index)
            self.categorySelector.insertSegmentWithTitle(item, atIndex: index, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if dataRows.count == 0 {
            self.loadNewData()
        }
    }

    var loadingNewData = false
    var scrollingToSection = false
    func reachedEndOfSection() -> Bool {
        if self.categories.count > 0 {
            if let rows = self.dataRows[self.categories[self.categories.count - 1]] {
                if rows.count >= self.rowMaxLimit {
                    return true
                }
            }
        } else {
            return true//
        }
        return false
    }
    
    func fullLoadComplete() -> Bool {
        return self.availableCategories.count == self.categories.count
    }
    
    
    
    func loadSection(section: Int, block: ()->()) {
        if self.categories.contains(self.availableCategories[section]) {
            block()
        } else {
            let sections = NSIndexSet(indexesInRange: NSMakeRange(self.categories.count, section - self.categories.count + 1))
            for index in self.categories.count...section {
                self.categories.append(self.availableCategories[index])
                self.dataRows[self.categories.last!] = newArray
            }
            self.browseContentView.performBatchUpdates({
                self.browseContentView.insertSections(sections)
                }, completion: { completed in
                    block()
            })
        }
    }
    
    func loadNewData() {
        if !loadingNewData {
            self.loadMoreLabel.font = UIFont.boldSystemFontOfSize(15)
            self.loadingNewData = true
            self.loadMoreLabel.alpha = self.reachedEndOfSection() ? 1.0 : 0.0
            if self.reachedEndOfSection() {self.spinner.startAnimating()}
            if !self.fullLoadComplete() {
                print( self.reachedEndOfSection() ? "Loading NEXT Category" : "Loading more rows in \(self.categories.last!)")
                self.loadMoreLabel.text = self.reachedEndOfSection() ? "Loading \(self.availableCategories[self.categories.count]) Category..." : "Loading More Books ..."
            }
            let delay = self.reachedEndOfSection() ? 2 * Double(NSEC_PER_SEC) : 0.4 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            self.browseContentView.userInteractionEnabled = !self.reachedEndOfSection()
            dispatch_after(time, dispatch_get_main_queue(), {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if self.reachedEndOfSection() {
                        if self.categories.count == 0 {
                            self.categorySelector.hidden = false
                        }
                        self.loadNextSection(self.categories.count)
                    } else {
                        self.loadMoreRowsInSection(self.categories.count - 1)
                    }

                    self.loadMoreLabel.alpha = 0.0
                    if !self.fullLoadComplete() {
                        self.loadMoreLabel.text = "Load \(self.availableCategories[self.categories.count]) Category"
                    } else {
                        self.loadMoreLabel.text = "No More Books"
                    }
                    self.spinner.stopAnimating()
                    self.loadingNewData = false
                })
            })
        }
    }
    
    let newArray = ["This Week", "All Time", "Daily Life", "Fiction", "Top Rated", "Articles", "Living Things", "Featured", "World", "Non-Fiction","This Week", "All Time", "Daily Life", "Fiction", "Top Rated", "Articles", "Living Things", "Featured", "World", "Non-Fiction"]
    
    func loadNextSection(section: Int) {
        if self.categories.count < self.availableCategories.count {
            self.categories.append(self.availableCategories[section])
            var tempArray = [String]()
            for index in 0...self.rowMinLimit - 1 {
                tempArray.append(self.newArray[index])
            }
            self.dataRows[self.categories.last!] = tempArray
            
            if let strechyHeader = self.browseContentView.collectionViewLayout as? StretchyHeaderSpringyCollectionViewLayout {
                strechyHeader.sprin
            }
            //ONLY Reload New Category with minimum rows
            self.browseContentView.performBatchUpdates({
                self.browseContentView.insertSections(NSIndexSet(index: section))
                if self.categories.count > 1 {
                    self.browseContentView.reloadItemsAtIndexPaths([NSIndexPath(forRow: self.rowMaxLimit, inSection: section - 1)])
                }
                }, completion: { completed in
                    self.categorySelector.selectedSegmentIndex = section
                    self.didSelectedNewCategory(self.categorySelector)
                    if !self.reachedEndOfSection() {
                        self.loadNewData()
                    }
            })
        }
    }
    
    func loadMoreRowsInSection(section: Int) {
        //ONLY Reload New Rows  in Existing Category
        self.browseContentView.performBatchUpdates({
            var olderSize = 0
            if let existingRows = self.dataRows[self.categories[section]] {
                olderSize = existingRows.count
                var temp = existingRows
                temp.append(self.newArray[olderSize])
                self.dataRows[self.categories[section]] = temp
                
                var indexPathsToLoad = [NSIndexPath]()
                /*for index in olderSize...olderSize + self.newArray.count - 1 {
                 indexPathsToLoad.append(NSIndexPath(forRow: index, inSection: self.categories.count - 1))
                 }*/
                indexPathsToLoad.append(NSIndexPath(forRow: olderSize, inSection: section))
                self.browseContentView.insertItemsAtIndexPaths(indexPathsToLoad)
            }
            
            
            }, completion: { completed in
                if !self.reachedEndOfSection() {
                    self.loadNewData()
                }
        })
    }

}

//MARK: CollectionViewDelegate & Datasource Methods
extension ViewController {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == self.dataRows[self.categories[indexPath.section]]!.count {
            loadingCell = collectionView.dequeueReusableCellWithReuseIdentifier ("load", forIndexPath:indexPath) as? LoadingCVCell
            
            if (loadingCell == nil)
            {
                let nib:Array = NSBundle.mainBundle().loadNibNamed("LoadingCVCell", owner: self, options: nil)
                loadingCell = nib[0] as? LoadingCVCell
            }
            
            if indexPath.section == self.availableCategories.count - 1 && indexPath.row == rowMaxLimit {
                currentSection += 1
            }
            
            return loadingCell!
        }
        
        var  cell: RowCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier ("cell",
                                                                                                 forIndexPath:indexPath) as? RowCollectionViewCell
        
        if (cell == nil)
        {
            let nib:Array = NSBundle.mainBundle().loadNibNamed("RowCollectionViewCell", owner: self, options: nil)
            cell = nib[0] as? RowCollectionViewCell
        }
        
        cell?.title.text = self.dataRows[self.categories[indexPath.section]]![indexPath.row]
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let headerView = self.browseContentView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "section", forIndexPath: indexPath) as? CategoryHeaderView {
                //headerView.sectionTitle.text = self.categories[indexPath.section]
                if !self.scrollingToSection {
                    //self.categorySelector.selectedSegmentIndex = indexPath.section
                    //self.categoryTitleLabel.text = self.availableCategories[indexPath.section]
                }
                return headerView
            }
        }
        
        return UICollectionReusableView(frame: CGRectZero)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.categories.count
    }
    
    
    func collectionView(collectionView : UICollectionView,layout  collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        if indexPath.row == self.dataRows[self.categories[indexPath.section]]!.count && indexPath.section == self.categories.count - 1 {
            return CGSizeMake(self.browseContentView.frame.size.width, 40)
        } else if indexPath.row < self.dataRows[self.categories[indexPath.section]]!.count {
            return CGSizeMake(self.browseContentView.frame.size.width, 150)
        }
        return CGSizeMake(self.browseContentView.frame.size.width, 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataRows[self.categories[section]]!.count + 1
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.scrollingToSection = false
    }

    
    //ScrollViewMethods
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            //var didUpdateConstraint = false
        
        /*print("target offset \(targetContentOffset.memory.y), contentOffset: \(scrollView.contentOffset.y)")
        if let futureIndexPath = self.browseContentView.indexPathForItemAtPoint(CGPointMake(targetContentOffset.memory.x, targetContentOffset.memory.y)) {
            print("current Section: \(currentSection), Future Section: \(futureIndexPath.section)")
            //if currentSection < self.categories.count {
                if currentSection != futureIndexPath.section {
                    if let attributes = self.browseContentView.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: currentSection < futureIndexPath.section ? currentSection + 1 : currentSection - 1)) {
                        targetContentOffset.memory.y = attributes.frame.origin.y - 220
                        self.currentSection = currentSection < futureIndexPath.section ? currentSection + 1 : currentSection - 1
                    }
                } else if let currentIndexPath = self.browseContentView.indexPathForItemAtPoint(CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y)) {
                    print("current Segment: \(self.categorySelector.selectedSegmentIndex), Future Section: \(futureIndexPath.section)")
                    if self.categorySelector.selectedSegmentIndex != futureIndexPath.section {
                        if let attributes = self.browseContentView.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: self.categorySelector.selectedSegmentIndex)) {
                            targetContentOffset.memory.y = attributes.frame.origin.y - 220
                            self.currentSection = self.categorySelector.selectedSegmentIndex
                        }
                    }
                }
            //}
                //print("Section: \(existsIndexPath.section), Row: \(existsIndexPath.row)")
            //}
            //print("Section: \(existsIndexPath.section), Row: \(existsIndexPath.row)")
        } else {
            //Landing on Section Header
            if targetContentOffset.memory.y > scrollView.contentOffset.y {
                if let attributes = self.browseContentView.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: currentSection < self.categories.count - 1 ? currentSection + 1 : currentSection)) {
                    targetContentOffset.memory.y = attributes.frame.origin.y - 220
                    self.currentSection = currentSection < self.categories.count - 1 ? currentSection + 1 : currentSection
                }
            } else if targetContentOffset.memory.y < scrollView.contentOffset.y {
                if let attributes = self.browseContentView.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: currentSection > 0 ? currentSection - 1 : currentSection)) {
                    targetContentOffset.memory.y = attributes.frame.origin.y - 220
                    self.currentSection = currentSection > 0 ? currentSection - 1 : currentSection
                }
            }
        }*/
        
        
        
        //print("target offset \(targetContentOffset.memory.y), contentOffset: \(scrollView.contentOffset.y)")
        /*if targetContentOffset.memory.y == 0 {
            //didUpdateConstraint = true
        } else if targetContentOffset.memory.y > scrollView.contentOffset.y && !self.reachedEndOfSection {
            //self.loadNewData()
        } else*/ if targetContentOffset.memory.y == scrollView.contentSize.height - scrollView.frame.size.height && targetContentOffset.memory.y + 100 <= scrollView.contentOffset.y && self.reachedEndOfSection() && !self.fullLoadComplete() {
            self.loadNewData()
        } else {
            //This is the index of the "page" that we will be landing at
            //let nearestIndex = Int(CGFloat(targetContentOffset.memory.y*0.5) / scrollView.bounds.size.height)
            
            //Just to make sure we don't scroll past your content
            //let clampedIndex = max( min( nearestIndex, Int(scrollView.contentSize.height/scrollView.bounds.size.height)), 0 )
            
            //This is the actual x position in the scroll view
            //var yOffset = CGFloat(clampedIndex) * scrollView.bounds.size.height
            
            //I've found that scroll views will "stick" unless this is done
            //yOffset = yOffset == 0.0 ? 1.0 : yOffset
            
            var yOffset = targetContentOffset.memory.y > scrollView.contentOffset.y ? targetContentOffset.memory.y - scrollView.contentOffset.y : scrollView.contentOffset.y - targetContentOffset.memory.y
            yOffset = targetContentOffset.memory.y > scrollView.contentOffset.y ? targetContentOffset.memory.y - yOffset*0.5 : targetContentOffset.memory.y + yOffset*0.5
            
            //print("target offset \(targetContentOffset.memory.y), contentOffset: \(scrollView.contentOffset.y), NEW contentOffset: \(yOffset)")
            
            if yOffset < scrollView.contentSize.height - scrollView.frame.size.height {

                //Tell the scroll view to land on our page
                targetContentOffset.memory.y = yOffset
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //print("content offset Y: \(scrollView.contentOffset.y) alpha: \((scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height))/70)")
        if !self.loadingNewData && self.reachedEndOfSection() {
            let multiplier = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height))/100
            self.loadMoreLabel.font = UIFont.boldSystemFontOfSize(12 + 3*multiplier)
            self.loadMoreLabel.alpha = 1.0*multiplier
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        /*let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.width
        if bottomEdge <= scrollView.contentSize.height && !self.reachedEndOfSection {
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.loadMoreLabel.alpha = 1.0
                }, completion: nil)
            self.spinner.startAnimating()
        }*/
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
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
        
        self.categorySelector.selectedSegmentIndex = section
        self.categoryTitleLabel.text = self.availableCategories[section]
        //print("title for section is \(self.availableCategories[section])")
    }
}

