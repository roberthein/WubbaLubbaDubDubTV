import SwiftUI

struct EpisodeView: View {
    let episode: EpisodeEntity
    var namespace: Namespace.ID

    var body: some View {
        ZStack {
            Image(episode.cellId)
                .resizable()
                .scaledToFill()
                .foregroundStyle(Color.rmYellow)

            VStack(alignment: .center, spacing: Padding.innerHalf) {
                Text(episode.name.uppercased())
                    .font(CustomFont.primaryTitle)
                    .foregroundStyle(Color.rmBlueDark)
                    .lineLimit(1)

                HStack(spacing: Padding.inner) {
                    Label(episode.code, systemImage: "tv")
                        .font(CustomFont.primarySubtitle)
                        .foregroundStyle(Color.rmBlueDark)

                    if let airDate = episode.airDate {
                        Label(AirDateFormatter.format(airDate), systemImage: "calendar")
                            .font(CustomFont.primarySubtitle)
                            .foregroundStyle(Color.rmBlueDark)
                    }
                }

                HStack {
                    Label("\(episode.characterIDs.count) Characters", systemImage: "person.3.fill")
                        .font(CustomFont.primarySubtitle)
                        .foregroundStyle(Color.rmBlueDark)
                }
            }
            .padding(.horizontal, Padding.outerDouble)
        }
        .matchedTransitionSource(id: "episode_\(episode.id)", in: namespace)
    }
}
