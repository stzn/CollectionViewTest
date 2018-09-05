//
//  ProfileCell.swift
//  CollectionViewTest
//
//  Created by shiz on 2018/06/09.
//  Copyright © 2018年 shiz. All rights reserved.
//

import UIKit

final class ProfileCell: UICollectionViewCell {

    @IBOutlet weak var icon: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var birthday: UILabel!
    @IBOutlet weak var content: UILabel!
    
    
    static let identifier = "profile"
    var profile: Profile? = nil {
        didSet {
            self.icon.text = profile?.iconLabel
            self.name.text = profile?.name
            self.birthday.text = profile?.birthday
            self.content.text = profile?.content
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }    
}

