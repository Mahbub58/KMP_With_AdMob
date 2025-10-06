import SwiftUI
import UserMessagingPlatform

class ConsentManager: ObservableObject {
    @Published var canRequestAds = false
    @Published var isPrivacyOptionsRequired = false
    @Published var isConsentGathered = false
    
    func gatherConsent() {
        let parameters = RequestParameters()

        // For testing purposes, you can force a UMPDebugGeography of EEA or not EEA.
        let debugSettings = DebugSettings()
        debugSettings.testDeviceIdentifiers = ["TEST-DEVICE-HASHED-ID"]
        debugSettings.geography = .EEA
        parameters.debugSettings = debugSettings
        
        // Requesting an update to consent information should be called on every app launch.
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] requestConsentError in
            DispatchQueue.main.async {
                if let consentError = requestConsentError {
                    print("Error gathering consent: \(consentError.localizedDescription)")
                    return
                }
                
                self?.updateConsentStatus()
                
                // Load and present consent form if required
                ConsentForm.loadAndPresentIfRequired(from: nil) { [weak self] loadAndPresentError in
                    DispatchQueue.main.async {
                        if let consentError = loadAndPresentError {
                            print("Error presenting consent form: \(consentError.localizedDescription)")
                        }
                        
                        self?.updateConsentStatus()
                        self?.isConsentGathered = true
                    }
                }
            }
        }
    }
    
    func presentPrivacyOptionsForm() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No root view controller available")
            return
        }

        ConsentForm.presentPrivacyOptionsForm(from: rootViewController) { [weak self] formError in
            DispatchQueue.main.async {
                if let error = formError {
                    print("Error presenting privacy options form: \(error.localizedDescription)")
                }
                self?.updateConsentStatus()
            }
        }
    }
    
    private func updateConsentStatus() {
        canRequestAds = ConsentInformation.shared.canRequestAds
        isPrivacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }
}