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
    @IBOutlet var scrollUpLabel: UILabel!
    @IBOutlet var counter: UILabel!
    @IBOutlet var topLayoutForLabel: NSLayoutConstraint!
    @IBOutlet var bottomLayoutForLabel: NSLayoutConstraint!
    @IBOutlet var yForCollectionView: NSLayoutConstraint!
    @IBOutlet var heightForCollectionView: NSLayoutConstraint!
    @IBOutlet var categoryTitleLabel: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var categorySelector: UISegmentedControl!
    var  loadingCell: LoadingCVCell?
    
    var prevRow: Int = 0
    
    var imagesArray = ["pollination-image","place-value-image","fiction-vs-nonfiction-image","gravity-image","managing-frustration-image","map-skills-image","oceans-image","poetry-image","water-cycle-image"]
    
    var rowMaxLimit = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 20 : 10
    var rowMinLimit = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 6 : 3
    
    @IBAction func didSelectedNewCategory(selector: UISegmentedControl) {
        self.scrollingToSection = true
        self.loadNewData(true, section: selector.selectedSegmentIndex)
    }
    
    func performScrollAnimationToSection() {
        //self.browseContentView.scrollsToTop = true
        if let attributes = self.browseContentView.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
            //self.browseContentView.scrollRectToVisible(CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y - 260, attributes.frame.size.width, self.browseContentView.frame.size.height) , animated: true)
            self.browseContentView.scrollRectToVisible(CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y - 210, attributes.frame.size.width, self.browseContentView.frame.size.height) , animated: false)
            self.categoryTitleLabel.text = MyNetwork.instance().categories[MyNetwork.instance().currentSection].title
            if !self.fullLoadComplete() {
                self.loadMoreLabel.text = "Load \(MyNetwork.instance().categories[MyNetwork.instance().currentSection + 1].title)"
            } else {
                self.loadMoreLabel.text = "No More Books"
            }
        }
        self.view.stopLoading()
    }
    
    func performScrollBackAnimationToSection() {
        if let attributes = self.browseContentView.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: MyNetwork.instance().categories[MyNetwork.instance().currentSection].rows.count - 1, inSection: 0)) {
            self.browseContentView.scrollRectToVisible(CGRectMake(attributes.frame.origin.x, attributes.frame.origin.y, attributes.frame.size.width, 150) , animated: false)
            self.categoryTitleLabel.text = MyNetwork.instance().categories[MyNetwork.instance().currentSection].title
            if !self.fullLoadComplete() {
                self.loadMoreLabel.text = "Load \(MyNetwork.instance().categories[MyNetwork.instance().currentSection + 1].title)"
            } else {
                self.loadMoreLabel.text = "No More Books"
            }
        }
        self.view.stopLoading()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.heightForCollectionView.constant = self.view.frame.size.height - 20
        
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
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMoreRowsIn(section: Int) {
        let current = MyNetwork.instance().categories[section]
        if !current.fetchedAllRows {
            MyAPIs.getData(section, completion: {
                if MyNetwork.instance().currentSection == section {
                    self.getMoreRowsIn(section)
                } else {
                    
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
                        if indexPathsToLoad.count > 0 && MyNetwork.instance().currentSection == section {
                            self.browseContentView.insertItemsAtIndexPaths(indexPathsToLoad)
                        }
                        if MyNetwork.instance().currentSection == section {
                            self.counter.text = "\(current.currentIndex)"
                        }
                        if current.fetchedAllRows {
                            self.counter.text = "MAX"
                        }
                    })
                //}
            })
        } else {
            self.loadingNewData = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.spinner.startAnimating()
        if MyNetwork.instance().categories.count == 0 {
            self.loadMoreLabel.text = "Initial Loading ..."
            MyAPIs.getSections({
                self.loadSection({})
            })
        }
    }
    
    func updateCategorySelector() {
        self.categorySelector.removeAllSegments()
        for (index, item) in MyNetwork.instance().categories.enumerate() {
            self.categorySelector.insertSegmentWithTitle(item.title, atIndex: index, animated: false)
        }
        self.categorySelector.selectedSegmentIndex = MyNetwork.instance().currentSection
        self.counter.hidden = false
        self.browseContentView.hidden = false
        //self.categorySelector.hidden = false
    }

    var loadingNewData = false
    var scrollingToSection = false
    func reachedEndOfSection() -> Bool {
        let current = MyNetwork.instance().categories[MyNetwork.instance().currentSection]
        if current.fetchedAllRows {
            return true
        }
        return false
    }
    
    func fullLoadComplete() -> Bool {
        return MyNetwork.instance().currentSection + 1 == MyNetwork.instance().categories.count
    }
    
    
    
    func loadSection(block : ()->()) {
        
        let current = MyNetwork.instance().categories[MyNetwork.instance().currentSection]
        if current.fetchedAllRows {
                //self.scrollingToSection = true
            self.view.stopLoading()
            self.yForCollectionView.constant = 0
            self.browseContentView.reloadData()
            if self.prevRow > MyNetwork.instance().currentSection {
                self.performScrollBackAnimationToSection()
            } else {
                self.performScrollAnimationToSection()
            }
            dispatch_async(dispatch_get_main_queue(), {
            self.scrollingToSection = true
            self.categorySelector.selectedSegmentIndex = MyNetwork.instance().currentSection
            self.getBackToNormal({
                self.view.stopLoading()
                self.browseContentView.userInteractionEnabled = true
            })
            self.counter.text = "\(current.rows.count)"
            self.counter.text = "MAX"
            })
        } else {
        
        MyAPIs.getData(MyNetwork.instance().currentSection, completion: {
            let current = MyNetwork.instance().categories[MyNetwork.instance().currentSection]
            MyNetwork.instance().activeCategories.append(current)
            current.currentIndex = current.rows.count
            self.loadingNewData = false
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.counter.text = "\(current.currentIndex)"
                
                if !self.fullLoadComplete() {
                    self.loadMoreLabel.text = "Load \(MyNetwork.instance().categories[MyNetwork.instance().currentSection + 1].title)"
                } else {
                    self.loadMoreLabel.text = "No More Books"
                }
                self.loadMoreLabel.alpha = 0.0
                
                self.spinner.stopAnimating()
                self.yForCollectionView.constant = 0
                if MyNetwork.instance().currentSection == 0 {
                    self.updateCategorySelector()
                    self.browseContentView.reloadData()
                    self.getMoreRowsIn(MyNetwork.instance().currentSection)
                } else {
                     self.browseContentView.reloadData()
                    if self.prevRow > MyNetwork.instance().currentSection {
                        //self.performScrollBackAnimationToSection()
                    } else {
                        self.performScrollAnimationToSection()
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.scrollingToSection = true
                        self.categorySelector.selectedSegmentIndex = MyNetwork.instance().currentSection
                        self.getBackToNormal({
                            self.view.stopLoading()
                            self.browseContentView.userInteractionEnabled = true
                        })
                        self.counter.text = "\(current.rows.count)"
                    })
                    self.getMoreRowsIn(MyNetwork.instance().currentSection)
                }
            })
        })
        }
    }
    
    func loadNewData(isdownScroll: Bool, section: Int?) {
        //if !loadingNewData {
            self.loadingNewData = true
            self.loadMoreLabel.font = UIFont.boldSystemFontOfSize(15)
            self.loadMoreLabel.alpha = 0.0
        self.scrollUpLabel.alpha = 0.0
            //if self.reachedEndOfSection() {self.spinner.startAnimating()}

            if let isJump = section {
                MyNetwork.instance().currentSection = isJump
                
                let current = MyNetwork.instance().categories[MyNetwork.instance().currentSection]
                if current.rows.count > 0 {
                    self.getMoreRowsIn(MyNetwork.instance().currentSection)
                    self.performScrollAnimationToSection()
                } else {
                    self.view.startLoading()
                    self.loadSection({})
                }
            } else {
                
                prevRow = MyNetwork.instance().currentSection
                self.browseContentView.userInteractionEnabled = false
                
                if isdownScroll {
                    MyNetwork.instance().currentSection += 1
                    self.scrollDownAnimation({
                        self.view.startLoading()
                        self.scrollingToSection = true
                        self.loadSection({})
                    })
                } else {
                    MyNetwork.instance().currentSection -= 1
                    self.scrollUpAnimation({
                        self.view.startLoading()
                        self.scrollingToSection = true
                        self.loadSection({})
                    })
                }
                if !self.fullLoadComplete() {
                    print( self.reachedEndOfSection() ? "Loading NEXT Category" : "Loading more rows in \(MyNetwork.instance().categories.last!)")
                    self.loadMoreLabel.text = self.reachedEndOfSection() ? "Loading \(MyNetwork.instance().categories[MyNetwork.instance().currentSection + 1].title) ..." : "Loading More Books ..."
                }
            }
        
        //}
    }
    
    func getBackToNormal(completion:()->()) {
        if self.prevRow > MyNetwork.instance().currentSection {
            self.performScrollBackAnimationToSection()
        }
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            //self.view.layoutIfNeeded() // Animate from constraints
            self.browseContentView.alpha = 1.0
            
            }, completion: { (finished:Bool) -> Void in
                completion()
        })
    }
    
    func scrollUpAnimation(completion: ()-> ()) {
        self.yForCollectionView.constant = self.view.frame.size.height
        UIView.animateWithDuration(0.5,
                                   animations: { () -> Void in
            self.view.layoutIfNeeded() // Animate from constraints
            self.browseContentView.alpha = 0.0
            }, completion: { (finished:Bool) -> Void in
                completion()
        })
    }
    
    func scrollDownAnimation(completion: ()-> ()) {
        self.yForCollectionView.constant = -self.view.frame.size.height
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded() // Animate from constraints
            }, completion: { (finished:Bool) -> Void in
                self.browseContentView.alpha = 0.0
                completion()
        })
    }
    
    var shouldLoadUp : Bool?

}

