import UIKit
import SwiftUI
import KeyboardKit
import QuantumSDK

class Scanner: ObservableObject {
    @Published var value = 0
    @Published var connection = ""
    @Published var barcodeString = ""
    @Published var uhfTagData = ""
    @Published var debugInfo = ""
    @Published var cards: [String: NSNumber] = [:]
    @Published var valueHasChangedForBarcode = false
    @Published var rfidCardData = ""
    @Published var deviceNotConnected = true
    @Published var uhfScanIsFinished = false
    let ipc = IPCDTDevices.sharedDevice()!
    // fjshbifuhbsiufhsdiufhisdufbw
    init() {
        
        print("Scanner initializing...")
        // Set dev key
        do {
            try IPCIQ.register()!.setDeveloperKey("")
            print("Developer key set successfully")
        } catch {
            print("Failed to set developer key: \(error)")
        }
        
        // Set delegate and connect to hardware
        ipc.addDelegate(self)
        ipc.connect()
        
        // Get the initial connection state to show on screen
        connectionState(ipc.connstate)
        
        // Initialize UHF module
        
    }
    
    
}

extension Scanner: IPCDTDeviceDelegate {
    func connectionState(_ state: Int32) {
        print("Connection state changed: \(state)")
        
        // Update screen with connection state
        switch state {
        case 0:
            self.connection = "disconnected"
            self.barcodeString = ""
            debugInfo += "Device disconnected\n"
            break
            
        case 1:
            self.connection = "connecting..."
            self.barcodeString = ""
            debugInfo += "Device connecting\n"
            break
            
        case 2:
            self.connection = "connected"
            self.deviceNotConnected = false
            initializeUHF()
           // intitializeRFID()
            debugInfo += "Device connected\n"
            break
            
        default:
            debugInfo += "Unknown connection state: \(state)\n"
            break
        }
    }
    /*
     func startScanningRFID(){
     do{
     
     let cardData = try ipc.mfRead(1, address: 4, length: 32)
     print("\(cardData)")
     } catch {
     print("error reading card data \(error.localizedDescription)")
     }
     }
     */
    
    func startBarcodeScanning() async throws {
        do {
            ipc.connect()
            try ipc.barcodeStartScan()
        } catch {
            throw error
        }
    }
    func barcodeData(_ barcode: String!, type: Int32) {
        self.barcodeString = barcode
        print("Barcode detected: \(barcode ?? "")")
        debugInfo += "Barcode: \(barcode ?? "")\n"
    }
    
    func intitializeRFID() {
        do{
            
            try ipc.rfInit(1)
            print("RFID initialized")
        } catch {
            print("Error initializing RFID module \(error.localizedDescription)")
            
        }
    }
    
    
    func initializeUHF() {
        do {
            try ipc.uhfInit(.US)
            print("UHF module initialized successfully")
            debugInfo += "UHF module initialized\n"
        } catch {
            print("Failed to initialize UHF module: \(error)")
            debugInfo += "UHF init failed: \(error)\n"
        }
    }
    
    func startUHFScan() async throws {
        print("Attempting to start UHF scan...")
        
        do{
            //initializeUHF()
            try ipc.uhfStartAutoRead(forTagType: .C, maxNumberOfTags: 1, maxTimeForTagging: 1, repeatCycleCount: 1)
        }catch{
            throw error
        }
        //        try ipc.uhfStartAutoRead(forTagType: .B, maxNumberOfTags: 1, maxTimeForTagging: 5, repeatCycleCount: 5)
        //  uhfTagDetected(pc: <#T##Int16#>, epc: <#T##NSData#>)
        print("UHF scan started for Type C tags (EPC Gen2)")
        //debugInfo += "UHF scan started\n"
        
    }
    
    func stopUHFScan() {
        do {
            try ipc.uhfStopAutoRead()
            print("UHF scan stopped")
            debugInfo += "UHF scan stopped\n"
        } catch {
            print("Failed to stop UHF scan: \(error)")
            debugInfo += "UHF scan stop failed: \(error)\n"
        }
    }
    
