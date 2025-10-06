import SwiftUI
import GoogleMobileAds
@main
struct iOSApp: App {
    @StateObject private var consentManager = ConsentManager()
    init() {
        // Initialize Google Mobile Ads SDK
        if consentManager.canRequestAds {
            MobileAds.shared.start { initializationStatus in
                print("AppDelegate: Google Mobile Ads SDK initialized")
                print("AppDelegate: Initialization status: \(initializationStatus.adapterStatusesByClassName)")
            }
        }

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(consentManager)
                .onAppear {
                    consentManager.gatherConsent()
                }
        }
    }
}