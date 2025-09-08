import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("禁煙情報")) {
                    DatePicker("禁煙開始日", selection: $settings.quitDate)

                    VStack(alignment: .leading) {
                        Text("１日の喫煙本数（本）")
                        TextField("20", value: $settings.cigarettesPerDay, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }

                    VStack(alignment: .leading) {
                        Text("タバコ１箱の価格（円）")
                        TextField("600", value: $settings.pricePerPack, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }

                    VStack(alignment: .leading) {
                        Text("タバコ１箱の本数（本）")
                        TextField("20", value: $settings.cigarettesPerPack, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                }

                Section {
                    Button("保存") {
                        // The data is already bound and updated in the settings object.
                        // We just need to dismiss the view.
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarItems(trailing: Button("閉じる") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
