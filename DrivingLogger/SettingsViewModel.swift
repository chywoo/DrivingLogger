import Foundation

class SettingsViewModel: ObservableObject {
    @Published var appVersion: String
    
    init() {
        // 앱의 버전 정보를 가져옵니다.
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion = version
        } else {
            self.appVersion = "1.0"
        }
    }
}
