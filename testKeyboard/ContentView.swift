import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = Scanner()
    @State private var stuff = ""
    
    var body: some View {
        VStack {
            Text("Connection: \(scanner.connection)")
            Text("Barcode: \(scanner.barcodeString)")
            Text("UHF Tag: \(scanner.uhfTagData)")
            TextField("Enter", text: $stuff)
            
            Spacer()
            
            
            Button("Start UHF Scan") {
                //scanner.startUHFScan()
            }
            Spacer()
            
            Button("Stop UHF Scan") {
                scanner.stopUHFScan()
            }
            
            Spacer()
            
            
            Button("Intialize UHF"){
                scanner.initializeUHF()
            }
            
            Spacer()
            
            ScrollView {
                Text(scanner.debugInfo)
                    .font(.system(size: 12))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