    func uhfTagDetected(_ pc: UInt16, epc: Data) {
        
        DispatchQueue.main.async{
            assert(Thread.isMainThread, "uhfTagDetected called on a background thread!")
            let cardID = "\(epc)"
            print(epc as NSData)
            //   var dattoNS = epc as NSData
            let byteArray = [UInt8](epc)
            let byteString = byteArray.map { String(format: "%02x", $0) }.joined(separator: "")
            self.uhfTagData = byteString
            self.debugInfo += byteString
            var nReads = self.cards[cardID]?.intValue ?? 0
            // self.debugInfo += "nreads \(nReads)\n"
            nReads += 1
            self.cards[cardID] = NSNumber(value: nReads)
            // self.debugInfo += "epc \(epc)\n"
            // self.debugInfo += "cardID \(cardID)\n"
            //  self.debugInfo += "nreads \(nReads)\n"
            var log = ""
            
            do {
                // Stop the auto-read process
                try self.ipc.uhfStopAutoRead()
                
                // Read user data from the UHF tag
                //      let userData = try self.ipc.uhfReadTypeCTagData(forEPC: epc, password: 0, targetMemoryBank: .RFU, startingAddress: 0, dataLength: 4)
                
                // Since userData is non-optional, no need for 'if let'
                //  log += "Read EPC: \(epc), userdata: \(userData)\n"
                //self.debugInfo += String(decoding: epc, as: UTF8.self)
                //  self.debugInfo += log
            } catch {
                // If any error occurs during the stop or read operation, log the failure
                log += "Operation failed with error: \(error)\n"
            }
            
        }
    }
    //rf delegates
    
    /// Support functions
    
    func mifareAuthenticate(cardIndex: Int32, address: Int32, key: [UInt8]?) throws {
        var keyData: Data? = nil
        if key == nil {
            let defaultMifareKey: [UInt8] = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
            keyData = Data(defaultMifareKey)
        }
        try ipc.mfAuth(byKey: cardIndex, type: 0x41, address: address, key: keyData)
    }
    
    func mifareSafeWrite(cardIndex: Int32, address: Int32, data: [UInt8], key: [UInt8]?) throws {
        guard address >= 4 else {
            return
        }
        
        var lastAuth: Int32 = -1
        var addr = address
        var written = 0
        while written < data.count {
            if (addr % 4) == 3 {
                addr += 1
                continue
            }
            if lastAuth != (addr / 4) {
                lastAuth = addr / 4
                try mifareAuthenticate(cardIndex: cardIndex, address: addr, key: key)
            }
            let block = data.subArray(written, len: min(16, data.count - written))
            
            var bytesWritten: Int32 = 0
            try ipc.mfWrite(cardIndex, address: addr, data: Data(block), bytesWritten: &bytesWritten)
            written += Int(bytesWritten)
            addr += 1
        }
    }
    
    func mifareSafeRead(cardIndex: Int32, address: Int32, length: Int, key: [UInt8]?) throws -> [UInt8] {
        var data = [UInt8]()
        var lastAuth: Int32 = -1
        var addr = address
        var read = 0
        while read < length {
            if (addr % 4) == 3 {
                addr += 1
                continue
            }
            if lastAuth != (addr / 4) {
                lastAuth = addr / 4
                try mifareAuthenticate(cardIndex: cardIndex, address: addr, key: key)
            }
            
            let block = try ipc.mfRead(cardIndex, address: addr, length: 16)
            data.append(contentsOf: block)
            read += block.count
            addr += 1
        }
        return data
    }
    
    func dfStatus2String(status: UInt8) -> String {
        switch (status) {
        case 0x00:
            return "OPERATION_OK"
        case 0x0C:
            return "NO_CHANGES"
        case 0x0E:
            return "OUT_OF_EEPROM_ERROR"
        case 0x1C:
            return "ILLEGAL_COMMAND_CODE"
        case 0x1E:
            return "INTEGRITY_ERROR"
        case 0x40:
            return "NO_SUCH_KEY"
        case 0x7E:
            return "LENGTH_ERROR"
        case 0x9D:
            return "PERMISSION_DENIED"
        case 0x9E:
            return "PARAMETER_ERROR"
        case 0xA0:
            return "APPLICATION_NOT_FOUND"
        case 0xA1:
            return "APPL_INTEGRITY_ERROR"
        case 0xAE:
            return "AUTHENTICATION_ERROR"
        case 0xAF:
            return "ADDITIONAL_FRAME"
        case 0xBE:
            return "BOUNDARY_ERROR"
        case 0xC1:
            return "PICC_INTEGRITY_ERROR"
        case 0xCD:
            return "PICC_DISABLED_ERROR"
        case 0xCE:
            return "COUNT_ERROR"
        case 0xDE:
            return "DUPLICATE_ERROR"
        case 0xEE:
            return "EEPROM_ERROR"
        case 0xF0:
            return "FILE_NOT_FOUND"
        case 0xF1:
            return "FILE_INTEGRITY_ERROR"
        default:
            return "UNKNOWN"
        }
    }
    
