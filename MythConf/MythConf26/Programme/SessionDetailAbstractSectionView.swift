import SwiftUI

struct SessionDetailAbstractSectionView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Abstract")
                .font(.headline)
                .conferenceHeaderAccessibility(label: "Abstract")

            Text(text)
                .accessibilityLabel("Abstract")
                .accessibilityValue(text)
        }
    }
}

#Preview {
    SessionDetailAbstractSectionView(
        text: "A practical session about building inclusive conference apps with SwiftUI."
    )
}
