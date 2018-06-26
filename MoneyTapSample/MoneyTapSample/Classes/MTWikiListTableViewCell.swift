//
//  MTWikiListTableViewCell.swift
//  MoneyTapSample
//
//  Created by Batman on 25/06/18.
//  Copyright © 2018 AnilKumar. All rights reserved.
//

import UIKit

class MTWikiListTableViewCell: UITableViewCell {

    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var subHeadLineLabel: UILabel!
    @IBOutlet weak var thumbNailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
