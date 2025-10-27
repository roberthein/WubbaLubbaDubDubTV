import SwiftUI

struct CharacterView: View {
    let characterID: Int
    var namespace: Namespace.ID

    var body: some View {
        ZStack {
            Image("cell-small-\(cellId)")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.rmPinkLight)

            Text("character #\(characterID)".uppercased())
                .font(CustomFont.primaryTitle)
                .foregroundStyle(Color.rmBlueDark)
                .lineLimit(1)
                .padding(.horizontal, Padding.outerDouble)
        }
        .matchedTransitionSource(id: "character_\(characterID)", in: namespace)
        .rotationEffect(.degrees(rotation))
    }

    private var cellId: Int {
        CharacterEntity.mapToOneToThree(characterID)
    }

    private var rotation: Double {
        Double(cellId) * (cellId.isMultiple(of: 2) ? 1 : -1)
    }
}
