//
//  CanvasViewModel.swift
//  DroneProtoZero
//
//  Created by boland on 2/28/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation

enum CanvasSection: Int {
    case status
    case hardware
    case steps
}

struct CanvasViewModel {
    
    var sectionCount = 3
    
    func cellHeight(for indexPath: IndexPath) -> Float {
        guard let section = sectionType(for: indexPath) else { return 0 }
        switch section {
        case .status:
            return 55.0
        case .hardware:
            return 70.0
        default:
            return 228.0
        }
    }
    
    func sectionType(for indexPath: IndexPath) -> CanvasSection? {
        guard let section = CanvasSection(rawValue: indexPath.section) else { return CanvasSection.steps }
        return section
    }
    
    
    
    
}
