//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Wei Yang on 6/11/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

class MemeColletionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // reset the layout
        resetFlowLayout(view.frame.size)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update Data in CollectionView
        collectionView?.reloadData()
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // make the layout properly when the phone orientation is changed
        // flowLayout will be nil when collection view is not load yet
        if flowLayout != nil {
            resetFlowLayout(size)
        }
    }
    
    func resetFlowLayout(size: CGSize) {
        let space: CGFloat = 3.0
        var dimension: CGFloat = 130.0
        let num = CGFloat(Int(size.width/dimension))
        dimension = (size.width - space * (num-1)) / num
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    // MARK: Collection View Data Source
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.row]
        
        // display the memedImage of meme
        cell.imageView.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
