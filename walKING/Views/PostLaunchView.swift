import SwiftUI

struct PostLaunchView: View {
    @State private var currentTab = 0
    private let tabCount = 3

    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                ForEach(0..<tabCount, id: \.self) { index in
                    VStack {
                        Spacer()
                        Text("Welcome Tab \(index + 1)")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            // Dots indicator
            HStack(spacing: 8) {
                ForEach(0..<tabCount, id: \.self) { index in
                    Circle()
                        .fill(index == currentTab ? Color.accentColor : Color.gray.opacity(0.4))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.bottom, 24)

            HStack {
                Button(action: {
                    // On last tab, go to login; otherwise, skip to login
                    // Replace with your navigation logic
                    // Example: showLogin = true
                }) {
                    Text(currentTab == tabCount - 1 ? "Continue" : "Skip")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .animation(.easeInOut, value: currentTab)
    }
}

#Preview {
    PostLaunchView()
}
