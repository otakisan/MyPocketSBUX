//
//  SignInViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/06/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, AccountSettingsViewControllerDelegate {

    @IBOutlet weak var myPocketIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBAction func touchUpInsideSignInButton(sender: UIButton) {
        // TODO: 入力値チェック（空、ASCII以外、等々）
        if let user = AccountManager.instance.signIn(self.myPocketIDTextField.text!, password: self.passwordTextField.text!) {
            UIAlertView(title: "\(user.myPocketId) signed in.", message: "success.", delegate: nil, cancelButtonTitle: "Close").show()
        }
        else {
            UIAlertView(title: "Failed to sign in.", message: "failed.", delegate: nil, cancelButtonTitle: "Close").show()
        }
        self.passwordTextField.text = ""
        self.changeControlUIStyle()
    }
    
    @IBAction func touchUpInsideSignOutButton(sender: UIButton) {
        AccountManager.instance.signOut()
        self.changeControlUIStyle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.changeControlUIStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeControlUIStyle() {
        // 活性・非活性その他の制御は、データの状態により変わるから、
        // それごとにクラスにして制御させる形にする。
        // 一心同体の密結合になるけど。
        if IdentityContext.sharedInstance.signedIn() {
            // TODO: コントロールのスタイルではないが…
            self.myPocketIDTextField.text = IdentityContext.sharedInstance.currentUserID
            
            self.myPocketIDTextField.enabled = false
            self.passwordTextField.enabled = false
            self.signInButton.hidden = true
            self.signOutButton.hidden = false
        }else{
            self.myPocketIDTextField.enabled = true
            self.passwordTextField.enabled = true
            self.signInButton.hidden = false
            self.signOutButton.hidden = true
        }
    }
    
    func createdAccount(myPocketId: String) {
        self.myPocketIDTextField.text = myPocketId
        self.passwordTextField.text = ""
        self.changeControlUIStyle()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? AccountSettingsViewController {
            vc.delegate = self
        }
    }
    

}
