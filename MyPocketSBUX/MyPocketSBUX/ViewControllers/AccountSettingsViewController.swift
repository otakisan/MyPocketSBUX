//
//  AccountSettingsViewController.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/06/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class AccountSettingsViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: AccountSettingsViewControllerDelegate?

    @IBOutlet weak var myPocketIDTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reenterPasswordTextField: UITextField!
    
    @IBAction func touchUpInsideDoneBarButtonItem(sender: UIBarButtonItem) {
        let validationResult = self.valid()
        if validationResult.valid {
            let result = AccountManager.instance.createAccountAndChangeCurrentUser(self.myPocketIDTextField.text, emailAddress: self.emailAddressTextField.text, password: self.passwordTextField.text)
            if result.success {
                self.delegate?.createdAccount(self.myPocketIDTextField.text)
                self.navigationController?.popViewControllerAnimated(true)
            }
            else{
                UIAlertView(title: "Failed to create the account.", message: result.reason, delegate: nil, cancelButtonTitle: "Close.").show()
            }
        }else{
            UIAlertView(title: validationResult.reason, message: "Please make sure your input.", delegate: nil, cancelButtonTitle: "Close.").show()
        }
    }
    
    deinit {
        self.delegate = nil
    }
    
    func valid() -> (valid: Bool, reason: String) {
        // TODO: 空のパスワードでいいのか、等の細かいチェックは後々に。
        return self.passwordTextField.text == self.reenterPasswordTextField.text ?
        (valid: true, reason: "") : (valid: false, reason: "Difference between the passwords.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol AccountSettingsViewControllerDelegate {
    func createdAccount(myPocketId: String)
}