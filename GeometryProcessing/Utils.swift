//
//  Utils.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation

extension Array {
    /// Make consecutive elements of the array unique by given binary predicate
    public mutating func unique(by predicate: (Element, Element) -> Bool) {
        guard (!isEmpty) else { return }
        
        var firstIndex: Int = 0
        var lastUniqueIdx: Int = 0
        var firstElement: Element = self[0]
        
        for i in 1..<count {
            if (predicate(firstElement, self[i])) {
                continue
            } else {
                firstElement = self[i]
                swapAt(firstIndex + 1, i)
                firstIndex += 1
                lastUniqueIdx = firstIndex
            }
        }
        
        removeSubrange((lastUniqueIdx + 1)..<endIndex)
    }
    
    // Make array elements unique by given predicate
    public mutating func uniqueAll(by predicate: (Element, Element) -> Bool) {
        guard (!isEmpty) else { return }
        
        for element in self {
            while let index = firstIndex(where: { predicate($0, element) }) {
                remove(at: index)
            }
        }
    }
}

public protocol Countable {
    var count: Int { get }
}

extension Array: Countable {}
