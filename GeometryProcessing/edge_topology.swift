//
//  edge_topology.swift
//  GeometryProcessing
//
//  Created by Reza on 8/8/23.
//

import Foundation
import Matrix

// Initialize Edges and their topological relations (assumes an edge-manifold
// mesh)
//
// Inputs:
//   V  #V by dim list of mesh vertex positions (unused)
//   F  #F by 3 list of triangle indices into V
// Outputs:
//   EV  #Ex2 matrix storing the edge description as pair of indices to
//       vertices
//   FE  #Fx3 matrix storing the Triangle-Edge relation
//   EF  #Ex2 matrix storing the Edge-Triangle relation
//
// TODO: This seems to be a inferior duplicate of edge_flaps.h:
//   - unused input parameter V
//   - roughly 2x slower than edge_flaps
//   - outputs less information: edge_flaps reveals corner opposite edge
//   - FE uses non-standard and ambiguous order: FE(f,c) is merely an edge
//     incident on corner c of face f. In contrast, edge_flaps's EMAP(f,c)
//     reveals the edge _opposite_ corner c of face f
public func edge_topology<MV: Matrix, MF: Matrix, MEV: Matrix, MEF: Matrix, MFE: Matrix>
(_ V: MV, _ F: MF, _ EV: inout MEV, _ FE: inout MFE, _ EF: inout MEF)
where MV.Element == Double, MF.Element == Int, MFE.Element == Int, MEF.Element == Int, MEV.Element == Int
{
    // Only needs to be edge-manifold
    if (V.rows == 0 || F.rows == 0) {
        EV = .Constant(0, 2, -1)
        FE = .Constant(0, 3, -1)
        EF = .Constant(0, 2, -1)
        return
    }
    assert(is_edge_manifold(F))
    var ETT: [[Int]] = []
    for f in 0..<F.rows {
        for i in 0..<3 {
            // v1 v2 f vi
            var v1: Int = F[f, i]
            var v2: Int = F[f, (i + 1) % 3]
            if (v1 > v2) { swap(&v1, &v2) }
            var r: [Int] = .init(repeating: 0, count: 4)
            r[0] = v1
            r[1] = v2
            r[2] = f
            r[3] = i
            ETT.append(r)
        }
    }
    ETT.sort()
    
    // count the number of edges (assume manifoldness)
    var En: Int = 1 // the last is always counted
    for i in 0..<(ETT.count - 1) {
        if (!((ETT[i][0] == ETT[i + 1][0]) && (ETT[i][1] == ETT[i + 1][1]))) {
            En += 1
        }
    }
    
    EV = .Constant(En, 2, -1)
    FE = .Constant(F.rows, 3, -1)
    EF = .Constant(En, 2, -1)
    En = 0
    
    var skip: Bool = false
    for i in 0..<ETT.count {
        if skip {
            skip = false
            continue
        }
        if (i == ETT.count - 1 || !((ETT[i][0] == ETT[i + 1][0]) && (ETT[i][1] == ETT[i + 1][1]))) {
            // Border edge
            let r1 = ETT[i]
            EV[En, 0] = r1[0]
            EV[En, 1] = r1[1]
            EF[En, 0] = r1[2]
            FE[r1[2], r1[3]] = En
        } else {
            let r1 = ETT[i]
            let r2 = ETT[i + 1]
            EV[En, 0] = r1[0]
            EV[En, 1] = r1[1]
            EF[En, 0] = r1[2]
            EF[En, 1] = r2[2]
            FE[r1[2], r1[3]] = En
            FE[r2[2], r2[3]] = En
            skip = true
        }
        En += 1
    }
    
    // Sort the relation EF, accordingly to EV
    // the first one is the face on the left of the edge
    for i in 0..<EF.rows {
        let fid: Int = EF[i, 0]
        var flip: Bool = true
        // search for edge EV.row(i)
        for j in 0..<3 {
            if ((F[fid, j] == EV[i, 0]) && (F[fid, (j + 1) % 3] == EV[i, 1])) {
                flip = false
            }
        }
        
        if (flip) {
            let tmp: Int = EF[i, 0]
            EF[i, 0] = EF[i, 1]
            EF[i, 1] = tmp
        }
    }
}
