//
//  MyPageTableViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/30.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MyPageTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        self.loginView()
    }
    
    private func didLoginUser(user: PFUser) {
        IdentityContext.sharedInstance.currentUserID = user.username ?? ""
        
        // ログイン後、通知許可を求める
        AccountManager.instance.registerForRemoteNotifications()

        // プッシュ通知
        NotificationUtility.instance.pushNotificationUserDidLogIn()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: - Table view data source

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

/**
 PFLogInViewController関連処理
 ログインビューのカスタムの仕方については、下記リンクの「Subclassing」のあたりが参考になるはず（未確認）
 https://parse.com/tutorials/login-and-signup-views
 あとは、ローカライズをどうするか。
 */
extension MyPageTableViewController: PFLogInViewControllerDelegate {
    
    func loginView() {
        if PFUser.currentUser() == nil {
            let loginView = PFLogInViewController()
            loginView.fields = PFLogInFields.Default
            loginView.logInView!.logo = UIImageView(image: UIImage(named: "LoginLogo"))
            loginView.delegate = self
            loginView.signUpController?.delegate = self
            loginView.signUpController?.signUpView?.logo = UIImageView(image: UIImage(named: "LoginLogo"))
            self.presentViewController(loginView, animated: true, completion: nil)
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        // Check if both fields are completed
        if (username.characters.count != 0 && password.characters.count != 0) {
            return true // Begin login process
        }
        
        let alert = UIAlertController(title: "入力不足です", message: "username, passwordの両方を入力してください。", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in}))
        logInController.presentViewController(alert, animated: true, completion: nil)
        
        return false
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.didLoginUser(user)

        logInController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        // アラートを表示。ログイン画面は残す
        let alert = UIAlertController(title: "", message: "ログインに失敗しました。", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in}))
        logInController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        // 何も処理をせず、再度viewDidAppearのときにログイン画面を表示する
        // 仮に、ナビゲーションで遷移してきた画面の上にログイン画面を出しているとしたら、ここで、ナビゲーション的に戻る操作をする
    }
}

extension MyPageTableViewController: PFSignUpViewControllerDelegate {
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [String : String]) -> Bool{
        // 事前チェックなし
        var informationComplete = true
        
        // loop through all of the submitted data
        for (_, value) in info {
            if (value.characters.count ?? 0 == 0) { // check completion
                informationComplete = false
                break
            }
        }
        
        // Display an alert if a field wasn't completed
        if (!informationComplete) {
            let alert = UIAlertController(title: "入力不足です", message: "username, passwordの両方を入力してください。", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in}))
            signUpController.presentViewController(alert, animated: true, completion: nil)
        }
        
        return informationComplete
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.didLoginUser(user)
        
        signUpController.dismissViewControllerAnimated(true, completion: nil)
        signUpController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        // アラートを表示。アカウント登録画面は残す
        let alert = UIAlertController(title: "", message: "登録に失敗しました。", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in}))
        signUpController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        // 何も処理をせず、戻る
    }
}