    func dfCommand(description: String, cardIndex: Int32, data: [UInt8]) -> Bool {
        do {
            var status: UInt8 = 0
            let r = try ipc.iso14Transceive(cardIndex, data: Data(data), status: &status)
            let statusStr = dfStatus2String(status: status)
            print("\(description) succeeded with status \(statusStr)(\(status)) and response: \(r.hexString)")
            return true
        } catch {
            print("\(description) failed: \(error.localizedDescription)")
        }
        return false
    }
    
    // RF delegates
    func rfCardRemoved(_ cardIndex: Int32) {
        print("\nCard removed")
    }
    
    func rfCardDetected(_ cardIndex: Int32, info: DTRFCardInfo!) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        print("\(info.typeStr!) card detected")
        print("Serial: \(info.uid.hexString)")
        rfidCardData = info.uid.hexString
        
        var success = true
        switch (info.type) {
        case .CARD_MIFARE_DESFIRE:
            Thread.sleep(forTimeInterval: 0.3)
            
            do {
                let ats = try ipc.iso14GetATS(cardIndex)
                print("ATS Data: \(ats.hexString)")
            } catch {
                print("Get ATS failed: \(error.localizedDescription)")
                success = false
            }
            
            let SELECT_APPID_MASTER: [UInt8] = [0x5A, 0x00, 0x00, 0x00]
            let AUTH_ROUND_ONE: [UInt8] = [0xAA, 0x00]
            
            if !dfCommand(description: "Select master application", cardIndex: cardIndex, data: SELECT_APPID_MASTER) {
                success = false
            }
            
            if !dfCommand(description: "Authenticate round 1", cardIndex: cardIndex, data: AUTH_ROUND_ONE) {
                success = false
            }
            
        case .CARD_MIFARE_MINI, .CARD_MIFARE_CLASSIC_1K, .CARD_MIFARE_CLASSIC_4K, .CARD_MIFARE_PLUS:
          /*  do {
                let dataToWrite: [UInt8] = [0xFF, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F]
                try mifareSafeWrite(cardIndex: cardIndex, address: 8, data: dataToWrite, key: nil)
                print("Mifare write complete!")
            } catch {
                print("Mifare write failed: \(error.localizedDescription)")
                success = false
            } */
            
            do {
                let block = try mifareSafeRead(cardIndex: cardIndex, address: 8, length: 4 * 16, key: nil)
                print("Mifare read complete: \(block.hexString)")
            } catch {
                print("Mifare read failed: \(error.localizedDescription)")
                success = false
            }
            
        case .CARD_MIFARE_ULTRALIGHT, .CARD_MIFARE_ULTRALIGHT_C:
            Thread.sleep(forTimeInterval: 0.5)
            do {
                let block = try ipc.mfRead(cardIndex, address: 8, length: 16)
                print("Mifare read complete: \(block.hexString)")
            } catch {
                print("Mifare read failed: \(error.localizedDescription)")
                success = false
            }
            
            do {
                try ipc.mfUlcAuth(byKey: cardIndex, key: "BREAKMEIFYOUCAN!".data(using: .ascii))
                print("Mifare authenticate complete")
            } catch {
                print("Mifare authenticate failed: \(error.localizedDescription)")
                success = false
            }
            
            do {
                let block = try ipc.mfRead(cardIndex, address: 8, length: 16)
                print("Mifare read complete: \(block.hexString)")
            } catch {
                print("Mifare read failed: \(error.localizedDescription)")
                success = false
            }
            
            do {
                try ipc.mfWrite(cardIndex, address: 0x2C, data: "12345678abcdefgh!".data(using: .ascii), bytesWritten: nil)
                print("Mifare write complete")
            } catch {
                print("Mifare write failed: \(error.localizedDescription)")
                success = false
            }
        case .CARD_UNKNOWN:
            print("unknown card")
        case .CARD_ISO14443A:
            print("unknown card")

        case .CARD_ISO15693:
            print("unknown card")

        case .CARD_ISO14443B:
            print("unknown card")

        case .CARD_FELICA:
            print("unknown card")

        case .CARD_ST_SRI:
            print("unknown card")

        case .CARD_PAYMENT_A:
            print("unknown card")

        case .CARD_PICOPASS_15693:
            print("unknown card")

        case .CARD_PICOPASS_14443B:
            print("unknown card")

        case .CARD_EPASSPORT:
            print("unknown card")

        case .CARD_PAYMENT_B:
            print("unknown card")

        @unknown default:
            print("unknown card")

        }
    }
}
extension Data {
    var hexString: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
extension Array {
    func subArray(_ start: Int, len: Int) -> Array {
        let end = Swift.min(start + len, self.count)
        return Array(self[start..<end])
    }
}

extension Array where Element == UInt8 {
    var hexString: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}


