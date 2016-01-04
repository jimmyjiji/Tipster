//
//  ViewController.swift
//  Tipster
//
//  Created by Jimmy Ji on 12/10/15.
//  Copyright © 2015 Jimmy Ji. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var tipAmount: UILabel!
    @IBOutlet weak var billAmount: UITextField!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var taxAmount: UILabel!
    @IBOutlet weak var billMove: UIView!
    
    @IBOutlet weak var onePerson: UILabel!
    @IBOutlet weak var twoPerson: UILabel!
    @IBOutlet weak var threePerson: UILabel!
    @IBOutlet weak var fourPerson: UILabel!
    @IBOutlet weak var fadeInCalculator: UIView!
    var activityIndicator:UIActivityIndicatorView!
    var image: UIImage!
    let amountChanged = 100.00
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(red: 204/255, green: 229/255, blue: 255, alpha: 1)
        self.fadeInCalculator.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 255, alpha: 1)
        self.billMove.backgroundColor = UIColor(red: 204/255, green: 229/255, blue: 255, alpha: 1)
       
        
        tipAmount.text = "$0.00"
        onePerson.text = "$0.00"
        
        self.fadeInCalculator.alpha = 0.0

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func fadeIn(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.fadeInCalculator.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.fadeInCalculator.alpha = 0.0
            }, completion: completion)
    }
    
    
    @IBAction func haveBill(sender: UITextField) {
        if (billAmount.text == "") {
            fadeOut()
            //moveUp()
        } else if (billAmount.text != "" && billAmount.text?.characters.count > 1) {
            fadeIn()
        } else if (billAmount.text != "") {
            fadeIn()
            //moveDown()
        }
    }
    
    @IBAction func getBillAmount(sender: AnyObject) {
     
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
    
    
    @IBAction func getPictureBill(sender: UIButton) {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imageFromSource.sourceType = UIImagePickerControllerSourceType.Camera
            
        } else {
            imageFromSource.sourceType =
                UIImagePickerControllerSourceType.PhotoLibrary
        }
        self.presentViewController(imageFromSource, animated: false, completion: nil)
        
        }
    
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract()
        tesseract.language = "eng+fra"
        
        tesseract.engineMode = .TesseractCubeCombined
        
        tesseract.pageSegmentationMode = .Auto
        
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        
     
        let text = tesseract.recognizedText
        if (text != nil) {
            print(text)
            print("##################################")
            let test = parseText(text)
            print(test)
            billAmount.text = test
            fadeIn()
        } else {
            print("Empty Text")
        }
        removeActivityIndicator()
    }
    
    func parseText(text: String) -> String {
       
                let containsTotal = text.lowercaseString.containsString("total")
                if containsTotal {
                    let startIndex = text.lowercaseString.rangeOfString("total")?.endIndex
                    let newString = text.substringFromIndex(startIndex!)
                    let endIndex = newString.rangeOfString("\n")?.endIndex
                    if endIndex != nil {
                        let newerString = newString.substringToIndex(endIndex!)
                        var finalString = newerString.stringByReplacingOccurrencesOfString("$", withString: "")
                        finalString = finalString.stringByReplacingOccurrencesOfString(";", withString: "")
                        finalString = finalString.stringByReplacingOccurrencesOfString(",", withString: "")
                        finalString = finalString.stringByReplacingOccurrencesOfString(":", withString: "")
                        finalString = finalString.stringByReplacingOccurrencesOfString("'", withString: "")
                        finalString = finalString.stringByReplacingOccurrencesOfString("/^[A-Za-z]+$/", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                        finalString = finalString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        
                        if finalString != "" {
                            return finalString
                        } else {
                            let alertController = UIAlertController(title: "Error", message:
                                "Found a total, but no price! Take a better picture fool", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            return ""
                        }
                    }
                    let alertController = UIAlertController(title: "Error", message:
                        "Couldn't find new line char. Take a better picture fool", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return ""

            } else {
                    let alertController = UIAlertController(title: "Error", message:
                        "Couldn't find total. Take a better picture fool", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                return ""
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        image = scaleImage(selectedPhoto, maxDimension: 640)
        
        addActivityIndicator()
        
        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(self.image)
        })    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
}

