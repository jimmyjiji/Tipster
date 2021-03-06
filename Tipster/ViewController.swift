//
//  ViewController.swift
//  Tipster
//
//  Created by Jimmy Ji on 12/10/15.
//  Copyright © 2015 Jimmy Ji. All rights reserved.
//

import UIKit
import EasyImagy

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var tipAmount: UILabel!
    @IBOutlet weak var billAmount: UITextField!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var taxAmount: UILabel!
    @IBOutlet weak var billMove: UIView!
    @IBOutlet weak var taxPercent: UITextField!
    
    @IBOutlet weak var morePeopleTextField: UITextField!
    @IBOutlet weak var onePerson: UILabel!
    @IBOutlet weak var twoPerson: UILabel!
    @IBOutlet weak var threePerson: UILabel!
    @IBOutlet weak var fourPerson: UILabel!
       @IBOutlet weak var fadeInCalculator: UIView!
    
    @IBOutlet weak var morePeopleLabel: UILabel!
    var activityIndicator:UIActivityIndicatorView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        applyGradient()
        self.fadeInCalculator.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 255, alpha: 1)
        tipAmount.text = "$0.00"
        onePerson.text = "$0.00"
        taxPercent.text = "8.875"
        morePeopleTextField.text = "5"
        self.fadeInCalculator.alpha = 0.0
        
        let defaults = NSUserDefaults.standardUserDefaults()
        tipControl.selectedSegmentIndex = defaults.integerForKey("saveTip")
        
    }
    /**
     Applies gradient to app
    */
    func applyGradient() {
        let topColor = UIColor(red: 204/255, green: 229/255, blue: 255, alpha: 1)
        let bottomColor = UIColor(red: 51/255, green: 153/255, blue: 255, alpha: 1)
        let gradientColors = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /**
     Closes the keyboard on tap
     Removes keyboard observer
    */
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     Fades in the calculator portion of Tipster
    */
    func fadeIn(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.fadeInCalculator.alpha = 1.0
            }, completion: completion)  }
    /**
     Fades out the calculator portion of Tipster
     */
    func fadeOut(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.fadeInCalculator.alpha = 0.0
            }, completion: completion)
    }
    /**
     Shake to clear bill!
     */
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            billAmount.text = ""
            getBillAmount(self)
            fadeOut()
        }
    }
    /**
     Saves if the tip percentage has changed
    */
    @IBAction func tipPercentChanged(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(tipControl.selectedSegmentIndex, forKey: "saveTip")
        defaults.synchronize()
        
    }
    /**
     Obtains number of people value and updates calculator
    */
    @IBAction func getPeopleValue(sender: AnyObject) {
       
        let moreValue = NSString(string: morePeopleTextField.text!).doubleValue
        var tipPercentages = [0.15, 0.18, 0.2, 0.25]
        let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        
        
        let billDouble = NSString(string: billAmount.text!).doubleValue
        let tax = NSString(string: taxPercent.text!).doubleValue / 100
        
        let taxOverall = tax * billDouble
        
        taxAmount.text = String(format: "$%.2f", taxOverall)
        
        let tip = billDouble * tipPercentage
        let total = tip + billDouble + taxOverall
        
        let more = total/moreValue
        if moreValue != 0 {
            morePeopleLabel.text = String(format: "$%.2f", more)
        } else {
            morePeopleLabel.text = "$0.00"
        }
    }
    /**
     Moves keyboard accordingly to if user is editing number of people
    */
    @IBAction func morePeopleTouched(sender: AnyObject) {
           NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    /**
     Moves keyboard accordingly to if user is editing number of people
    */
    @IBAction func morePeopleEnd(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    /**
     Checks if the Bill text field has a value. 
     If the text field has a value, the calculator will fade in 
     Otherwise, it will stay faded out
     */
    @IBAction func haveBill(sender: UITextField) {
        if billAmount.text == "" {
            fadeOut()
        } else if billAmount.text != "" && billAmount.text?.characters.count > 1 {
            fadeIn()
        } else if billAmount.text != "" {
            fadeIn()
        }
    }
    /**
     Gets tax amount
    */
    
    @IBAction func getTaxAmount(sender: AnyObject) {
        getBillAmount(self)
    }
    /**
     Obtains the total bill by adding tax and tip from the bill text field
     */
    @IBAction func getBillAmount(sender: AnyObject) {
        
        var tipPercentages = [0.15, 0.18, 0.2, 0.25]
        let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        
        
        let billDouble = NSString(string: billAmount.text!).doubleValue
        let tax = NSString(string: taxPercent.text!).doubleValue / 100
            
        let taxOverall = tax * billDouble
        
        taxAmount.text = String(format: "$%.2f", taxOverall)
        
        let tip = billDouble * tipPercentage
        let total = tip + billDouble + taxOverall
        let one = total
        let two = total/2
        let three = total/3
        let four = total/4
        let tempMore = total/5
        
        
        tipAmount.text = String(format: "$%.2f", tip)
        onePerson.text = String(format: "$%.2f", one)
        twoPerson.text = String(format: "$%.2f", two)
        threePerson.text = String(format: "$%.2f", three)
        fourPerson.text = String(format: "$%.2f", four)
        morePeopleLabel.text = String(format: "$%.2f", tempMore)
        
    }
    
    /**
     When "Take a picture of the Bill!" button is pressed, this method opens up the camera if there is a 
     camera source available. Otherwise, it will simply go to your photo library.
     */
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
    
    /**
     Allows uploading of receipts from photo library
    */
    @IBAction func uploadPicture(sender: AnyObject) {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        
        
        imageFromSource.sourceType =
                UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(imageFromSource, animated: false, completion: nil)
    }
    /**
     Performs what happens after the picture is taken
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.addActivityIndicator()
        dismissViewControllerAnimated(true, completion: {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.image = self.scaleImage(selectedPhoto, maxDimension: 640)
            self.binarizeImage()
            self.gaussianFilter()
            self.performImageRecognition(self.image!)
        })
        
    }
    /**
     Uses the Tesseract framework to perform the Image recognition
     image: The image it performs the image recognition on
     */
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract()
        tesseract.language = "eng"
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_grayScale()
        tesseract.recognize()
        
     
        let text = tesseract.recognizedText
        if text != nil {
            //print(text)
            //print("##################################")
            let result = parseText(text, stringsToFind: ["Sub", "otal", "tota", "ota]", "cash", "$", "payment"])
            //print(result)
            billAmount.text = ""
            billAmount.text = billAmount.text?.stringByAppendingString(result)
            
            if result != "" {
                getBillAmount(self)
                fadeIn()
            }
        } else {
            getBillAmount(self)
            fadeOut()
            displayError("Empty Text")
        }
        removeActivityIndicator()
    }
    
    /**
     This method parses the text produced by the Tesseract framework.
     The method looks for the substring "otal" in the text and returns a double value in string
     text: String to be parsed
     return: the price to be put into bill amount
    */
    func parseText(text: String, stringsToFind: [String]) -> String {
        for (var i = 0; i < stringsToFind.count; i++) {
                let containsTotal = text.lowercaseString.containsString(stringsToFind[i])
                if containsTotal {
                    let startIndex = text.lowercaseString.rangeOfString(stringsToFind[i])?.endIndex
                    let newString = text.substringFromIndex(startIndex!)
                    let endIndex = newString.rangeOfString("\n")?.endIndex
                    if endIndex != nil {
                        let newerString = newString.substringToIndex(endIndex!)
                        var finalString = removeJunkFromString(newerString)
                        let matches = matchesForRegexInText("\\d+\\.\\d{2}", text: finalString)
                        finalString = matches.joinWithSeparator("")
                        if finalString != "" {
                            return finalString
                        } else if finalString == " " || finalString == "" {
                            let search = removeJunkFromString(text)
                            finalString = searchAroundTotal(search)
                            if finalString != "" {
                                return finalString
                            } else {
                                displayError("Found the string value \(stringsToFind[i]) ... but no valid price!")
                                return ""
                            }
                        }
                    }
                    displayError("Couldnt find new line char!")
                    return ""
            }
        }
        displayError("Couldn't find a total!")
        return ""
        
    }
    /**
     Removes unneccessary noise from string parsing 
     string: String to remove noise
     return: result parse
    */
    func removeJunkFromString(string: String) -> String{
        var text = string
        text = text.stringByReplacingOccurrencesOfString("$", withString: "")
        text = text.stringByReplacingOccurrencesOfString("'", withString: ".")
        text = text.stringByReplacingOccurrencesOfString(",", withString: ".")
        text = text.stringByReplacingOccurrencesOfString(" ", withString: "")
        return text
    }
    
    /**
     Last resort function that searches all values in the recognized text for a double value.
     It then takes sorts the array, takes the two largest values and see if multiplying by the tax
     rate is equivalent to the largest value. Otherwise, return nothing. 
     text: Overall recognized text that has had junk removed
     return: String value of subtotal
    */
    func searchAroundTotal(text: String) -> String{
        let matches = matchesForRegexInText("\\d+\\.\\d{2}", text: text)
        var doubleArray = matches.map{ Double($0) ?? 0 }
        doubleArray = doubleArray.sort()
        if doubleArray.count > 2 {
            let guessedSubTotal = doubleArray[doubleArray.count-2]
            let supposedTotal = doubleArray[doubleArray.count-1]
            let guessedTotal = guessedSubTotal * 1.08875
            if guessedTotal > supposedTotal-0.1 && guessedTotal < supposedTotal+0.1 {
                let string = String(format: "%0.2f", guessedSubTotal)
                return string
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    /**
     Helper function that looks for a regex value in a string 
     regex: the String representation of a regular expression
     text: the String that the regex is going to be applied on
     return: String array of the string parsed by regex
    */
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    /**
     Displays an Alert view with an error message 
     errorMessage: the error message to be displayed
     */
    func displayError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message:
            errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
   
    /**
     Binarizes the image to reduce noise
     */
    func binarizeImage() {
        let easyImage = Image(UIImage: image!)!
        let binarize = easyImage.map { $0.gray < 128 ? Pixel.black : Pixel.white }
        image = binarize.UIImage
    }
    /**
     Smooths the edges using gaussian blur
    */
    func gaussianFilter() {
        let imageToBlur = CIImage(image: image!)!
        let blurfilter = CIFilter(name: "CIGaussianBlur")!
        blurfilter.setValue("0.1", forKey:kCIInputRadiusKey)
        blurfilter.setValue(imageToBlur, forKey: "inputImage")
        self.image = UIImage(CGImage: CIContext(options:nil).createCGImage(blurfilter.outputImage!, fromRect:blurfilter.outputImage!.extent))
      
        
    }
    /*
     Scales the image taken to be more user friendly with Tesseract
     image: Image to be scaled 
     maxDimension: The max dimension of the image 
     return: Returns an UIImage
     */
    
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
    
    /**
     Adds a subview to demonstrate activity
     */
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    /**
     Removes the subview that demonstrates activity and destroys it
     */
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    /**
     Notification that keyboard has been shown
    */
    func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        var myFrame: CGRect = self.view.frame;
        myFrame.origin.y -= keyboardFrame.height;
        self.view.frame = myFrame;
        
    }
    
    /**
     Notification that keyboard has been hidden
    */
    func keyboardWillHide(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        var myFrame: CGRect = self.view.frame;
        myFrame.origin.y += keyboardFrame.height;
        self.view.frame = myFrame;
        
    }
}

