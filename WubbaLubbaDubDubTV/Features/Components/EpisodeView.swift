import SwiftUI

struct EpisodeView: View {
    let episode: EpisodeEntity
    var namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(episode.name)
                .font(.title2.bold())
                .foregroundStyle(.black)

            HStack(spacing: 16) {
                Label(episode.code, systemImage: "tv")
                    .font(.subheadline)
                    .foregroundStyle(.black)

                if let airDate = episode.airDate {
                    Label(AirDateFormatter.format(airDate), systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(.black)
                }
            }

            Divider()

            HStack {
                Label("\(episode.characterIDs.count) Characters", systemImage: "person.3.fill")
                    .font(.subheadline)
                    .foregroundStyle(.black)
            }
        }
        .matchedTransitionSource(id: "episode_\(episode.id)", in: namespace)
        .background(Color.rmYellow)
    }
}
