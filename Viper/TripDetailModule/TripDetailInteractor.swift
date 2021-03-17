
import Combine
import MapKit
class TripDetailInteractor {
    //MARK: PRIVATE LET
    private let trip : Trip
    private let model : DataModel
    
    //MARK: PRIVATE VAR
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: PUBLISHED VAR
    @Published var totalDistance: Measurement<UnitLength> = Measurement(value: 0, unit: .meters)
    @Published var wayPoints : [Waypoint] = []
    @Published var directions : [MKRoute] = []
    
    //MARK: LET
    let mapInfoProvider : MapDataProvider
    
    //MARK: VAR
    var tripName: String { trip.name }
    var tripNamePublisher: Published<String>.Publisher { trip.$name }
    
    
    
    //MARK: PUBLISHED
    
    init(trip : Trip, model : DataModel, mapInfoProvider : MapDataProvider) {
        
        self.model = model
        self.trip = trip
        self.mapInfoProvider = mapInfoProvider
        
        trip.$waypoints
            .assign(to: \.wayPoints, on: self)
            .store(in: &cancellable)
        
        trip.$waypoints
            .flatMap{ mapInfoProvider.totalDistance(for: $0) }
            .map{Measurement(value: $0, unit: UnitLength.meters)}
            .assign(to: \.totalDistance, on: self)
            .store(in: &cancellable)
        
        trip.$waypoints
            .setFailureType(to: Error.self)
            .flatMap{mapInfoProvider.directions(for: $0)}
            .catch{_ in Empty<[MKRoute], Never>()}
            .assign(to: \.directions, on: self)
            .store(in: &cancellable)
    }
    
    func setTripName(_ name: String){
        trip.name = name
    }
    
    func save(){
        model.save()
    }
    
    func addWayPoint(){
        trip.addWaypoint()
    }
    
    func moveWaypoint(fromOffsets: IndexSet, toOffset: Int){
        trip.waypoints.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    func deleteWaypoint(atOffsets: IndexSet){
        trip.waypoints.remove(atOffsets: atOffsets)
    }
    
    func updateWaypoints(){
        trip.waypoints = trip.waypoints
    }
}
