import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Management")) {
                    Button("Export Data") {
                        // TODO: 데이터 내보내기 기능 구현
                    }
                    Button("iCloud Backup") {
                        // TODO: iCloud 백업 기능 구현
                    }
                }
                
                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
