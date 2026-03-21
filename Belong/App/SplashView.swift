import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Text("Belong")
                .font(BelongFont.display())
                .foregroundStyle(BelongColor.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BelongColor.background)
    }
}

#Preview {
    SplashView()
}
