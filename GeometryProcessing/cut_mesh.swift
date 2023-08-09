//
//  cut_mesh.swift
//  GeometryProcessing
//
//  Created by Reza on 8/9/23.
//

import Foundation
import Matrix

// Given a mesh and a list of edges that are to be cut, the function
// generates a new disk-topology mesh that has the cuts at its boundary.
//
//
// Known issues: Assumes mesh is edge-manifold.
//
// Inputs:
//   V  #V by 3 list of the vertex positions
//   F  #F by 3 list of the faces
//   cuts  #F by 3 list of boolean flags, indicating the edges that need to
//     be cut (has 1 at the face edges that are to be cut, 0 otherwise)
// Outputs:
//   Vn  #V by 3 list of the vertex positions of the cut mesh. This matrix
//     will be similar to the original vertices except some rows will be
//     duplicated.
//   Fn  #F by 3 list of the faces of the cut mesh(must be triangles). This
//     matrix will be similar to the original face matrix except some indices
//     will be redirected to point to the newly duplicated vertices.
//   I   #V by 1 list of the map between Vn to original V index.

// In place mesh cut
public func cut_mesh<MV: Matrix, MF: Matrix, MCUT: Matrix, MI: Vector>
(_ V: inout MV, _ F: inout MF, _ C: MCUT, _ I: inout MI)
where MV.Element == Double, MF.Element == Int, MI.Element == Int, MCUT.Element == Bool
{
    var FF = MF()
    var FFi = MF()
    triangle_triangle_adjacency(F, &FF, &FFi)
    cut_mesh(&V, &F, &FF, &FFi, C, &I)
}

public func cut_mesh<MV: Matrix, MF: Matrix, MFF: Matrix, MFFI: Matrix, MC: Matrix, MI: Vector>
(_ V: inout MV, _ F: inout MF, _ FF: inout MFF, _ FFi: inout MFFI, _ C: MC, _ I: inout MI)
where MV.Element == Double, MF.Element == Int, MFF.Element == Int, MFFI.Element == Int, MI.Element == Int, MC.Element == Bool
{
    // store current number of occurance of each vertex as the alg proceed
    var occurence = Vec<Int>(V.rows)
    occurence.setConstant(1)
    
    // set eventual number of occurance of each vertexexpected
    var eventual = Vec<Int>(V.rows)
    eventual.setZero()
    
    for i in 0..<F.rows {
        for k in 0..<3 {
            let u: Int = F[i, k]
            let v: Int = F[i, (k + 1) % 3]
            if (FF[i, k] == -1) { // add one extra occurance for boundary vertices
                eventual[u] += 1
            } else if (C[i, k] == true && u < v) { // only compute every (undirected edge ones
                eventual[u] += 1
                eventual[v] += 1
            }
        }
    }
    
    // original number of vertices
    let n_v: Int = V.rows
    
    // estimate number of new vertices and resize V
    var n_new: Int = 0
    for i in 0..<eventual.rows {
        n_new += ((eventual[i] > 0) ? eventual[i] - 1 : 0)
    }
    V.conservativeResize(n_v + n_new, V.cols)
    I = .LineSpaced(low: 0, high: V.rows, count: V.rows)
    
    // pointing to the current bottom of V
    var pos: Int = n_v
    for f in 0..<C.rows {
        for k in 0..<3 {
            let v0: Int = F[f, k]
            if (F[f, k] >= n_v) { continue } // ignore new vertices
            if (C[f, k] == true && occurence[v0] != eventual[v0]) {
                let he = HalfEdgeIterator(F, FF, FFi, f, k)
                
                // rotate clock-wise around v0 until hit another cut
                var fan: [Int] = []
                var fi = he.Fi()
                var ei = he.Ei()
                repeat {
                    fan.append(fi)
                    he.flipE()
                    he.flipF()
                    fi = he.Fi()
                    ei = he.Ei()
                } while (C[fi, ei] == false && !he.isBorder())
                
                // make a copy
                V.row(pos) <<== V.row(v0)
                I[pos] = v0
                // add one occurance to v0
                occurence[v0] += 1
                
                // replace old v0
                for f0 in fan {
                    for j in 0..<3 {
                        if (F[f0, j] == v0) {
                            F[f0, j] = pos
                        }
                    }
                }
                
                // mstk vuyd sd nounfsty
                FF[f, k] = -1
                FF[fi, ei] = -1
                
                pos += 1
            }
        }
    }
}

public func cut_mesh<MV: Matrix, MF: Matrix, MCUTS: Matrix, MVN: Matrix, MFN: Matrix>
(_ V: MV, _ F: MF, _ C: MCUTS, _ Vn: inout MVN, _ Fn: inout MFN)
where MVN.Element == MV.Element, MFN.Element == MF.Element, MF.Element == Int, MV.Element == Double, MCUTS.Element == Bool
{
    Vn = .init(V, V.rows, V.cols)
    Fn = .init(F, F.rows, F.cols)
    var _I = Veci()
    cut_mesh(&Vn, &Fn, C, &_I)
}

public func cut_mesh<MV: Matrix, MF: Matrix, MCUTS: Matrix, MVN: Matrix, MFN: Matrix, MI: Vector>
(_ V: MV, _ F: MF, _ C: MCUTS, _ Vn: inout MVN, _ Fn: inout MFN, _ I: inout MI)
where MV.Element == Double, MF.Element == Int, MI.Element == Int, MVN.Element == MV.Element, MFN.Element == MF.Element, MCUTS.Element == Bool
{
    Vn = .init(V, V.rows, V.cols)
    Fn = .init(F, F.rows, F.cols)
    cut_mesh(&Vn, &Fn, C, &I)
}
