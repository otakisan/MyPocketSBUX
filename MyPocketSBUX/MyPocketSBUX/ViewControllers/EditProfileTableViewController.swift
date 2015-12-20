//
//  EditProfileTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class EditProfileTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePictureImageView: PFImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    
    private static let bioPlaceHolder = "bio."
    
    var user : PFUser?
    
    @IBAction func touchUpInsideProfilePictureEditButton(sender: UIButton) {
        self.presentImagePickerController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "tapSaveBarButton:")
        
        self.initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func tapSaveBarButton(sender: UIButton){
        if let user = self.user {
            self.profilePictureImageView.file?.saveInBackground()
            user[userProfilePictureKey] = self.profilePictureImageView.file ?? NSNull()
            user[userDisplayNameKey] = self.nameTextField.text
            user[userBioKey] = self.bioTextView.text
            user[userEmailKey] = self.emailTextField.text
            
            user.saveInBackgroundWithBlock({ (isSuccess, error) -> Void in
                if !isSuccess {
                    print("failed to save the user profile")
                }
            })
        }
    }
    
    private func presentImagePickerController() {
        let detailView = UIImagePickerController()
        detailView.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        detailView.delegate = self
        
        self.presentViewController(detailView, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let profilePictureImage = ImageUtility.convertProfilePictureImage(selectedImage)
            self.profilePictureImageView.image = profilePictureImage
            if let profilePictureData = UIImageJPEGRepresentation(profilePictureImage, 0.5) {
                self.profilePictureImageView.file = PFFile(data: profilePictureData)
            }
        }
    }

    private func initialize() {
        self.navigationItem.title = "Edit Profile"

        self.nameTextField.delegate = self
        self.bioTextView.delegate = self
        self.emailTextField.delegate = self
        
        self.setUserData()
    }
    
    private func setUserData() {
        if let user = self.user {
            self.profilePictureImageView.file = user["profilePicture"] as? PFFile
            self.profilePictureImageView.loadInBackground({ (profilePictureImage, error) -> Void in
                if error != nil {
                    self.profilePictureImageView.backgroundColor = UIColor.lightGrayColor()
                }
            })
            
            self.nameTextField.text = user["displayName"] as? String
            self.idLabel.text = user.username
            self.bioTextView.text = user["bio"] as? String ?? EditProfileTableViewController.bioPlaceHolder
            self.emailTextField.text = user["email"] as? String
        }
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
