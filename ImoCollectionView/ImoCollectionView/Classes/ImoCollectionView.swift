//
//  ImoCollectionView.swift
//  ImoCollectionView
//
//  Created by Borinschi Ivan on 10/13/16.
//  Copyright © 2016 Imodeveloper. All rights reserved.
//

import UIKit

protocol ImoCollectionViewProtocol {
    
}

public class ImoCollectionView: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    
    // MARK: - Proprietes
    
    var registeredCells = Array<String>()
    var registeredViews = Array<String>()
    var sections = Array<ImoCollectionViewSection>()

    
    public var didSelectSource:((ImoCollectionViewCellSource?) -> (Void))?
    public var didSelectItemAt:((IndexPath) -> (Void))?
    public var canFocusItemAt:((IndexPath) -> (Bool))?
    
    
    public var scrollViewDidScroll:((UIScrollView) -> (Void))?
    public var scrollViewDidZoom:((UIScrollView) -> (Void))?
    public var scrollViewWillBeginDragging:((UIScrollView) -> (Void))?
    public var scrollViewWillEndDragging:((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> (Void))?
    public var scrollViewDidEndDragging:((_ scrollView: UIScrollView, _ decelerate: Bool) -> (Void))?
    public var scrollViewWillBeginDecelerating:((UIScrollView) -> (Void))?
    
    // MARK: - UICollectionView
    
    public init(controller: UIViewController, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame: controller.view.frame, collectionViewLayout: layout)
        self.setUp()
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame: frame, collectionViewLayout: layout)
        self.setUp()
    }
    
    func setUp() {
        
        self.backgroundColor = UIColor.clear
        self.delegate = self;
        self.dataSource = self;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        let layout = UICollectionViewFlowLayout()
        self.setCollectionViewLayout(layout, animated: false)
        self.setUp()        
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let closure = self.didSelectItemAt {
            closure(indexPath)
        }
        
        if let closure = self.didSelectSource {
            closure(self.cellSourceForIndexPath(indexPath: indexPath))
        }
        
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        
        var transitionLayou = self.collectionViewLayout
        
        
        return transitionLayou as! UICollectionViewTransitionLayout
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        
        return proposedIndexPath
    }
    
    
//    @objc(collectionView:canFocusItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath?) -> Bool {
        
        if let closure = self.canFocusItemAt {
            closure(indexPath!)
        }
        
        return true
    }
    
    
