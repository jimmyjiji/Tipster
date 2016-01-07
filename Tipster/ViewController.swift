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
        if billAmount.text == "" {
            fadeOut()
        } else if billAmount.text != "" && billAmount.text?.characters.count > 1 {
            fadeIn()
        } else if billAmount.text != "" {
            fadeIn()
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
        tesseract.image = image.g8_grayScale()
        tesseract.recognize()
        
     
        let text = tesseract.recognizedText
        if text != nil {
            print(text)
            print("##################################")
            let result = parseText(text)
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
    
    func parseText(text: String) -> String {
                let containsTotal = text.lowercaseString.containsString("otal")
                if containsTotal {
                    let startIndex = text.lowercaseString.rangeOfString("otal")?.endIndex
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
                            displayError("Found an total... but no price!")
                            return ""
                        }
                    }
                    displayError("Couldnt find new line char!")
                    return ""

            } else {
                    displayError("Couldn't find a total!")
                    return ""
        }
        
    }
    
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

    
    func displayError(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message:
            errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.addActivityIndicator()
        dismissViewControllerAnimated(true, completion: {
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.image = self.scaleImage(selectedPhoto, maxDimension: 640)
            self.enhanceImage()
            self.performImageRecognition(self.image!)
        })
       
    }
    
    func enhanceImage() {
        let easyImage = Image(UIImage: self.image!)!
        let weights = [
            1,  4,  6,  4, 1,
            4, 16, 24, 16, 4,
            6, 24, 36, 24, 6,
            4, 16, 24, 16, 4,
            1,  4,  6,  4, 1,
        ]
        let gaussianFilter = easyImage.map { x, y, pixel in
            easyImage[(y - 2)...(y + 2)][(x - 2)...(x + 2)].map {
                Pixel.weightedMean(zip(weights, $0))
                } ?? pixel
        }
        self.image = gaussianFilter.UIImage

        let binarize = easyImage.map { $0.gray < 128 ? Pixel.black : Pixel.white }
        self.image = binarize.UIImage
    }
    
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

