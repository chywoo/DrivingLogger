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

