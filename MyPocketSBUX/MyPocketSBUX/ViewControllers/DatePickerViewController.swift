//
//  DatePickerViewController.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/06.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    var delegate : DatePickerViewControllerDelegate?

    @IBAction func touchUpInsideOkButton(sender: UIButton) {
        self.delegate?.didOkDatePicker(self.datePicker.date)
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func touchUpInsideCancelButton(sender: UIButton) {
        self.delegate?.didCancelDatePicker(self.datePicker.date)
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

protocol DatePickerViewControllerDelegate {
    func didOkDatePicker(date: NSDate)
    func didCancelDatePicker(date: NSDate)
}
