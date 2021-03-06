//
//  PictureCell.swift
//  ImoCollectionView_Example
//
//  Created by Borinschi Ivan on 11/2/16.
//  Copyright (c) 2016 Imodeveloperlab. All rights reserved.
//
//  This file was generated by the ImoCollectionView Xcode Templates
//

import UIKit
import ImoCollectionView

class PictureCellSource: ImoCollectionViewCellSource {

    var pictureName : String
    
    public init(picture:String) {
        
        self.pictureName = picture
        
        super.init(cellClass: "PictureCell")
        self.height = 100
        self.width = 100
        self.nib = UINib(nibName: self.cellClass, bundle: Bundle.init(for: self.classForCoder))
    }
    
}


class PictureCell: ImoCollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    public override func setUpWithSource(source:AnyObject) {
        
        if source is PictureCellSource {
            
            imageView.image = UIImage(named: source.pictureName)
            
        }
    }    
}
