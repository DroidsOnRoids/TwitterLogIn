//
//  LoginButton.swift
//  twittersdksample
//
//  Created by Paweł Sternik on 07.12.2015.
//  Copyright © 2015 Paweł Sternik. All rights reserved.
//

import UIKit

class LoginButton: UIButton {

// MARK: Initial methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
// MARK: Setup 
    
    func setup() {
        setTitleColor(.whiteColor(), forState: .Normal)
        layer.borderWidth = 2.0
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderColor = UIColor.whiteColor().CGColor
        backgroundColor = .twitterColor()
    }

}
