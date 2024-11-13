
# Keyboard-for-Linea-Pro-7I
This is a custom keyboard written in Swift and utilizes swiftUI and was created using KeyboardKit. This program is compatible with the Linea Pro 7i device. 

# How to install
Once you have your developer key, just paste it into the try IPCIQ.register()!.setDeveloperKey("<Your developer key>") method in the Scanner.swift class. In addition, you will also need to add your bundleId and appGroupId to the KeyboardViewController under the KeyboardApp Extension.

Follow the instruction in the QuantumSDK on how to configure your info.plist and your project. You will need to add add three privacy keys. Your info.plist at the end should resemble this:

![image](https://github.com/user-attachments/assets/ce0b4e61-758d-48c0-9c32-14c4f068db72)


you will also need to import the Foundation, CoreLocation, and QuantumSDK frameworks(Make sure this is at the root of your directory) into your project as well as the KeyboardKit package dependency.

![image](https://github.com/user-attachments/assets/2c0abb10-c423-409f-abd5-44e6ed55b6ad)


# How to use

Once you have everything installed on your device, it will resemble a normal iOS keyboard except it has a custom toolbar with three buttons: 

![image](https://github.com/user-attachments/assets/b3813e21-3109-4212-957a-4df27eaf9bb6)

When the device has not yet been connected, the three buttons on top will be grayed out and disabled. Once the device has been connected, then the buttons and the functions of the device will be available to you: 


![image](https://github.com/user-attachments/assets/9e4b102e-cbe1-4273-8e4a-981f838c5f50)

**RFID**: The RFID button is used to scan HF RFID Tags such as mifare. Once tapped, the device will contiously scan for RFID tags until it is tapped again or it successfully scans a tag and prints its content to the screen. 

**UHF**: when tapped, if there is a UHF tag nearby, it will scan it and print its contents out to the screen

**Barcode Scanner**: This activates the bar code scanner on the device. it will scan for 9 seconds or until it successfully scans a barcode. This can also be activated by pressing the buttons on the side of the device


