import SwiftUI

struct RandomImageView: View {
    let index: Int = .random(in: 1 ... 24)

    var body: some View {
        Image("rm-\(index)")
    }
}
