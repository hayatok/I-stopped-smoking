import SwiftUI

struct ContentView: View {
    @StateObject private var settings = UserSettings()
    @State private var showingSettings = false

    // Timer to update the stats every second
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // State for the calculated statistics
    @State private var durationString: String = "0日 0時間 0分"
    @State private var cigarettesNotSmoked: Int = 0
    @State private var moneySaved: Double = 0.0

    // For animation
    @State private var isAnimatingLungs = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.green.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 100))
                        .foregroundColor(Color.green)
                        .scaleEffect(isAnimatingLungs ? 1.1 : 1.0)
                        .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 0)
                        .padding(.bottom, 20)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                isAnimatingLungs = true
                            }
                        }

                    Text("禁煙達成中！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 30)

                    VStack(spacing: 20) {
                        StatisticView(label: "禁煙継続時間", value: durationString, iconName: "timer")
                        StatisticView(label: "吸わなかった本数", value: "\(cigarettesNotSmoked) 本", iconName: "smoke.fill")
                        StatisticView(label: "節約できた金額", value: String(format: "%.0f 円", moneySaved), iconName: "yensign.circle.fill")
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(15)
                    .shadow(radius: 5)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("禁煙アプリ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
            .onReceive(timer) { _ in
                updateStatistics()
            }
            .onAppear(perform: updateStatistics)
        }
    }

    func updateStatistics() {
        let now = Date()
        guard settings.quitDate <= now else {
            self.durationString = "未来の時間は計算できません"
            self.cigarettesNotSmoked = 0
            self.moneySaved = 0
            return
        }

        let timeInterval = now.timeIntervalSince(settings.quitDate)

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute]
        self.durationString = formatter.string(from: timeInterval) ?? "計算中..."

        if settings.cigarettesPerDay > 0 {
            let cigarettesPerSecond = Double(settings.cigarettesPerDay) / (24.0 * 60.0 * 60.0)
            self.cigarettesNotSmoked = Int(timeInterval * cigarettesPerSecond)
        } else {
            self.cigarettesNotSmoked = 0
        }

        if settings.cigarettesPerPack > 0 && settings.pricePerPack > 0 {
            let pricePerCigarette = settings.pricePerPack / Double(settings.cigarettesPerPack)
            self.moneySaved = Double(self.cigarettesNotSmoked) * pricePerCigarette
        } else {
            self.moneySaved = 0
        }
    }
}

struct StatisticView: View {
    var label: String
    var value: String
    var iconName: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.accentColor)
                .frame(width: 40)

            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            Spacer()
        }
    }
}
