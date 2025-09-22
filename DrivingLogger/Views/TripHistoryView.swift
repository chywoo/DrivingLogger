import SwiftUI

struct TripHistoryView: View {
    @StateObject var viewModel: TripHistoryViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.trips) { trip in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trip.startDate, style: .date)
                                .font(.headline)
                            HStack {
                                Text(trip.startDate, style: .time)
                                Text("—")
                                if let endDate = trip.endDate {
                                    Text(endDate, style: .time)
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(String(format: "%.2f mi", trip.distance / 1609.34))
                                .font(.headline)
                            
                            // ⭐️ 2. 기존의 복잡한 계산 대신 이 한 줄로 교체합니다.
                            Text(trip.formattedDuration)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.deleteTrip)
            }
            .navigationTitle("Trip History")
            .onAppear {
                viewModel.loadTrips()
            }
        }
    }
}


// MARK: - Xcode Preview
import SwiftData

// 1. 운행 기록이 있는 상태의 Preview
#Preview("With Data") {
    // 임시 인메모리 데이터베이스 설정
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, configurations: config)
    let context = container.mainContext
    
    // Preview를 위한 가짜 운행 기록 데이터 추가
    let sampleTrip1 = Trip(startDate: Date().addingTimeInterval(-3600), endDate: Date().addingTimeInterval(-1800), distance: 5471.7, route: [])
    let sampleTrip2 = Trip(startDate: Date().addingTimeInterval(-86400), endDate: Date().addingTimeInterval(-85000), distance: 12874.8, route: [])
    context.insert(sampleTrip1)
    context.insert(sampleTrip2)

    // 의존성 생성 및 View 렌더링
    let tripRepository = TripRepository(modelContext: context)
    let viewModel = TripHistoryViewModel(tripRepository: tripRepository)
    
    return TripHistoryView(viewModel: viewModel)
}

// 2. 운행 기록이 없는 비어있는 상태의 Preview
#Preview("Empty State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, configurations: config)
    let tripRepository = TripRepository(modelContext: container.mainContext)
    let viewModel = TripHistoryViewModel(tripRepository: tripRepository)
    
    // 여기서는 가짜 데이터를 추가하지 않음
    
    return TripHistoryView(viewModel: viewModel)
}