//    public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
//        
//        if let closure = self.canFocusItemAt {
//            closure(indexPath)
//        }
//        
//        return true
//    }
    
    
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.sourcesCount(inSection: section)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.sectionsCount()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let source = self.cellSourceForIndexPath(indexPath: indexPath) {
           
            self.registerCellClassForSource(source: source)
            
            let cell : ImoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: source.cellClass, for: indexPath) as! ImoCollectionViewCell
            cell.setUpWithSource(source: source)
            return cell as UICollectionViewCell
        }
        
        return UICollectionViewCell()
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let headerViewSource = self.reusableViewSourceForIndexPath(indexPath: indexPath, kind: kind)
        {
           self.registerClassForReusableView(reusableViewSource: headerViewSource)
            
            let view : ImoCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: headerViewSource.kind, withReuseIdentifier: headerViewSource.indentifier, for: indexPath) as! ImoCollectionReusableView
            
            view.setUpWithSource(source: headerViewSource)
            
            return view;
        }
        else
        {
            return UICollectionReusableView()
        }
        
    }
    
    
    // MARK: - Helpers
    
    
    public func registeredViewsCount() -> Int {
        
        return registeredViews.count;
    }
    
    public func registeredCellsCount() -> Int {
        
        return registeredCells.count;
    }
    
    
    public func sectionsCount() -> Int {
        
        return sections.count
    }
    
    public func sourcesCount(inSection sectionIndex:Int) -> Int {
        
        if self.sections.indices.contains(sectionIndex) {
            
            let section : ImoCollectionViewSection = self.sections[sectionIndex]
            return section.countSources()
        }
        
        return 0
    }
    
    
    public func registerCellClassForSource(source:ImoCollectionViewCellSource) {
        
        if !registeredCells.contains(source.cellClass) {
         
            if let _ = source.nib {
                self.register(source.nib, forCellWithReuseIdentifier: source.cellClass)
                registeredCells.append(source.cellClass)
            }
            else {
                self.register(NSClassFromString(source.cellClass), forCellWithReuseIdentifier:source.cellClass)
                registeredCells.append(source.cellClass)
            }
        }
    }
    
    
    public func registerClassForReusableView(reusableViewSource:ImoCollectionReusableViewSource) {
        
        let identifier = reusableViewSource.viewClass.appending(reusableViewSource.indentifier)
        
        if !registeredViews.contains(identifier)  {
            
            if let _ = reusableViewSource.nib {
                
                self.register(reusableViewSource.nib, forSupplementaryViewOfKind:  reusableViewSource.kind, withReuseIdentifier: reusableViewSource.indentifier)
                registeredViews.append(identifier)
                
            } else {
                
                self.register(NSClassFromString(reusableViewSource.viewClass), forSupplementaryViewOfKind: reusableViewSource.kind, withReuseIdentifier:reusableViewSource.indentifier)
                registeredViews.append(identifier)
            }
        }
    }
    
    
    public func cellSourceForIndexPath(indexPath:IndexPath) -> ImoCollectionViewCellSource? {
        
        if self.sections.indices.contains(indexPath.section) {
            
            let section : ImoCollectionViewSection = self.sections[indexPath.section]
            return section.sourceAtIndex(index: indexPath.row)
        }
        
        return nil
    }
    
    
    public func reusableViewSourceForIndexPath(indexPath:IndexPath,kind: String) -> ImoCollectionReusableViewSource? {
        
        if self.sections.indices.contains(indexPath.section) {

            let section : ImoCollectionViewSection = self.sections[indexPath.section]
            
            if (kind == UICollectionElementKindSectionHeader) {
                return section.headerViewSource
            }
            else if (kind == UICollectionElementKindSectionFooter) {
                return section.footerViewSource
            }
        }
        
        return nil
    }
    
    
    
    public func sectionForIndex(section:Int) -> ImoCollectionViewSection? {
        
        if self.sections.indices.contains(section) {
            let section : ImoCollectionViewSection = self.sections[section]
            return section;
        }

        return nil
    }
    
    
    public func addSection(section:ImoCollectionViewSection) {
        
        self.sections.append(section)
        
    }
    
    public func deleteAllSections() {
        
        self.sections.removeAll()
        
    }
    
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let source = self.cellSourceForIndexPath(indexPath: indexPath) {
            
            if (source.width != nil && source.height != nil) {
                
                return CGSize(width: source.width!, height: source.height!)
                
            }
            
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if let section = self.sectionForIndex(section: section) {
            return section.minimumLineSpacing
        }
        
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if let section = self.sectionForIndex(section: section) {
            return section.minimumInteritemSpacing
        }
        
        return 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if let section = self.sectionForIndex(section: section) {
            return section.inset
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if let section = self.sectionForIndex(section: section) {
            
            if let header = section.headerViewSource {
                
                if let size = header.size {
                    return size;
                }
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if let section = self.sectionForIndex(section: section) {
            
            if let footer = section.footerViewSource {
                
                if let size = footer.size {
                    return size;
                }
            }
        }
        
        return CGSize(width: 0, height: 0)
        
    }
    
    
    public func setSticky(header: Bool, footer:Bool) {
        
        if header {
            
            // casting is required because UICollectionViewLayout doesn't offer header pin.
            //Its feature of UICollectionViewFlowLayout
            var layout = self.collectionViewLayout as? UICollectionViewFlowLayout
            
            if #available(iOS 9.0, *) {
                layout?.sectionHeadersPinToVisibleBounds = true
                
            } else {
            
                layout = ImoCustomCollectionFlowLayout()
            }

            self.collectionViewLayout = layout!
        }
        
        if footer {
            
            // casting is required because UICollectionViewLayout doesn't offer header pin.
            //Its feature of UICollectionViewFlowLayout
            var layout = self.collectionViewLayout as? UICollectionViewFlowLayout
            
            if #available(iOS 9.0, *) {
                layout?.sectionFootersPinToVisibleBounds = true
                
            } else {
                
                layout = ImoCustomCollectionFlowLayout()
            }
            
            self.collectionViewLayout = layout!
        }

    }
    
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        if let closure = self.scrollViewDidScroll {
            closure(scrollView)
        }
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView)  {
        
        if let closure = self.scrollViewDidZoom {
            closure(scrollView)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if let closure = self.scrollViewWillBeginDragging {
            closure(scrollView)
        }
    }
    
   
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if let closure = self.scrollViewWillEndDragging {
            closure(scrollView, velocity, targetContentOffset)
        }
    }
    

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if let closure = self.scrollViewDidEndDragging {
            closure(scrollView, decelerate)
        }
        
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        if let closure = self.scrollViewWillBeginDecelerating {
            closure(scrollView)
        }
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        
        return true
        
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
        
    }
    
    
}
