//
//  boundary_loop.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Compute list of ordered boundary loops for a manifold mesh.
  //
  // Templates:
  //  Index  index type
  // Inputs:
  //   F  #V by dim list of mesh faces
  // Outputs:
  //   L  list of loops where L[i] = ordered list of boundary vertices in loop i
  //
public func boundary_loop(_ F: Mat<Int>, _ L: inout [[Int]]) {
    if (F.rows == 0) {
        return
    }
    
    let Vdummy = Vec<Double>(F.maxCoeff() + 1, 1)
    var TT: Mati = .init()
    var TTi: Mati = .init()
    var VF: [[Int]] = [[]]
    var VFi: [[Int]] = [[]]
    
    triangle_triangle_adjacency(F, &TT, &TTi)
    vertex_triangle_adjacency(Vdummy, F, &VF, &VFi)
    
    var unvisited: [Bool] = is_border_vertex(F: F)
    
    var unseen: Set<Int> = .init()
    for i in 0..<unvisited.count {
        if (unvisited[i]) {
            unseen.insert(i)
        }
    }
    
    while (!unseen.isEmpty) {
        var l: [Int] = []
        
        // Get first vertex of loop
        let start = unseen.popFirst()!
        unvisited[start] = false
        l.append(start)
        
        var done: Bool = false
        
        while (!done) {
            // Find next vertex
            var newBndEdge: Bool = false
            let v: Int = l[l.count - 1]
            var next: Int = 0
            for i in 0..<VF[v].count {
                guard !newBndEdge else { continue }
                
                let fid = VF[v][i]
                
                if (TT.row(fid).minCoeff() < 0) { // face contains boundary edge
                    var vLoc = -1
                    if (F[fid, 0] == v) { vLoc = 0 }
                    if (F[fid, 1] == v) { vLoc = 1 }
                    if (F[fid, 2] == v) { vLoc = 2 }
                    
                    let vNext: Int = F[fid, (vLoc + 1) % F.cols]
                    
                    newBndEdge = false
                    if (unvisited[vNext] && TT[fid, vLoc] < 0) {
                        next = vNext
                        newBndEdge = true
                    }
                }
            }
            
            if (newBndEdge) {
                l.append(next)
                unseen.remove(next)
                unvisited[next] = false
            } else {
                done = true
            }
        }
        L.append(l)
    }
}

// Compute ordered boundary loops for a manifold mesh and return the
  // longest loop in terms of vertices.
  //
  // Templates:
  //  Index  index type
  // Inputs:
  //   F  #V by dim list of mesh faces
  // Outputs:
  //   L  ordered list of boundary vertices of longest boundary loop
  //
public func boundary_loop(_ F: Mat<Int>, _ L: inout [Int]) {
    if (F.rows == 0) { return }
    
    var Lall: [[Int]] = [[]]
    boundary_loop(F, &Lall)
    
    var idxMax = -1
    var maxLen: Int = 0
    for i in 0..<Lall.count {
        if (Lall[i].count > maxLen) {
            maxLen = Lall[i].count
            idxMax = i
        }
    }
    
    // check for meshes without boundary
    if (idxMax == -1) {
        L.removeAll()
        return
    }
    
    L = .init(repeating: 0, count: Lall[idxMax].count)
    for i in 0..<Lall[idxMax].count {
        L[i] = Lall[idxMax][i]
    }
}

// Compute ordered boundary loops for a manifold mesh and return the
  // longest loop in terms of vertices.
  //
  // Templates:
  //  Index  index type
  // Inputs:
  //   F  #V by dim list of mesh faces
  // Outputs:
  //   L  ordered list of boundary vertices of longest boundary loop
  //
public func boundary_loop<V: Vector>(_ F: Mat<Int>, _ L: inout V) where V.Element == Int {
    if (F.rows == 0) { return }
    
    var Lvec: [Int] = []
    boundary_loop(F, &Lvec)
    
    L.resize(Lvec.count, 1)
    for i in 0..<Lvec.count {
        L[i] = Lvec[i]
    }
}
