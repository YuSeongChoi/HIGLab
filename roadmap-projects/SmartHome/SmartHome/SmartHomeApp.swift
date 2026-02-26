import SwiftUI

@main
struct SmartHomeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            DevicesView()
                .tabItem {
                    Label("기기", systemImage: "house")
                }
            
            BluetoothScanView()
                .tabItem {
                    Label("BLE 스캔", systemImage: "antenna.radiowaves.left.and.right")
                }
            
            NFCView()
                .tabItem {
                    Label("NFC", systemImage: "wave.3.right")
                }
        }
    }
}

#Preview {
    ContentView()
}
