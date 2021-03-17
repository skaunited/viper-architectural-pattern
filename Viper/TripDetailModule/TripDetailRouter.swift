import SwiftUI
class TripDetailRouter {
    //MARK: PRIVATE LET
    private let mapProvider : MapDataProvider
    
    init(mapProvider : MapDataProvider) {
        self.mapProvider = mapProvider
    }
    
    func makeWayPointView(for waypoint: Waypoint) -> some View{
        let presenter = WaypointViewPresenter(
            waypoint: waypoint,
            interactor: WaypointViewInteractor(
                waypoint: waypoint,
                mapInfoProvider: mapProvider)
        )
        return WaypointView(presenter: presenter)
    }
}

