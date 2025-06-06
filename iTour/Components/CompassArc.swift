//
//  CompassArc.swift
//  iTour
//
//  Created by Ramdan on 21/05/25.
//

import SwiftUI

struct CompassArc: Shape {
    let startAngle: Double
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: Angle(degrees: -90 - startAngle),
            endAngle: Angle(degrees: -90 - endAngle),
            clockwise: true
        )
        return path.strokedPath(StrokeStyle(lineWidth: 15, lineCap: .round))
    }
}