//MARK: CollectionViewDelegate & Datasource Methods
extension ViewController {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == MyNetwork.instance().categories[indexPath.section].rows.count {
            loadingCell = collectionView.dequeueReusableCellWithReuseIdentifier ("load", forIndexPath:indexPath) as? LoadingCVCell
            
            if (loadingCell == nil)
            {
                let nib:Array = NSBundle.mainBundle().loadNibNamed("LoadingCVCell", owner: self, options: nil)
                loadingCell = nib[0] as? LoadingCVCell
            }
            
            if indexPath.section == MyNetwork.instance().categories.count - 1 && indexPath.row == rowMaxLimit {
                //currentSection += 1
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
        
        
        //let category =  MyNetwork.instance().categories[indexPath.section]
        let category =  MyNetwork.instance().categories[MyNetwork.instance().currentSection]
        cell?.row = category.rows[indexPath.row]
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if let headerView = self.browseContentView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "section", forIndexPath: indexPath) as? CategoryHeaderView {
//                headerView.sectionTitle.text = MyNetwork.instance().categories[indexPath.section].title
//                headerView.image.image = UIImage(named: self.imagesArray[indexPath.section])
                headerView.sectionTitle.text = MyNetwork.instance().categories[MyNetwork.instance().currentSection].title
                headerView.image.image = UIImage(named: self.imagesArray[MyNetwork.instance().currentSection])

                headerView.widthForimage.constant = headerView.frame.size.width + 100
                headerView.heightForimage.constant = headerView.frame.size.height + 100
                if !self.scrollingToSection {
                    //self.categorySelector.selectedSegmentIndex = indexPath.section
                    //self.categoryTitleLabel.text = self.availableCategories[indexPath.section]
                }
                return headerView
            }
        }
        
