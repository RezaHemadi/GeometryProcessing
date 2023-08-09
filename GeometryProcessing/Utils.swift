//
//  Utils.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation

extension Array: Comparable where Element == Int {
    public static func < (lhs: Array<Int>, rhs: Array<Int>) -> Bool {
        if lhs.isEmpty { return true }
        if rhs.isEmpty { return false }
        let n = Swift.max(lhs.count, rhs.count)
        
        for i in 0..<n {
            if !lhs.indices.contains(i) { return true }
            if !rhs.indices.contains(i) { return false }
            
            if lhs[i] == rhs[i] {
                continue
            } else {
                return lhs[i] < rhs[i]
            }
        }
        
        return false
    }
}

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
        
        var indicesToRemove: [Int] = []
        
        for i in 0..<count {
            for j in (i + 1)..<count {
                if predicate(self[i], self[j]) {
                    indicesToRemove.append(j)
                }
            }
        }
        
        indicesToRemove.sort()
        var n: Int = 0
        while !indicesToRemove.isEmpty {
            let index = indicesToRemove.removeFirst()
            remove(at: index - n)
            n += 1
        }
    }
}

public protocol Countable {
    var count: Int { get }
}

extension Array: Countable {}
