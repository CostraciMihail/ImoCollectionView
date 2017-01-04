//
//  ImoCustomCollectionFlowLayout.swift
//  Pods
//
//  Created by winify on 12/27/16.
//
//

import UIKit

open class ImoCustomCollectionFlowLayout: UICollectionViewFlowLayout {

    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        
        // Get the layout attributes for a standard UICollectionViewFlowLayout
        var elementsLayoutAttributes = super.layoutAttributesForElements(in: rect) as? [UICollectionViewLayoutAttributes]!
        if elementsLayoutAttributes == nil {
            return nil
        }
        
        
        // Define a struct we can use to store optional layout attributes in a dictionary
        struct HeaderAttributes {
            var layoutAttributes: UICollectionViewLayoutAttributes?
        }
        var visibleSectionHeaderLayoutAttributes = [Int : HeaderAttributes]()
        
        
        // Loop through the layout attributes we have
        for (index, layoutAttributes) in elementsLayoutAttributes!.enumerated() {
            let section = layoutAttributes.indexPath.section
            
            switch layoutAttributes.representedElementCategory {
            case .supplementaryView:
                // If this is a set of layout attributes for a section header, replace them with modified attributes
                if layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader {
                    let newLayoutAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: layoutAttributes.indexPath)
                    elementsLayoutAttributes![index] = newLayoutAttributes!
                    
                    // Store the layout attributes in the dictionary so we know they've been dealt with
                    visibleSectionHeaderLayoutAttributes[section] = HeaderAttributes(layoutAttributes: newLayoutAttributes)
                }
                
            case .cell:
                // Check if this is a cell for a section we've not dealt with yet
                if visibleSectionHeaderLayoutAttributes[section] == nil {
                    // Stored a struct for this cell's section so we can can fill it out later if needed
                    visibleSectionHeaderLayoutAttributes[section] = HeaderAttributes(layoutAttributes: nil)
                }
                
            case .decorationView:
                break
            }
        }
        
        // Loop through the sections we've found
        for (section, headerAttributes) in visibleSectionHeaderLayoutAttributes {
            // If the header for this section hasn't been set up, do it now
            if headerAttributes.layoutAttributes == nil {
                let newAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: NSIndexPath(item: 0, section: section) as IndexPath)
                elementsLayoutAttributes!.append(newAttributes!)
            }
        }
        
        return elementsLayoutAttributes
        
        
        
        
        
//        guard var superAttributes = super.layoutAttributesForElements(in: rect) else {
//            return super.layoutAttributesForElements(in: rect)
//        }
//        
//        let contentOffset = collectionView!.contentOffset
//        let missingSections = NSMutableIndexSet()
//        
//        for layoutAttributes in superAttributes {
//            if (layoutAttributes.representedElementCategory == .cell) {
//                missingSections.add(layoutAttributes.indexPath.section)
//            }
//            
//            if let representedElementKind = layoutAttributes.representedElementKind {
//                if representedElementKind == UICollectionElementKindSectionHeader {
//                    missingSections.remove(layoutAttributes.indexPath.section)
//                }
//            }
//        }
//        
//        missingSections.enumerate({ idx, stop in
//            
//            let indexPath = NSIndexPath(item: 0, section: idx)
//            if let layoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath as IndexPath) {
//                superAttributes.append(layoutAttributes)
//            }
//        })
//        
//        for layoutAttributes in superAttributes {
//            if let representedElementKind = layoutAttributes.representedElementKind {
//                if representedElementKind == UICollectionElementKindSectionHeader {
//                    let section = layoutAttributes.indexPath.section
//                    let numberOfItemsInSection = collectionView!.numberOfItems(inSection: section)
//                    
//                    let firstCellIndexPath = NSIndexPath(item: 0, section: section)
//                    let lastCellIndexPath = NSIndexPath(item: max(0, (numberOfItemsInSection - 1)), section: section)
//                    
//                    var firstCellAttributes:UICollectionViewLayoutAttributes
//                    var lastCellAttributes:UICollectionViewLayoutAttributes
//                    
//                    if (self.collectionView!.numberOfItems(inSection: section) > 0) {
//                        firstCellAttributes = self.layoutAttributesForItem(at: firstCellIndexPath as IndexPath)!
//                        lastCellAttributes = self.layoutAttributesForItem(at: lastCellIndexPath as IndexPath)!
//                    } else {
//                        firstCellAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: firstCellIndexPath as IndexPath)!
//                        lastCellAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: lastCellIndexPath as IndexPath)!
//                    }
//                    
//                    let headerHeight = layoutAttributes.frame.height
//                    var origin = layoutAttributes.frame.origin
//                    
//                    origin.y = min(max(contentOffset.y, (firstCellAttributes.frame.minY - headerHeight)), (lastCellAttributes.frame.maxY - headerHeight))
//                    ;
//                    
//                    layoutAttributes.zIndex = 1024;
//                    layoutAttributes.frame = CGRect(origin: origin, size: layoutAttributes.frame.size)
//                    
//                }
//            }
//        }
//        
//        return superAttributes
    }

    
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    

    
    private func frameForSection(section: Int) -> CGRect? {
        
        // Sanity check
        let numberOfItems = collectionView!.numberOfItems(inSection: section)
        if numberOfItems < 1 {
            return nil
        }
        
        // Get the index paths for the first and last cell in the section
        let firstIndexPath = NSIndexPath(row: 0, section: section)
        let lastIndexPath = NSIndexPath(row: numberOfItems - 1, section: section)
        
        // Work out the top of the first cell and bottom of the last cell
        var firstCellTop = layoutAttributesForItem(at: firstIndexPath as IndexPath)?.frame.origin.y
        let lastCellBottom = (layoutAttributesForItem(at: lastIndexPath as IndexPath)?.frame)!.maxY
        
        // Build the frame for the section
        var frame = CGRect.zero
        
        frame.size.width = collectionView!.bounds.size.width
        frame.origin.y = firstCellTop!
        frame.size.height = lastCellBottom - firstCellTop!
        
        // Increase the frame to allow space for the header
        frame.origin.y -= headerReferenceSize.height
        frame.size.height += headerReferenceSize.height
        
        // Increase the frame to allow space for any section insets
        frame.origin.y -= sectionInset.top
        frame.size.height += sectionInset.top
        
        frame.size.height += sectionInset.bottom
        
        return frame
    }
    
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // Get the layout attributes for a standard flow layout
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        
        // If this is a header, we should tweak it's attributes
        if elementKind == UICollectionElementKindSectionHeader {
            if let fullSectionFrame = frameForSection(section: indexPath.section) {
                let minimumY = max(collectionView!.contentOffset.y + collectionView!.contentInset.top, fullSectionFrame.origin.y)
                let maximumY = fullSectionFrame.maxY - headerReferenceSize.height - collectionView!.contentInset.bottom
                
                attributes?.frame = CGRect(x: 0, y: min(minimumY, maximumY), width: collectionView!.bounds.size.width, height: headerReferenceSize.height)
                attributes?.zIndex = 1
            }
        }
        
        return attributes
    }
    
    
}
