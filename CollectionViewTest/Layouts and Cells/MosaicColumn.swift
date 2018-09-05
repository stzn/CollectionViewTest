//
//  MosaicColumn.swift
//  CollectionViewTest
//
//  Created by shiz on 2018/06/10.
//  Copyright © 2018年 shiz. All rights reserved.
//

import UIKit


struct MosaicColumns {
    var columns:[MosaicColumn]
    
    var smallestColumn: MosaicColumn {
        return columns.sorted().last!
    }
    
    init() {
        columns = [MosaicColumn](repeating: MosaicColumn(), count: 3)
    }
    
    subscript(index: Int) -> MosaicColumn {
        get {
            return columns[index]
        }
        set {
            columns[index] = newValue
        }
    }
}

struct MosaicColumn {
    
    var columnHeight: CGFloat
    
    init() {
        columnHeight = 0
    }
    
    mutating func appnedHeight(_ height: CGFloat) {
        columnHeight += height
    }
}

extension MosaicColumn: Comparable {
    static func < (lhs: MosaicColumn, rhs: MosaicColumn) -> Bool {
        return lhs.columnHeight < rhs.columnHeight
    }
}

