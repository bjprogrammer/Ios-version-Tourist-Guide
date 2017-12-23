//
//  PlacesCell.swift
//  Photorama
//
//  Created by Ashish Singh on 01/05/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit

class PlacesCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var openNowLabel: UILabel!
    @IBOutlet var logoImage: UIImage!
    @IBOutlet var typeLabel: UILabel!
    
    //sets fonts of labels
    func updateLabels() {
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        nameLabel.font = bodyFont
        ratingLabel.font = bodyFont
        
        let captionFont = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        openNowLabel.font = captionFont
        typeLabel.font = captionFont
    }
}