        return CategoryHeaderView(frame: CGRectZero)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // that -16 is because I have 8px for left and right spacing constraints for the label.
        // Set some extra pixels for height due to the margins of the header section.
        //This value should be the sum of the vertical spacing you set in the autolayout constraints for the label. + 16 worked for me as I have 8px for top and bottom constraints.
        /*if MyNetwork.instance().currentSection == section || section == self.prevRow { //MyNetwork.instance().categories[section].rows.count > 0  {
            print("Height for this section \(section) is 200")
            return CGSize(width: collectionView.frame.width, height: 200)
        }
        print("Height for this section \(section) is 0")
        return CGSize(width: collectionView.frame.width, height: 0)*/
        
        return CGSize(width: collectionView.frame.width, height: 200)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //return MyNetwork.instance().activeCategories.count
        //return MyNetwork.instance().currentSection + 1
        //return MyNetwork.instance().categories.count
        if MyNetwork.instance().categories.count > 0 {
        return 1
        }
        return 0
    }
    
    
    func collectionView(collectionView : UICollectionView,layout  collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        /*if (MyNetwork.instance().currentSection == indexPath.section || indexPath.section == self.prevRow)  {
            if indexPath.row == MyNetwork.instance().categories[indexPath.section].rows.count && indexPath.section == MyNetwork.instance().currentSection {
                return CGSizeMake(self.browseContentView.frame.size.width, 40)
            } else if indexPath.row < MyNetwork.instance().categories[indexPath.section].rows.count {
                return CGSizeMake(self.browseContentView.frame.size.width, 150)
            }
        }
         
         return CGSizeMake(self.browseContentView.frame.size.width, 0)
         */
        
        return CGSizeMake(self.browseContentView.frame.size.width, 150)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*if MyNetwork.instance().categories.count > 0 && (MyNetwork.instance().currentSection == section || section == self.prevRow) {
            return MyNetwork.instance().categories[section].rows.count
        }*/
        
        if MyNetwork.instance().categories.count > 0 {
            return MyNetwork.instance().categories[MyNetwork.instance().currentSection].rows.count
        }
        
        return 0
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
        if scrollView.contentOffset.y <= -100 && targetContentOffset.memory.y == 0 && MyNetwork.instance().currentSection != 0 {
            //self.loadNewData(false, section: nil)
            self.shouldLoadUp = false
            self.topLayoutForLabel.constant = 200
            //didUpdateConstraint = true
        } else /*if targetContentOffset.memory.y > scrollView.contentOffset.y && !self.reachedEndOfSection {
            //self.loadNewData()
        } else*/ if targetContentOffset.memory.y == scrollView.contentSize.height - scrollView.frame.size.height && targetContentOffset.memory.y + 100 <= scrollView.contentOffset.y && self.reachedEndOfSection() && !self.fullLoadComplete() {
            //self.loadNewData(true, section: nil)
            self.shouldLoadUp = true
            self.bottomLayoutForLabel.constant = -20
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
        
        if scrollView.contentOffset.y < 0 && MyNetwork.instance().currentSection != 0 {
            let multiplier = (scrollView.contentOffset.y*(-1))/100
            self.scrollUpLabel.font = UIFont.boldSystemFontOfSize(5 + 10*multiplier)
            self.scrollUpLabel.alpha = 1.0*multiplier
            self.topLayoutForLabel.constant = 200 + 50*multiplier
        }
    
        if self.reachedEndOfSection() {
            let multiplier = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height))/100
            self.loadMoreLabel.font = UIFont.boldSystemFontOfSize(5 + 10*multiplier)
            self.loadMoreLabel.alpha = 1.0*multiplier
            self.bottomLayoutForLabel.constant = -20 + 50*multiplier
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
        
        if let doExists = self.shouldLoadUp {
            self.loadNewData(doExists, section: nil)
            self.shouldLoadUp = nil
        }
        
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
        
        /*if MyNetwork.instance().currentSection != section && !self.scrollingToSection {
            self.categorySelector.selectedSegmentIndex = section
            let current = MyNetwork.instance().categories[section]
            MyNetwork.instance().currentSection = section
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

