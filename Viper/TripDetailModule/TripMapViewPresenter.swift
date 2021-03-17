import MapKit
import Combine
class TripMapViewPresenter: ObservableObject {
    //MARK: LET
    let interactor : TripDetailInteractor
    
    //MARK: PUBLISHED VAR
    @Published var pins: [MKAnnotation] = []
    @Published var routes: [MKRoute] = []
    
    //MARK: PRIVATE VAR
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor : TripDetailInteractor) {
        self.interactor = interactor
        
        interactor.$wayPoints
            .map{
                $0.map{
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = $0.location
                    return annotation
                }
            }
            .assign(to: \.pins, on: self)
            .store(in: &cancellables)
        
        interactor.$directions
            .assign(to: \.routes, on: self)
            .store(in: &cancellables)
    }
}
