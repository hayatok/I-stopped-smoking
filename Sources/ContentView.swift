import SwiftUI

struct ContentView: View {
    @StateObject private var settings = UserSettings()
    @State private var showingSettings = false
    @State private var showSuccessAnimation = false

    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3), Color.teal.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                // Main content
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack {
                            Image(systemName: "leaf.fill") // Using a system icon as a placeholder
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                                .frame(width: 80, height: 80)
                                .background(Color.white.opacity(0.5))
                                .clipShape(Circle())
                                .shadow(radius: 10)
                                .padding(.top, 20)

                            Text("今日も禁煙、お疲れ様です！")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }

                        // Statistics Section
                        StatisticsGridView(settings: settings)
                            .padding(.horizontal)

                        // Calendar Section
                        VStack {
                            Text("禁煙カレンダー")
                                .font(.headline)
                                .padding(.bottom, 5)
                            CalendarView(succeededDates: $settings.succeededDates)
                                .background(.regularMaterial)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                        // Daily Check-in Button
                        CheckInButton(settings: settings, showSuccessAnimation: $showSuccessAnimation)
                            .padding(.bottom, 20)
                    }
                }

                // Success Animation
                if showSuccessAnimation {
                    SuccessAnimationView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSuccessAnimation = false
                                }
                            }
                        }
                }
            }
            .navigationTitle("マイ禁煙ログ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
        }
    }
}

// MARK: - Subviews

struct StatisticsGridView: View {
    @ObservedObject var settings: UserSettings
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 15) {
            StatisticCard(
                iconName: "flame.fill",
                label: "継続日数",
                value: "\(calculateCurrentStreak()) 日",
                color: .orange
            )
            .opacity(isVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.5).delay(0.2), value: isVisible)

            StatisticCard(
                iconName: "checkmark.seal.fill",
                label: "合計成功",
                value: "\(settings.succeededDates.count) 日",
                color: .green
            )
            .opacity(isVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.5).delay(0.4), value: isVisible)

            StatisticCard(
                iconName: "yensign.circle.fill",
                label: "節約金額",
                value: "\(calculateMoneySaved()) 円",
                color: .blue
            )
            .opacity(isVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.5).delay(0.6), value: isVisible)
        }
        .onAppear {
            isVisible = true
        }
    }

    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = Date()
        while true {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            if settings.succeededDates.contains(components) {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                // Check if today is not yet marked. If so, start from yesterday.
                if streak == 0 && !calendar.isDateInToday(date) {
                     date = calendar.date(byAdding: .day, value: -1, to: date)!
                     continue
                }
                break
            }
        }
        return streak
    }

    private func calculateMoneySaved() -> Int {
        let pricePerCigarette = (settings.pricePerPack > 0 && settings.cigarettesPerPack > 0) ? settings.pricePerPack / Double(settings.cigarettesPerPack) : 0
        let moneySaved = Double(settings.succeededDates.count * settings.cigarettesPerDay) * pricePerCigarette
        return Int(moneySaved)
    }
}

struct StatisticCard: View {
    let iconName: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(15)
    }
}

struct CheckInButton: View {
    @ObservedObject var settings: UserSettings
    @Binding var showSuccessAnimation: Bool

    private var isAlreadyCheckedInToday: Bool {
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return settings.succeededDates.contains(todayComponents)
    }

    var body: some View {
        Button(action: {
            if !isAlreadyCheckedInToday {
                let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                settings.succeededDates.insert(todayComponents)
                withAnimation {
                    showSuccessAnimation = true
                }
            }
        }) {
            HStack {
                Image(systemName: isAlreadyCheckedInToday ? "checkmark.circle.fill" : "calendar.badge.plus")
                Text(isAlreadyCheckedInToday ? "今日の分は達成済み" : "今日の禁煙を達成！")
            }
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isAlreadyCheckedInToday ? Color.gray : Color.green)
            .cornerRadius(20)
            .shadow(color: .green.opacity(isAlreadyCheckedInToday ? 0 : 0.5), radius: 10)
            .scaleEffect(isAlreadyCheckedInToday ? 1.0 : 1.05)
            .animation(.spring(), value: isAlreadyCheckedInToday)
        }
        .disabled(isAlreadyCheckedInToday)
    }
}

struct SuccessAnimationView: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)

            ForEach(0..<10) { _ in
                Circle()
                    .fill(Color(hue: .random(in: 0...1), saturation: 1, brightness: 1))
                    .frame(width: .random(in: 10...30), height: .random(in: 10...30))
                    .offset(x: .random(in: -200...200), y: .random(in: -400...400))
                    .scaleEffect(scale)
                    .opacity(opacity)
            }

            VStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                Text("達成！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                scale = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.5)) {
                opacity = 0
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
