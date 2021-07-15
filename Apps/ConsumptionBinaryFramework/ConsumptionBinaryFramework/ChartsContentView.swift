//
//  ChartsContentView.swift
//  ConsumptionBinaryFramework
//
//  Created by Eidinger, Marco on 7/15/21.
//

import Foundation
import SwiftUI
import FioriCharts

struct ChartsContentView: View {
    var body: some View {
        ChartView(ChartModel(chartType: .line,
                             data: [[200, 170, 165, 143, 166, 82, 110]],
                             titlesForCategory: [["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul"]],
                             userInteractionEnabled: true,
                             selectionEnabled: true,
                             scaleXEnabled: true))
    }
}
