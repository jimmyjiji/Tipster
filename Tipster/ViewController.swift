//
//  ViewController.swift
//  Tipster
//
//  Created by Jimmy Ji on 12/10/15.
//  Copyright © 2015 Jimmy Ji. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tipAmount: UILabel!
    @IBOutlet weak var billAmount: UITextField!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var taxAmount: UILabel!
    
    @IBOutlet weak var onePerson: UILabel!
    @IBOutlet weak var twoPerson: UILabel!
    @IBOutlet weak var threePerson: UILabel!
    @IBOutlet weak var fourPerson: UILabel!
    @IBOutlet weak var fadeInCalculator: UIView!
    @IBOutlet weak var billAndLogoView: UIView!
    let amountChanged = 100.00
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(red: 204/255, green: 229/255, blue: 255, alpha: 1)
        self.fadeInCalculator.backgroundColor = UIColor(red: 204/255, green: 229/255, blue: 255, alpha: 1)
        self.billAndLogoView.backgroundColor = UIColor(red: 204/255, green: 229/255, blue: 255, alpha: 1)
        
       
        
        tipAmount.text = "$0.00"
        onePerson.text = "$0.00"
        //moveDown()
        //fadeOut()
        self.fadeInCalculator.alpha = 0.0

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func moveUp(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.billAndLogoView.frame.origin.y += 200
            }, completion: completion)  }
    
    func moveDown(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.billAndLogoView.frame.origin.y -= 200
            }, completion: completion)  }
    
    func fadeIn(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.fadeInCalculator.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.fadeInCalculator.alpha = 0.0
            }, completion: completion)
    }
    
    @IBAction func getBillAmount(sender: AnyObject) {
        if (billAmount.text != nil) {
            fadeIn()
            moveUp()
        } else if (billAmount.text == nil) {
            fadeOut()
            moveDown()
        }
        var tipPercentages = [0.15, 0.18, 0.2, 0.25]
        let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        
        
        let billDouble = NSString(string: billAmount.text!).doubleValue
        let tax = 0.08875 * billDouble
            
        taxAmount.text = String(format: "$%.2f", tax)

        let tip = billDouble * tipPercentage
        let total = tip + billDouble + tax
        let one = total
        let two = total/2
        let three = total/3
        let four = total/4
        
        
        tipAmount.text = String(format: "$%.2f", tip)
        onePerson.text = String(format: "$%.2f", one)
        twoPerson.text = String(format: "$%.2f", two)
        threePerson.text = String(format: "$%.2f", three)
        fourPerson.text = String(format: "$%.2f", four)
        
    }
}

