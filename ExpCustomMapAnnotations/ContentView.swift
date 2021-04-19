//
//  ContentView.swift
//  ExpCustomMapAnnotations
//
//  Created by Anders Munck on 01/04/2021.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var annotations:[StopAnnotation]?
    
    @State private var polyLines:[MKPolyline] = []
    
    let location = LocationManager()
    
    
    var body: some View {
        VStack {
            
            if location.userLocation != nil {
                
                MapView(userLocation: location.userLocation, annotations: $annotations)
                    .padding()
            }
            
            
            Image(systemName: annotations != nil ? "mappin.circle.fill" : "mappin.circle")
                .onTapGesture {
                    if annotations == nil {
                        annotations = StopAnnotation.exampleArray
                    } else {
                        annotations = nil
                    }
                }
        }
        .onAppear { location.start() }
        .onChange(of: annotations, perform: { value in
            
            
            print("changed annotations")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
