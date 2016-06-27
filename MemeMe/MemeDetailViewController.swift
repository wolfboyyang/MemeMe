//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Wei Yang on 6/27/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var memedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the image to display
        imageView.image = memedImage
    }
    
}