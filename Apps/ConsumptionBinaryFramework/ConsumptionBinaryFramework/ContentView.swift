//
//  ContentView.swift
//  ConsumptionBinaryFramework
//
//  Created by Eidinger, Marco on 7/15/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: ChartsContentView()) {
                    Text("Charts")
                }
                NavigationLink(
                    destination: CoreContentView()) {
                    Text("Core Elements")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
