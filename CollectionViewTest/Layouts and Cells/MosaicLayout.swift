//
//  MosaicLayout.swift
//  CollectionViewTest
//
//  Created by shiz on 2018/06/09.
//  Copyright © 2018年 shiz. All rights reserved.
//

import UIKit
import os.signpost

enum CellType {
    case big
    case small
}

protocol MosaicLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, cellTypeAt indexPath: IndexPath) -> CellType
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: MosaicLayout, insetAt: Int) -> UIEdgeInsets
    
    func heightForSmallMosaicCell() -> CGFloat
}

final class MosaicLayout: UICollectionViewLayout {
    
    weak var delegate: MosaicLayoutDelegate!
    
    var columns = MosaicColumns()
    
    // 全体のサイズ
    var contentBounds = CGRect.zero
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    var numberOfColumns = 3
    
    var rowHeight: CGFloat = 0.0
    
    private var contentWidth: CGFloat {
        get {
            let insets = collectionView!.contentInset
            return collectionView!.bounds.width - (insets.left + insets.right)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            let height = columns.smallestColumn.columnHeight
            return CGSize(width: contentWidth, height: height)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        
        return !newBounds.size.equalTo(cv.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        return cachedAttributes.filter { (attributes) -> Bool in
//            return rect.intersects(attributes.frame)
//        }
//    }
//
    
    override func prepare() {
        super.prepare()
        
        guard let _ = collectionView else { return }
        
        // clear
        reset()
        
        // for every item
        // prepare attributes
        // store attributes in cachedAttributesArray
        // union contentBounds with attributes.frame
        createAttributes()
    }
    

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var attributesArray = [UICollectionViewLayoutAttributes]()

        guard let firstMatchIndex = binarySearchAttributes(range: 0...cachedAttributes.endIndex, rect: rect) else { return attributesArray }

        for attributes in cachedAttributes[..<firstMatchIndex.item].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }

        for attributes in cachedAttributes[firstMatchIndex.item...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        return attributesArray
    }

    private func binarySearchAttributes(range: ClosedRange<Int>, rect: CGRect) -> IndexPath? {

        var lower = range.lowerBound
        var upper = range.upperBound

        while (true) {
            let current = (lower + upper) / 2
            let indexPath = IndexPath(item: current, section: 0)

            guard cachedAttributes.count > indexPath.item else { return nil }
            
            let attributes = cachedAttributes[indexPath.item]
            if rect.intersects(attributes.frame) {
                return indexPath
            } else if lower > upper {
                return nil
            } else {
                if attributes.frame.maxY < rect.minY {
                    lower = current + 1
                } else {
                    upper = current - 1
                }
            }
        }
    }
    
    
    private func createAttributes() {
        
        var smallCellIndexPathBuffer = [IndexPath]()
        var lastBigCellLeftSide = false
        
        for cellIndex in 0..<collectionView!.numberOfItems(inSection: 0) {
            
            (lastBigCellLeftSide, smallCellIndexPathBuffer) = createCellLayout(
                with: cellIndex,
                bigCellSide: lastBigCellLeftSide,
                cellBuffer:smallCellIndexPathBuffer)
        }
        
        if !smallCellIndexPathBuffer.isEmpty {
            addSmallCellLayout(at: smallCellIndexPathBuffer[0], atColumn: indexOfSmallestColumn())
            smallCellIndexPathBuffer.removeAll()
        }
        
    }
    
    func createCellLayout(with index: Int, bigCellSide: Bool, cellBuffer: [IndexPath]) -> (Bool, [IndexPath]) {
        
        let indexPath = IndexPath(item: index, section: 0)
        let type = cellType(index: indexPath)
        
        var newBuffer = cellBuffer
        var newSide = bigCellSide
        
        if type == .big {
            newSide = createBigCellLayout(with: indexPath, cellSide: bigCellSide)
        } else if type == .small {
            newBuffer = createSmallCellLayout(with: indexPath, buffer: newBuffer)
        }
        return (newSide, newBuffer)
    }
    
    func createBigCellLayout(with indexPath: IndexPath, cellSide: Bool) -> Bool {
        addBigCellLayout(at: indexPath, atColumn: cellSide ? 1 : 0)
        return !cellSide
    }
    
    func createSmallCellLayout(with indexPath: IndexPath, buffer: [IndexPath]) -> [IndexPath] {
        
        var newBuffer = buffer
        newBuffer.append(indexPath)
        if newBuffer.count >= 2 {
            let column = indexOfSmallestColumn()
            
            addSmallCellLayout(at: newBuffer[0], atColumn: column)
            addSmallCellLayout(at: newBuffer[1], atColumn: column)
            
            newBuffer.removeAll()
        }
        
        return newBuffer
    }
    
    
}

extension MosaicLayout {
    
    func addBigCellLayout(at indexPath: IndexPath, atColumn column: Int) {
        let cellHeight = layoutAttributes(with: .big, indexPath: indexPath, atColumn: column)
        
        columns[column].appnedHeight(cellHeight)
        columns[column + 1].appnedHeight(cellHeight)
    }
    
    func addSmallCellLayout(at indexPath: IndexPath, atColumn column: Int) {
        let cellHeight = layoutAttributes(with: .small, indexPath: indexPath, atColumn: column)
        
        columns[column].appnedHeight(cellHeight)
    }
    
    
    func layoutAttributes(with type: CellType, indexPath: IndexPath, atColumn column: Int) -> CGFloat {
        
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let frame = cellRect(with: type, at: indexPath, atColumn: column)
        
        layoutAttributes.frame = frame
        
        let cellHeight = layoutAttributes.frame.size.height + insetForCell().top
        
        cachedAttributes.append(layoutAttributes)
        
        return cellHeight
    }
    
    
    func cellRect(with type: CellType, at indexPath: IndexPath, atColumn column: Int) -> CGRect {
        
        var cellHeight = cellContentHeightFor(cellType: type, indexPath: indexPath)
        var cellWidth = cellContentWidthFor(cellType: type)
        
        var originX = CGFloat(column) * (contentWidth / CGFloat(numberOfColumns))
        var originY = columns[column].columnHeight
        
        let sectionInset = insetForCell()
        
        originX += sectionInset.left
        originY += sectionInset.top
        
        cellWidth -= sectionInset.right
        cellHeight -= sectionInset.bottom
        
        return CGRect(x: originX, y: originY, width: cellWidth, height: cellHeight)
    }
    
    func cellContentHeightFor(cellType type: CellType, indexPath: IndexPath) -> CGFloat {
        
        let height = delegate.heightForSmallMosaicCell()
        if indexPath.item % 3 == 0 {
            rowHeight = height * CGFloat(arc4random_uniform(3))
        }
        if type == .big {
            return rowHeight * 2
        }
        return rowHeight
    }
    
    func cellContentWidthFor(cellType type: CellType) -> CGFloat {
        
        let w = contentWidth / 3
        if type == .big {
            return w * 2
        }
        return w
    }
    
    func cellType(index indexPath: IndexPath) -> CellType {
        return delegate.collectionView(collectionView!, cellTypeAt: indexPath)
    }
    
    func insetForCell()-> UIEdgeInsets {
        return delegate.collectionView(collectionView!, layout: self, insetAt: 0)
    }
}

extension MosaicLayout {
    
    func indexOfSmallestColumn() -> Int {
        var index = 0
        
        for i in 1..<numberOfColumns {
            if columns[i] < columns[index] {
                index = i
            }
        }
        return index
    }
    
    func reset() {
        columns = MosaicColumns()
        cachedAttributes = [UICollectionViewLayoutAttributes]()
    }
    
}



