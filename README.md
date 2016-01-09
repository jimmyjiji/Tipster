# Tipster

**Really basic Tip Calculator through Swift**

This app is mainly for me to get familiar with the Swift language as well as proper usage of XCode. Here you have 
a simple calculator that calculates the tax and tip required for the total bill from a subtotal. The calculator provides
ways to evenly split the bill up to 4 people. 

*More People coming soon.*

#Scanning Functionality!

The app now has receipt scanning functionality. In case for whatever reason you are too lazy to type in the bill, you can simply take a picture of the receipt and it will scan the photo for the word "total" and input the result into the bill statement. 

The framework used for optical character recognition (OCR) is **Tesseract**.
The framework used for binarization is **EasyImagy** by koher

*Image scanning works significantly better once gaussian filter and binarization filter is set on image*

As of 1/8/2016, it takes about 6~ seconds to read an image.

As of 1/9/2016, it takes about 3~ seconds to read an image.
![Sample Image](https://github.com/jimmyjiji/Tipster/blob/master/Sample%20Tipster.jpg)
