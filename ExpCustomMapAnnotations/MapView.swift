//
//  MapView.swift
//  ExpCustomMapAnnotations
//
//  Created by Anders Munck on 01/04/2021.
//

import MapKit
import SwiftUI


struct MapView: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    let userLocation:CLLocationCoordinate2D?
    
    // Input
    @Binding var annotations: [StopAnnotation]?
    var polylines: [MKPolyline]?
    
    
    // MapView Functions
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        
        // Setup delegate
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // If userLocation is known, zoom to that
        if let userLocation = self.userLocation {
            
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
            
        }
        
        // Register custom annotation views
        mapView.register(StopAnnotationViewContainer.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(StopAnnotation.self))
        mapView.register(UserAnnotationViewContainer.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(UserAnnotation.self))
        
        // Show user location
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        
        addAnnotations(mapView)
        
    }
    
    private func addAnnotations(_ mapView: MKMapView) {
        
        
        // If stop annotations are updated, add them
        if let stopAnnotations = annotations {
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(stopAnnotations)
                
            
        } else {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        
        // Add polylines
        if let polyLines = polylines {
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlays(polyLines)
        }
    }
    
    
    
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        // MARK: FORMATTING
        
        // Polyline formatting
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        
        // Annotation formatting
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            var annotationView: MKAnnotationView?
            
            if annotation is MKUserLocation {
                
                let view = UserAnnotationViewContainer()
                annotationView = view
            }
            
            if annotation is StopAnnotation {
                
                let identifier = NSStringFromClass(StopAnnotation.self)
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
                
                if let annotation = annotation as? StopAnnotation, let view = view as? StopAnnotationViewContainer {
                    
                    view.isDraggable = true
                    view.number = (annotation.orderIndex ?? 0)
                    annotationView = view
                }
            }
            
            return annotationView
            
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
                switch newState {
                case .starting:
                    view.dragState = .dragging
                    
                    if let view = view as? StopAnnotationViewContainer {
                        view.dragging = true
                    }
                    
                    
                case .ending, .canceling:
                    view.dragState = .none
                    
                    if let view = view as? StopAnnotationViewContainer {
                        view.dragging = false
                    }
                default: break
                }
        }
        
        private func setupStopAnnotationView(for annotation: StopAnnotation, on mapView: MKMapView) -> MKAnnotationView? {
            
            let identifier = NSStringFromClass(StopAnnotation.self)
            let stopAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
            
            stopAnnotationView.zPriority = .min
            (stopAnnotationView as! StopAnnotationViewContainer).number = (annotation.orderIndex ?? 0) + 1
            
            return stopAnnotationView
        }
        
        
        
        
    }
    
}

// MARK: ANNOTATIONS




import UIKit

// Stop Annotation Views
class StopAnnotationViewContainer: MKAnnotationView {
    
    private let annotationFrame = CGRect(x: 0, y: 0, width: 40, height: 40)
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = annotationFrame
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        backgroundColor = .clear
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }

     var number: Int = 0 {
        didSet {
            updateView()
        }
    }

    public var dragging: Bool = false {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        let vc = UIHostingController(rootView: StopAnnotationView(number: number, dragging: dragging))
        
        // Add SwiftUI View
        if let view = vc.view {
            
            view.backgroundColor = .clear
            addSubview(view)
            view.frame = bounds
        }
        
    }
    
}


struct StopAnnotationView: View {
    
    // Input
    let number:Int
    let dragging: Bool
    
    // State
    @State var appeared:Bool = false
    @State var animate:Bool = false
    
    var body: some View {
        ZStack {
            
            if appeared {
                    
                Text("\(number)")
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(3)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(dragging ? Color.red : Color.blue)
                            .frame(width: 20, height: 20)
                    )
                
            } else {
                
                EmptyView()
                
            }
        }
        .frame(width: 40, height: 40, alignment: .bottom)
        .offset(x: 0, y: animate ? 0 : -40)
        .offset(x: 0, y: dragging ? -40 : 0)
        .onAppear {
            
            let delay = Double(number) * 0.05
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                appeared = true
                
                let animation = Animation.easeOut(duration: 0.3)
                withAnimation(animation) {
                    animate = true
                }
            }
        }
    }
}

// User Annotation Views
class UserAnnotationViewContainer: MKAnnotationView {
    private let annotationFrame = CGRect(x: 0, y: 0, width: 40, height: 40)

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = annotationFrame
        self.centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        self.backgroundColor = .clear
        _setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }

    func _setup() {
        backgroundColor = .clear
        
        let vc = UIHostingController(rootView: UserAnnotationView())
        if let view = vc.view {
            view.backgroundColor = .clear
            addSubview(view)
            view.frame = bounds
        }
       
    }
}

struct UserAnnotationView: View {
    
    
    var body: some View {
        ZStack {
            
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
            
        }
        .frame(width: 40, height: 40, alignment: .bottom)
    }
}

