//
//  triangle_triangle_adjacency.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Constructs the triangle-triangle adjacency matrix for a given
  // mesh (V,F).
  //
  // Inputs:
  //   F  #F by simplex_size list of mesh faces (must be triangles)
  // Outputs:
  //   TT   #F by #3 adjacent matrix, the element i,j is the id of the triangle
  //        adjacent to the j edge of triangle i
  //   TTi  #F by #3 adjacent matrix, the element i,j is the id of edge of the
  //        triangle TT(i,j) that is adjacent with triangle i
  //
public func triangle_triangle_adjacency<MF: Matrix>(_ F: MF, _ TT: inout MF, _ TTi: inout MF)
where MF.Element == Int
{
    triangle_triangle_adjacency(F, &TT)
    TTi = .Constant(TT.rows, TT.cols, -1)
    
    for f in 0..<F.rows {
        for k in 0..<3 {
            let vi = F[f, k]
            let vj = F[f, (k + 1) % 3]
            let fn = TT[f, k]
            if (fn >= 0) {
                for kn in 0..<3 {
                    let vin = F[fn, kn]
                    let vjn = F[fn, (kn + 1) % 3]
                    if (vi == vjn && vin == vj) {
                        TTi[f, k] = kn
                        break
                    }
                }
            }
        }
    }
}

public func triangle_triangle_adjacency<MF: Matrix>(_ F: MF, _ TT: inout MF)
where MF.Element == Int
{
    let n = F.maxCoeff() + 1
    var VF: Vec<Int> = .init()
    var NI: Vec<Int> = .init()
    vertex_triangle_adjacency(F: F, n: n, VF: &VF, NI: &NI)
    TT = .Constant(F.rows, 3, -1)
    // loop over faces
    for f in 0..<F.rows {
        // loop over corners
        for k in 0..<3 {
            let vi: Int = F[f, k]
            let vin: Int = F[f, (k + 1) % 3]
            // Loop over face neighbors incident on this corner
            for j in NI[vi]..<NI[vi + 1] {
                let fn: Int = VF[j]
                // Not this face
                if (fn != f) {
                    // Face neighbor also has [vi, vin] edge
                    if (F[fn, 0] == vin || F[fn, 1] == vin || F[fn, 2] == vin) {
                        TT[f, k] = fn
                        break
                    }
                }
            }
        }
    }
}

// Preprocessing
private func triangle_triangle_adjacency_preprocess(_ F: Mat<Int>, _ TTT: inout [[Int]]) {
    fatalError("To be implemented")
}

// Extract the face adjacencies
private func trianlge_triangle_adjacency_extractTT(_ F: Mat<Int>, _ TTT: inout [[Int]], _ TT: inout Mat<Int>) {
    TT.setConstant(F.rows, F.cols, -1)
    
    for i in 1..<TTT.count {
        let r1: [Int] = TTT[i - 1]
        let r2: [Int] = TTT[i]
        
        if (r1[0] == r2[0] && r1[1] == r2[1]) {
            TT[r1[2], r1[3]] = r2[2]
            TT[r2[2], r2[3]] = r1[2]
        }
    }
    
    /*
    for i in 1..<TTT.count {
        if ((TTT[i - 1][0] == TTT[i][0]) && (TTT[i - 1][1] == TTT[i][1])) {
            TT[TTT[i - 1][2], TTT[i - 1][3]] = TTT[i][2]
            TT[TTT[i][2],TTT[i][3]] = TTT[i - 1][2]
        }
    }*/
}

// Extract the face adjacencies indices (needed for fast traversal)
private func triangle_triangle_adjacency_extractTTi(_ F: Mat<UInt32>, _ TTT: inout [[Int]], _ TTi: inout Mat<Int>) {
    fatalError("To be implemented")
}

