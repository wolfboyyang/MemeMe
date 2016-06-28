//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Wei Yang on 6/10/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var navToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextFieldCenterYContraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldCenterYContraint: NSLayoutConstraint!
    
    var meme: Meme?
    
    var memedImageWidth: CGFloat = 0
    var memedImageHeight: CGFloat = 0
    var viewSize: CGSize = CGSize()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -4.0
    ]
    
    let MemeTextPorportion: CGFloat = 0.3

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSize = view.frame.size
        /*
            1. There should be two textfields, reading “TOP” and “BOTTOM” when a user opens the Meme Editor.
            2. Text should be center-aligned.
            3. Text should approximate the "Impact" font, all caps, white with a black outline.
            4. When a user taps inside a textfield, the default text should clear.
            5. When a user presses return, the keyboard should be dismissed.
         
         */
        func setMemeTextAttributes(textField: UITextField) {
            textField.defaultTextAttributes = memeTextAttributes
            textField.textAlignment = .Center
            textField.delegate = self
        }
        setMemeTextAttributes(topTextField)
        setMemeTextAttributes(bottomTextField)

        setMeme(meme)
        // let the image view be able to be tapped to hide/show toolbar
        imageView.userInteractionEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // diable camera button if not available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        // to be informed if the keyboard show/hide
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove the keyboard notificatons
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }

    // MemeMe does not need the satuse bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func pickAnImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        if sender.tag == 0 { // take a photo
            imagePicker.sourceType = .Camera
        } else { // pick a image from photolibrary
            imagePicker.sourceType = .PhotoLibrary
        }
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    // user don't want to pick an image now
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // an image is picked
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // show the image in the image view
        imageView.image = image
        
        ressetMemeTextFieldPositon()
        
        shareButton.enabled = true
        
        // close the image picker
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // user rotated the phone to another orientation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //move the meme text to proper position
        viewSize = size
        ressetMemeTextFieldPositon()
    }
    
    // set the top/bottom text field position according to viewSize & MemeTextPorportion
    func ressetMemeTextFieldPositon() {
        var scaledImageHeight = viewSize.height
        var scaledImageWidth = viewSize.width
        if let image = imageView.image {
            scaledImageHeight = floor(min(viewSize.width * image.size.height / image.size.width, viewSize.height))
            scaledImageWidth =  floor(scaledImageHeight * image.size.width / image.size.height)
        }
        // set the memedImage size for saving meme later
        memedImageWidth = scaledImageWidth
        memedImageHeight = scaledImageHeight
        
        topTextFieldCenterYContraint.constant = -scaledImageHeight * MemeTextPorportion
        bottomTextFieldCenterYContraint.constant = scaledImageHeight * MemeTextPorportion
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // avoid to save meme if sharing is canceled or something is wrong
        activityViewController.completionWithItemsHandler = { (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) in
            if completed {
                self.save(memedImage)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
        
    }
    
    // Close the editor and return to Sent Memes View
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setMeme(meme: Meme!) {
        if let meme = meme {
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            imageView.image = meme.image
            shareButton.enabled = true
        } else {
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            imageView.image = nil
            // disable share button as no image is picked
            shareButton.enabled = false
        }
        ressetMemeTextFieldPositon()
    }
    
    func save(memedImage: UIImage) {
        //Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage
    {
        // hide the toolbar
        hideToolbar(true)

        let x = floor(imageView.center.x - memedImageWidth * 0.5)
        let y = floor(imageView.center.y - memedImageHeight * 0.5)
        
        let memedImageRect = CGRectMake(x, y, memedImageWidth, memedImageHeight)

        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let screenImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        
        // create memedImage as subImage of screenImage
        let imageRef = screenImage.CGImage
        let memedImageRef = CGImageCreateWithImageInRect(imageRef, memedImageRect)
        
        let memedImage : UIImage = UIImage(CGImage: memedImageRef!)
        UIGraphicsEndImageContext()
        
        
        // show the toolbar
        hideToolbar(false)
        
        return memedImage
    }
    
    // user tap the image view
    @IBAction func tapped(sender: AnyObject) {
        // hide the toolbar to preview memedImage
        let hidden = topToolbar.hidden
        hideToolbar(!hidden)
    }
    
    func hideToolbar(hidden: Bool) {
        topToolbar.hidden = hidden
        navToolbar.hidden = hidden
    }
    
    // When a user taps inside a textfield, the default text should clear.
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    // make sure all input characters are in uppercase
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let upppercaseString = string.uppercaseString
        if upppercaseString == string {
            // all characters are in uppercase, go ahead
            return true
        }
        
        // some characters are in lowercase, change to the uppercase ones
        var newText: NSString
        newText = textField.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: upppercaseString)
        textField.text = newText as String
        
        return false
    }
    
    // When a user presses return, the keyboard should be dismissed.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    func keyboardWillShow(notification: NSNotification) {
        // move the whole view up when bottom text is editing
        if bottomTextField.editing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // move back the whole view to original place
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

