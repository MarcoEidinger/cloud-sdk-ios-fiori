//
//  ContentView.swift
//  SnapshotTestApp
//
//  Created by Eidinger, Marco on 7/15/20.
//  Copyright © 2020 SAP. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("This app has no visual content. Please run the app's unit tests to compare implementation with snapshot image references")
                .multilineTextAlignment(.center)
            Spacer()
            Text("Prerequiste: 'git submodule update' was executed to laod snapshot image references")
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
