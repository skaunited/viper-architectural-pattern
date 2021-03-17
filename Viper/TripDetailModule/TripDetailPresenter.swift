import SwiftUI
import Combine

class TripDetailPresenter: ObservableObject {
    
    //MARK: PRIVATE LET
    private let interactor : TripDetailInteractor
    //MARK: PRIVATE VAR
    private var cancellables = Set<AnyCancellable>()
    private let router : TripDetailRouter
    
    //MARK: PUBLISHED VAR
    @Published var distanceLabel : String = "Calculating..."
    @Published var waypoints : [Waypoint] = []
    
    
    @Published var tripName: String = "No Name"
    let setTripName : Binding<String>
    
    init(interactor: TripDetailInteractor) {
        self.interactor = interactor
        self.router = TripDetailRouter(mapProvider: interactor.mapInfoProvider)
        
        setTripName = Binding<String>(
            get: { interactor.tripName },
            set: { interactor.setTripName($0) }
        )
        
        interactor.tripNamePublisher
            .assign(to: \.tripName, on: self)
            .store(in: &cancellables)
        
        interactor.$totalDistance
            .map{ "Total distance:" + MeasurementFormatter().string(from: $0) }
            .replaceNil(with: "Calculating...")
            .assign(to: \.distanceLabel, on: self)
            .store(in: &cancellables)
        
        interactor.$wayPoints
            .assign(to: \.waypoints, on: self)
            .store(in: &cancellables)
    }
    
    func save(){
        interactor.save()
    }
    
    func makeMapView() -> some View{
        TripMapView(presenter: TripMapViewPresenter(interactor: interactor))
    }
    
    func addWaypoint(){
        interactor.addWayPoint()
    }
    
    func didMoveWaypoint(fromOffsets : IndexSet, toOffset: Int){
        interactor.moveWaypoint(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    func didDeleteWaypoint(_ atOffsets: IndexSet){
        interactor.deleteWaypoint(atOffsets: atOffsets)
    }
    
    func cell(for waypoint: Waypoint) -> some View{
        let destination = router.makeWayPointView(for: waypoint)
            .onDisappear(perform: interactor.updateWaypoints)
        return NavigationLink( destination: destination){
            Text(waypoint.name)
        }
    }
}
