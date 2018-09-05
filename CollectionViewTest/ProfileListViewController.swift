//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by shiz on 2018/06/09.
//  Copyright © 2018年 shiz. All rights reserved.
//

import UIKit

class ProfileListViewController: UIViewController {
    
    var flowLayout: ColumnFlowLayout!
    var collectionView: UICollectionView!
    var people: [Profile] = [
        Profile(iconLabel: "😃",
                name: "山田太郎",
                birthday: "1991/1/23",
                content: "フリーランスエンジニアです。"),
        Profile(iconLabel: "😋",
                name: "佐藤二郎",
                birthday: "1988/2/8",
                content: "大阪府出身。"),
        Profile(iconLabel: "😜",
                name: "鈴木三郎",
                birthday: "1998/4/10",
                content: "実は某IT企業社長"),
        Profile(iconLabel: "😏",
                name: "後藤四郎",
                birthday: "1986/9/9",
                content: "自宅警備員。"),
        Profile(iconLabel: "😤",
                name: "伊藤五郎",
                birthday: "1977/10/10",
                content: "伊藤です。"),
        ]
    var mosaicViewController: MosaicViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout = ColumnFlowLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .black
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        
        let nib = UINib(nibName: "ProfileCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ProfileCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setNaviagtionItem()
    }
    
    private func setNaviagtionItem() {
        navigationItem.title = "名刺リスト"
        let item = UIBarButtonItem(title: "更新", style: .plain, target: self, action: #selector(performUpdate))
        navigationItem.rightBarButtonItem = item
        navigationController?.navigationBar.barTintColor = .white
    }

    @objc func performUpdate() {

        UIView.performWithoutAnimation {

            collectionView.performBatchUpdates({

                people[3].name = "変更したよ！！！！"

                collectionView.reloadItems(at: [IndexPath(item: 3, section: 0)])
            })
        }

        collectionView.performBatchUpdates({

            // 2 updates
            // index2の削除
            // index3のアイテムをindex0に移動する

            // delete item at index2
            // delete item at index3
            // insert item from index3 at index 0

            let movedPerson = people[3]

            // Delete from datasource by Desc
            people.remove(at: 3)
            people.remove(at: 2)

            // Insert into datasource by Asc
            people.insert(movedPerson, at: 0)

            collectionView.deleteItems(at: [IndexPath(item: 2, section: 0)])
            collectionView.moveItem(at: IndexPath(item: 3, section: 0), to: IndexPath(item: 0, section: 0))
        })
    }
    
//        @objc func performUpdate() {
//
//            // reason: 'attempt to delete and reload the same index path (<NSIndexPath: 0x6000015c82c0> {length = 2, path = 0 - 3})'
//            collectionView.performBatchUpdates({
//
//                people[3].name = "変更したよ！！！！"
//
//                let movedPerson = people[3]
//
//                people.remove(at: 3)
//                people.remove(at: 2)
//
//                people.insert(movedPerson, at: 0)
//                collectionView.reloadItems(at: [IndexPath(item: 3, section: 0)])
//                collectionView.deleteItems(at: [IndexPath(item: 2, section: 0)])
//                collectionView.moveItem(at: IndexPath(item: 3, section: 0), to: IndexPath(item: 0, section: 0))
//            })
//        }
    
    
}

// MARK: Data source

extension ProfileListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
        cell.profile = people[indexPath.row]
        return cell
    }
}

// MARK: Delegate
extension ProfileListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let navController = self.navigationController else { return }
        
        if mosaicViewController == nil {
            mosaicViewController = MosaicViewController()
        }
        mosaicViewController.profile = people[indexPath.item]
        
        navController.pushViewController(mosaicViewController, animated: true)
    }
}



