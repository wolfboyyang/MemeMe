//
//  Meme.swift
//  MemeMe
//
//  Created by Wei Yang on 6/10/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

struct Meme {
    let topText: String
    let bottomText: String
    let image: UIImage
    let memedImage: UIImage
    
    var description: String {
        if topText.isEmpty {
            return bottomText
        } else if bottomText.isEmpty {
            return topText
        } else {
            return topText + "..." + bottomText
        }
    }
}