// Adjacency list version, which works with non-manifold meshes
//
// Inputs:
//   F  #F by 3 list of triangle indices
// Outputs:
//   TT  #F by 3 list of lists so that TT[i][c] --> {j,k,...} means that
//     faces j and k etc. are edge-neighbors of face i on face i's edge
//     opposite corner c
//   TTj  #F list of lists so that TTj[i][c] --> {j,k,...} means that face
//     TT[i][c][0] is an edge-neighbor of face i incident on the edge of face
//     TT[i][c][0] opposite corner j, and TT[i][c][1] " corner k, etc.
func triangle_triangle_adjacency(_ F: Mati, _ TT: inout [[[Int]]]) {
    var not_used: [[[Int]]] = [[[]]]
    triangle_triangle_adjacency(F, false, &TT, &not_used)
}

// Wrapper with bool to choose whether to compute TTi (this prototype should
// be "hidden").
func triangle_triangle_adjacency(_ F: Mati, _ construct_TTi: Bool, _ TT: inout [[[Int]]], _ TTi: inout [[[Int]]]) {
    assert(F.cols == 3, "Faces must be triangles")
    // number of faces
    var E: Mat<Int> = .init()
    var uE: Mat<Int> = .init()
    var EMAP: Vec<Int> = .init()
    var uE2E: [[Int]] = [[]]
    unique_edge_map(F, &E, &uE, &EMAP, &uE2E)
    return triangle_triangle_adjacency(E, EMAP, uE2E, construct_TTi, &TT, &TTi)
}

// Inputs:
//   E  #F*3 by 2 list of all of directed edges in order (see
//     `oriented_facets`)
//   EMAP #F*3 list of indices into uE, mapping each directed edge to unique
//     undirected edge
//   uE2E  #uE list of lists of indices into E of coexisting edges
// See also: unique_edge_map, oriented_facets
func triangle_triangle_adjacency<ME: Matrix>
(_ E: ME, _ EMAP: Veci, _ uE2E: [[Int]], _ construct_TTi: Bool, _ TT: inout [[[Int]]], _ TTi: inout [[[Int]]])
where ME.Element == Int
{
    let m: Int = E.rows / 3
    assert(E.rows == m * 3, "E should come from list of triangles")
    // E2E[i] --> {j,k,...} means face edge i corresponds to other faces edges j
    // and k
    TT = .init(repeating: [[], [], []], count: m)
    if (construct_TTi) {
        TTi = .init(repeating: [[], [], []], count: m)
    }
    
    // No race conditions because TT*[f][c]'s are in bijection with e's
    // Minimum number of items per thread
    //const size_t num_e = E.rows();
    // Slightly better memory access than loop over E
    for f in 0..<m {
        for c in 0..<3 {
            let e: Int = f + m * c
            let N: [Int] = uE2E[EMAP[e]]
            for ne in N {
                let nf: Int = ne % m
                // don't add self
                if (nf != f) {
                    TT[f][c].append(nf)
                    if (construct_TTi) {
                        let nc: Int = ne / m
                        TTi[f][c].append(nc)
                    }
                }
            }
        }
    }
}

func triangle_triangle_adjacency<MuEC: Vector, MuEE: Vector>
(_ EMAP: Veci, _ uEC: MuEC, _ uEE: MuEE, _ construct_TTi: Bool, _ TT: inout [[[Int]]], _ TTi: inout [[[Int]]])
where MuEC.Element == Int, MuEE.Element == Int {
    let m: Int = EMAP.rows / 3
    assert(EMAP.rows == 3 * m, "EMAP should come from list of triangles.")
    // E2E[i] --> {j,k,...} means face edge i corresponds to other faces edges j
    // and k
    TT = .init(repeating: [[], [], []], count: m)
    if (construct_TTi) {
        TTi = .init(repeating: [[], [], []], count: m)
    }
    
    // No race conditions because TT*[f][c]'s are in bijection with e's
    // Minimum number of items per thread
    //const size_t num_e = E.rows();
    // Slightly better memory access than loop over E
    for f in 0..<m {
        for c in 0..<3 {
            let e: Int = f + m * c
            for j in uEC[EMAP[e]]..<uEC[EMAP[e] + 1] {
                let ne: Int = uEE[j]
                let nf: Int = ne % m
                // don't add self
                if (nf != f) {
                    TT[f][c].append(nf)
                    if (construct_TTi) {
                        let nc: Int = ne / m
                        TTi[f][c].append(nc)
                    }
                }
            }
        }
    }
}
