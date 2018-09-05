//
//  ColumnFlowLayout.swift
//  CollectionViewTest
//
//  Created by shiz on 2018/06/09.
//  Copyright © 2018年 shiz. All rights reserved.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    // After invalidateLayouts
    override func prepare() {
        super.prepare()
        
        guard let cv = collectionView else { return }
        
        // FlowLayoutは表示できる限り一行にカラムを詰め込む性質がある
        let availableWidth = cv.bounds.inset(by: cv.layoutMargins).size.width

        let minColumnWidth = CGFloat(300.0)
        let maxNumColumns = Int(availableWidth / minColumnWidth)
        let cellWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)

        self.itemSize = CGSize(width: cellWidth, height: 120.0)
                
//        self.itemSize = CGSize(width: cv.bounds.inset(by: cv.layoutMargins).size.width, height: 120.0)
        
        self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
        self.sectionInsetReference = .fromSafeArea
    }
}
