//
//  ViewController.swift
//  MemeMe
//
//  Created by Wei Yang on 6/10/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var navToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    // topTextField.center.y = imageView.center.y + constant
    @IBOutlet weak var topTextFieldCenterYContraint: NSLayoutConstraint!
    // bottomTextField.center.y = imageView.center.y + constant
    @IBOutlet weak var bottomTextFieldCenterYContraint: NSLayoutConstraint!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(), // black text border color
        NSForegroundColorAttributeName : UIColor.whiteColor(), // white text color
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -4.0 //a negative value for stroke width creates both a fill and stroke.
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view, typically from a nib.
        
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

        resetToLanchState(self)
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
        
        // take a photo
        if sender.tag == 0 {
            imagePicker.sourceType = .Camera
        }
        // otherwise, pick a image from photolibrary
        
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
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //move the meme text to proper position
        ressetMemeTextFieldPositon()
    }
    
    // set the top/bottom text field position to 0.2/0.8 to the image
    func ressetMemeTextFieldPositon() {
        var imageScaledHeight = imageView.frame.height
        if let image = imageView.image {
            imageScaledHeight = min(image.size.height * imageView.frame.width/image.size.width, imageView.frame.height)
        }
        
        topTextFieldCenterYContraint.constant = -imageScaledHeight * 0.3
        bottomTextFieldCenterYContraint.constant = imageScaledHeight * 0.3
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // avoid to save meme if sharing is canceled or something is wrong
        activityViewController.completionWithItemsHandler = { (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) in
            if completed {
                self.save(memedImage)
            }
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
        
    }
    
    // reset the top/bottom text, remove the image & disable share button
    @IBAction func resetToLanchState(sender: AnyObject) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imageView.image = nil
        
        ressetMemeTextFieldPositon()
        
        // disable share button as no image is picked at first
        shareButton.enabled = false
    }
    
    func save(memedImage: UIImage) {
        print("save meme")
        //Create the meme
        
    }
    
    func generateMemedImage() -> UIImage
    {
        // hide the toolbar
        hideToolbar(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
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
        textField.text = ""
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

