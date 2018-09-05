//
//  MosaicViewController.swift
//  CollectionViewTest
//
//  Created by shiz on 2018/06/09.
//  Copyright © 2018年 shiz. All rights reserved.
//

import UIKit

private let reuseIdentifier = "mosaic"

class MosaicViewController: UIViewController {

    var profile: Profile!
    var layout: MosaicLayout!
    var collectionView: UICollectionView!
    

    lazy var emojis: [String] = {
       let array = [[String]](repeating: ["🐻","🌝","🐶","🐱","😈","🐷","🐼","🐧"], count: 100)
        return array.flatMap { $0 }
    }()
    
    lazy var colors: [UIColor] = {
        let array = [[UIColor]](repeating: [#colorLiteral(red: 1, green: 0.4003497443, blue: 0.4329250241, alpha: 1), #colorLiteral(red: 0.2007934418, green: 1, blue: 0.1549067714, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9542052063, green: 0.9686274529, blue: 0.2353871143, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.1484400915, blue: 0.1652794546, alpha: 1), #colorLiteral(red: 0.8061914062, green: 0.09817105998, blue: 0.7610764065, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.04828146429, green: 0.04967377501, blue: 0.8680078125, alpha: 1)], count: 100)
        return array.flatMap { $0 }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = MosaicLayout()

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)

        collectionView.collectionViewLayout = layout
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        layout.delegate = self
        collectionView.dataSource = self
    }
}

extension MosaicViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        let color = colors[indexPath.item]
        
        cell.backgroundColor = color
        
//        let emoji = emojis[indexPath.item]
//
//        let l = UILabel()
//        l.text = emoji
//        l.textColor = .black
//        l.font = UIFont.systemFont(ofSize: 60)
//        l.translatesAutoresizingMaskIntoConstraints = false
//        cell.addSubview(l)
//        NSLayoutConstraint.activate([
//            l.centreXAnchor.constraint(equalTo: cell.centerXAnchor),
//            l.topAnchor.constraint(equalTo: cell.centerAnchor)
//            ])
//
        return cell
    }
}

extension MosaicViewController: MosaicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, cellTypeAt indexPath: IndexPath) -> CellType {
        return indexPath.item % 3 == 0 ? CellType.big : CellType.small
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: MosaicLayout, insetAt: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func heightForSmallMosaicCell() -> CGFloat {
        return 50
    }
    
    
}
