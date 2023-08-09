//
//  vertex_triangle_adjacency.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// vertex_face_adjacency constructs the vertex-face topology of a given mesh (V,F)

// Inputs:
  //   F  #F by 3 list of triangle indices into some vertex list V
  //   n  number of vertices, #V (e.g., F.maxCoeff()+1)
  // Outputs:
  //   VF  3*#F list  List of faces indice on each vertex, so that VF(NI(i)+j) =
  //     f, means that face f is the jth face (in no particular order) incident
  //     on vertex i.
  //   NI  #V+1 list  cumulative sum of vertex-triangle degrees with a
  //     preceeding zero. "How many faces" have been seen before visiting this
  //     vertex and its incident faces.
public func vertex_triangle_adjacency<MF: Matrix>(F: MF, n: Int, VF: inout Vec<Int>, NI: inout Vec<Int>)
where MF.Element == Int
{
    // vfd  #V list so that vfd(i) contains the vertex-face degree (number of
        // faces incident on vertex i)
    var vfd: Vec<Int> = .Zero(n)
    for i in 0..<F.rows {
        for j in 0..<3 {
            vfd[F[i, j]] += 1
        }
    }
    cumsum(vfd, 1, &NI)
    // prepend a zero
    NI.prepend(0)
    // vfd now acts as a counter
    vfd = .init(NI, NI.rows, NI.cols)
    
    VF = .init(3 * F.rows, 1)
    for i in 0..<F.rows {
        for j in 0..<3 {
            VF[vfd[F[i, j]]] = i
            vfd[F[i, j]] += 1
        }
    }
}

// Inputs:
  //   //V  #V by 3 list of vertex coordinates
  //   n  number of vertices #V (e.g. `F.maxCoeff()+1` or `V.rows()`)
  //   F  #F by dim list of mesh faces (must be triangles)
  // Outputs:
  //   VF  #V list of lists of incident faces (adjacency list)
  //   VI  #V list of lists of index of incidence within incident faces listed
  //     in VF
  //
  // See also: edges, cotmatrix, diag, vv
  //
  // Known bugs: this should not take V as an input parameter.
  // Known bugs/features: if a facet is combinatorially degenerate then faces
  // will appear multiple times in VF and correspondingly in VFI (j appears
  // twice in F.row(i) then i will appear twice in VF[j])

public func vertex_triangle_adjacency<M: Matrix>(_ V: M, _ F: Mati, _ VF: inout [[Int]], _ VFi: inout [[Int]]) {
    return vertex_triangle_adjacency(V.rows, F, &VF, &VFi)
}

public func vertex_triangle_adjacency(_ n: Int, _ F: Mati, _ VF: inout [[Int]], _ VFi: inout [[Int]]) {
    VF.removeAll()
    VFi.removeAll()
    
    VF = .init(repeating: [], count: n)
    VFi = .init(repeating: [], count: n)
    
    for fi in 0..<F.rows {
        for i in 0..<F.cols {
            VF[F[fi, i]].append(fi)
            VFi[F[fi, i]].append(i)
        }
    }
}
