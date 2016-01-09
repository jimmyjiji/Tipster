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
    
    @IBOutlet weak var onePerson: UILabel!
    @IBOutlet weak var twoPerson: UILabel!
    @IBOutlet weak var threePerson: UILabel!
    @IBOutlet weak var fourPerson: UILabel!
    @IBOutlet weak var fadeInCalculator: UIView!
    
    var activityIndicator:UIActivityIndicatorView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(red: 204/255, green: 229/255, blue: 255, alpha: 1)
        self.fadeInCalculator.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 255, alpha: 1)
        self.billMove.backgroundColor = UIColor(red: 204/255, green: 229/255, blue: 255, alpha: 1)
        tipAmount.text = "$0.00"
        onePerson.text = "$0.00"
        taxPercent.text = "8.875"
        self.fadeInCalculator.alpha = 0.0

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /**
     Closes the keyboard on tap
    */
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
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
     Obtains the total bill by adding tax and tip from the bill text field
     */
    @IBAction func getBillAmount(sender: AnyObject) {
     
        var tipPercentages = [0.15, 0.18, 0.2, 0.25]
        let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        
        
        let billDouble = NSString(string: billAmount.text!).doubleValue
        let tax = NSString(string: taxPercent.text!).doubleValue
            
        let taxOverall = tax * billDouble
        
        taxAmount.text = String(format: "$%.2f", tax)
        
        let tip = billDouble * tipPercentage
        let total = tip + billDouble + taxOverall
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
        tesseract.engineMode = .TesseractOnly
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_grayScale()
        tesseract.recognize()
        
     
        let text = tesseract.recognizedText
        if text != nil {
            print(text)
            print("##################################")
            let result = parseText(text, stringsToFind: ["otal", "tota", "ota]", "cash", "$"])
            print(result)
            billAmount.text = ""
            billAmount.text = billAmount.text?.stringByAppendingString(result)
            
            if result != "" {
                getBillAmount(self)
                fadeIn()
            }
        } else {
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
                        var finalString = newerString.stringByReplacingOccurrencesOfString("$", withString: "")
                        finalString = finalString.stringByReplacingOccurrencesOfString(",", withString: ".")
                        finalString = finalString.stringByReplacingOccurrencesOfString(" ", withString: "")
                        let matches = matchesForRegexInText("\\d+\\.\\d{2}", text: finalString)
                        finalString = matches.joinWithSeparator("")
                        if finalString != "" {
                            return finalString
                        } else if finalString == " " || finalString == "" {
                            displayError("Found an \(stringsToFind[i]) ... but no price!")
                            return ""
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
        blurfilter.setValue("0.08", forKey:kCIInputRadiusKey)
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
}

