import Foundation
import SwiftUI
import GoogleMobileAds
import UIKit

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test ad unit ID
        
        // Set the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            bannerView.rootViewController = window.rootViewController
        }
        
        // Set the delegate
        bannerView.delegate = context.coordinator
        
        // Load the ad
        let request = Request()
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("Banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner ad failed to load: \(error.localizedDescription)")
        }
    }
}

// Banner Ad Bridge for KMP integration
@objc public class BannerAdBridge: NSObject {
    @objc public static let shared = BannerAdBridge()
    
    private override init() {
        super.init()
    }
    
    @objc public func createBannerAdViewController() -> UIViewController {
        let bannerView = BannerAdView()
        return UIHostingController(rootView: bannerView)
    }
}