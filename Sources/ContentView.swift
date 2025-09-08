import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "lungs")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("I Stopped Smoking!")
        }
        .padding()
    }
}
