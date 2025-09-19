import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    // SwiftData의 ModelContext를 환경 변수에서 가져옵니다.
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack {
                    Text("Today's Trip")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(viewModel.todaySummary)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                Button(action: {
                    viewModel.toggleDrivingState()
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isDriving ? Color.red : Color.blue)
                            .frame(width: 200, height: 200)
                            .shadow(radius: 10)
                        
                        Text(viewModel.isDriving ? "Stop Driving" : "Start Driving")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 50)
            .navigationTitle("Dashboard")
            .onAppear {
                // View가 나타날 때 ViewModel에 ModelContext를 설정합니다.
                viewModel.setModelContext(modelContext)
            }
            .sheet(isPresented: $viewModel.isDriving) {
                // 운행이 시작되면 지도 추적 뷰를 모달로 표시합니다.
                TrackingMapView(viewModel: viewModel)
            }
        }
    }
}

