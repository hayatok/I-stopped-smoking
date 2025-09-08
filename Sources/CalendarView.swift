import SwiftUI

struct CalendarView: View {
    @Binding var succeededDates: Set<DateComponents>
    @State private var date = Date()

    private let calendar = Calendar.current
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY年 MMMM"
        return formatter
    }()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.date = self.calendar.date(byAdding: .month, value: -1, to: self.date) ?? self.date
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearFormatter.string(from: date))
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    self.date = self.calendar.date(byAdding: .month, value: 1, to: self.date) ?? self.date
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            let days = makeDays()
            let dayOfWeekHeaders = ["日", "月", "火", "水", "木", "金", "土"]

            HStack {
                ForEach(dayOfWeekHeaders, id: \.self) { header in
                    Text(header)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { day in
                    if let day = day {
                        DayView(day: day)
                    } else {
                        Rectangle().fill(Color.clear)
                    }
                }
            }
            .padding(10)
            .animation(.easeInOut, value: date)
            .gesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < -50 { // Swipe left
                            self.date = self.calendar.date(byAdding: .month, value: 1, to: self.date) ?? self.date
                        }
                        if value.translation.width > 50 { // Swipe right
                            self.date = self.calendar.date(byAdding: .month, value: -1, to: self.date) ?? self.date
                        }
                    }
            )
        }
    }

    private func makeDays() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }

        var days: [Date?] = []
        let startDate = monthInterval.start
        let endDate = monthInterval.end
        let startWeekday = calendar.component(.weekday, from: startDate) - 1

        // Add placeholders for days before the start of the month
        for _ in 0..<startWeekday {
            days.append(nil)
        }

        // Add days of the month
        var currentDate = startDate
        while currentDate < endDate {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return days
    }

    @ViewBuilder
    private func DayView(day: Date) -> some View {
        let dayNumber = calendar.component(.day, from: day)
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: day)
        let isSucceeded = succeededDates.contains(dayComponents)
        let isToday = calendar.isDateInToday(day)

        Text("\(dayNumber)")
            .fontWeight(.medium)
            .frame(width: 40, height: 40)
            .background(
                ZStack {
                    if isSucceeded {
                        Circle()
                            .fill(Color.green.opacity(0.8))
                            .shadow(color: .green, radius: 4)
                    }
                    if isToday {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 2)
                    }
                }
            )
            .foregroundColor(isSucceeded ? .white : .primary)
    }
}

// For Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample set of succeeded dates for the preview
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        let sampleSucceededDates: Set<DateComponents> = [
            calendar.dateComponents([.year, .month, .day], from: yesterday),
            calendar.dateComponents([.year, .month, .day], from: twoDaysAgo)
        ]

        return CalendarView(succeededDates: .constant(sampleSucceededDates))
            .padding()
    }
}
