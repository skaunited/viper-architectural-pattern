

import SwiftUI
import Combine

struct TripListCell: View {
  let imageProvider: ImageDataProvider = PixabayImageDataProvider() // this could be injected in the future
  @ObservedObject var trip: Trip

  @State private var images: [UIImage] = []
  @State private var cancellable: AnyCancellable?

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottomLeading) {
        SplitImage(images: self.images)
          .frame(width: geometry.size.width, height: geometry.size.height)
        BlurView()
          .frame(width: geometry.size.width, height: 42)
        Text(self.trip.name)
          .font(.system(size: 32))
          .fontWeight(.bold)
          .foregroundColor(.white)
          .padding(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 8))
      }
      .cornerRadius(12)
    }.onAppear() {
      self.cancellable = self.imageProvider.getEndImages(for: self.trip).assign(to: \.images, on: self)
    }
  }
}

#if DEBUG
struct TripListCell_Previews: PreviewProvider {
  static var previews: some View {
    let model = DataModel.sample
    let trip = model.trips[0]
    return TripListCell(trip: trip)
      .frame(height: 160)
      .environmentObject(model)
  }
}
#endif

struct BlurView: UIViewRepresentable {
  func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear
    let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(blurView, at: 0)
    NSLayoutConstraint.activate([
      blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
      blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
    ])
    return view
  }

  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BlurView>) {
  }
}
