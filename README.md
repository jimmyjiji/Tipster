# Tipster

**Really basic Tip Calculator through Swift**

This app is mainly for me to get familiar with the Swift language as well as proper usage of XCode. Here you have 
a simple calculator that calculates the tax and tip required for the total bill from a subtotal. The calculator provides
ways to evenly split the bill up to the base value of 4 people. Beyond that there is a textfield that you can fill out. The calculator saves tip values inbetween uses. The calculator has set a base value of 8.875% tax as that is NYC tax rate. However it is adjustable. 


#Scanning Functionality!

The app now has receipt scanning functionality. In case for whatever reason you are too lazy to type in the bill, you can simply take a picture of the receipt and it will scan the photo for the word "Total" and input the result into the bill statement. *Works with varying success rates *

The framework used for optical character recognition (OCR) is **Tesseract**. Engine used is Tesseract and Cube.

The framework used for binarization is **EasyImagy** by koher


![Sample Image](https://github.com/jimmyjiji/Tipster/blob/master/Final.jpg)
