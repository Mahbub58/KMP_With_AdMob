import Foundation
import SwiftUI
import GoogleMobileAds
import UIKit

struct InlineAdaptiveBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        // Create with a placeholder size; we'll set the inline size in updateUIView
        let bannerView = BannerView(adSize: AdSizeBanner)
        // Official AdMob iOS test banner ad unit ID
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"

        // Set delegates for load callbacks and ad size changes
        bannerView.delegate = context.coordinator
        bannerView.adSizeDelegate = context.coordinator

        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // Configure and load once when we have a container width and a root VC
        if !context.coordinator.didLoad {
            DispatchQueue.main.async {
                // Prefer the view's own bounds if available, then superview, then screen
                let widthCandidates: [CGFloat] = [uiView.bounds.width, uiView.superview?.bounds.width ?? 0, UIScreen.main.bounds.width]
                var rawWidth = widthCandidates.first(where: { $0 > 0 }) ?? UIScreen.main.bounds.width

                // Subtract safe area insets if a hosting VC is available
                if let vc = uiView.parentViewController() {
                    let insets = vc.view.safeAreaInsets
                    rawWidth -= (insets.left + insets.right)
                }

                // Clamp to supported inline adaptive range to avoid invalid width errors
                let isPad = UIDevice.current.userInterfaceIdiom == .pad
                let minWidth: CGFloat = 320
                let maxWidth: CGFloat = isPad ? 1024 : 728
                let containerWidth = max(min(rawWidth, maxWidth), minWidth)

                let adSize = currentOrientationInlineAdaptiveBanner(width: containerWidth)
                print("InlineAdaptiveBanner: rawWidth=\(rawWidth), clampedWidth=\(containerWidth), requested adSize=\(adSize.size)")
                uiView.adSize = adSize

                // Attach a root view controller from the responder chain or window
                if uiView.rootViewController == nil {
                    if let vc = uiView.parentViewController() {
                        uiView.rootViewController = vc
                        print("InlineAdaptiveBanner: rootViewController resolved from responder chain")
                    } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let window = windowScene.windows.first,
                              let root = window.rootViewController {
                        uiView.rootViewController = root
                        print("InlineAdaptiveBanner: rootViewController resolved from window")
                    }
                }

                // Load the ad when we have a root VC
                if uiView.rootViewController != nil {
                    print("InlineAdaptiveBanner: calling load(Request())")
                    uiView.load(Request())
                    context.coordinator.didLoad = true
                } else {
                    print("InlineAdaptiveBanner: rootViewController not set; scheduling retry")
                    context.coordinator.scheduleRetry(for: uiView)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, BannerViewDelegate, AdSizeDelegate {
        var didLoad = false
        private var loadRetryTimer: Timer?

        func scheduleRetry(for bannerView: BannerView) {
            if loadRetryTimer != nil { return }
            loadRetryTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self, weak bannerView] timer in
                guard let self = self, let view = bannerView else {
                    timer.invalidate(); return
                }
                // Try to resolve root VC again
                if view.rootViewController == nil {
                    if let vc = view.parentViewController() {
                        view.rootViewController = vc
                        print("InlineAdaptiveBanner: retry resolved rootViewController from responder chain")
                    } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let window = windowScene.windows.first,
                              let root = window.rootViewController {
                        view.rootViewController = root
                        print("InlineAdaptiveBanner: retry resolved rootViewController from window")
                    }
                }
                if view.rootViewController != nil && !self.didLoad {
                    print("InlineAdaptiveBanner: retry calling load(Request())")
                    view.load(Request())
                    self.didLoad = true
                    timer.invalidate()
                    self.loadRetryTimer = nil
                }
            }
        }
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("InlineAdaptiveBanner: Ad loaded successfully")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("InlineAdaptiveBanner: Failed to load ad: \(error.localizedDescription)")
        }

        // Respond to ad size changes for inline adaptive banners
        func adView(_ bannerView: BannerView, willChangeAdSizeTo size: AdSize) {
            print("InlineAdaptiveBanner: willChangeAdSizeTo width=\(size.size.width), height=\(size.size.height)")
            // Let intrinsic content size drive height; ensure layout updates
            bannerView.invalidateIntrinsicContentSize()
        }
    }

}

// Helper: find parent view controller from a UIView
private extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}


// Bridge to expose InlineAdaptiveBannerView as a UIViewController for KMP integration
@objc public class InlineAdaptiveBannerBridge: NSObject {
    @objc public static let shared = InlineAdaptiveBannerBridge()

    private override init() {
        super.init()
    }

    @objc public func createInlineAdaptiveBannerViewController() -> UIViewController {
        let view = InlineAdaptiveBannerView()
        return UIHostingController(rootView: view)
    }
}