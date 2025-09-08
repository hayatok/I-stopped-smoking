import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    @State private var showingResetAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("喫煙データ設定")) {
                    VStack(alignment: .leading) {
                        Text("１日の平均喫煙本数（本）")
                        TextField("20", value: $settings.cigarettesPerDay, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading) {
                        Text("タバコ１箱の価格（円）")
                        TextField("600", value: $settings.pricePerPack, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading) {
                        Text("タバコ１箱の本数（本）")
                        TextField("20", value: $settings.cigarettesPerPack, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }

                Section(header: Text("データ管理")) {
                    Button(action: {
                        self.showingResetAlert = true
                    }) {
                        Text("全記録をリセット")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarItems(
                leading: Button("完了") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("記録をリセット"),
                    message: Text("本当にすべての禁煙記録を削除しますか？この操作は取り消せません。"),
                    primaryButton: .destructive(Text("リセット")) {
                        settings.succeededDates.removeAll()
                    },
                    secondaryButton: .cancel(Text("キャンセル"))
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settings: UserSettings())
    }
}
