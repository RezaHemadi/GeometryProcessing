//
//  doubleArea.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// DOUBLEAREA computes twice the area for each input triangle[quad]
  // Inputs:
  //   V  #V by dim list of mesh vertex positions
  //   F  #F by simplex_size list of mesh faces (must be triangles)
  // Outputs:
  //   dblA  #F list of triangle double areas (SIGNED only for 2D input)
  //
  // Known bug: For dim==3 complexity is O(#V + #F)!! Not just O(#F). This is a big deal
  // if you have 1million unreferenced vertices and 1 face
public func doubleArea<M1: Matrix, M2: Matrix>(V: M1, F: M2, dblA: inout Vec<Double>) where M1.Element == Double, M2.Element == Int {
    let dim = V.cols
    let m = F.rows
    
    // Compute edge lengths
    let proj_doublearea: (Int, Int, Int) -> Double = { x, y, f in
        let rx = V[F[f, 0], x] - V[F[f, 2], x]
        let sx = V[F[f, 1], x] - V[F[f, 2], x]
        let ry = V[F[f, 0], y] - V[F[f, 2], y]
        let sy = V[F[f, 1], y] - V[F[f, 2], y]
        
        return rx * sy - ry * sx
    }
    
    switch dim {
    case 3:
        dblA = .Zero(m)
        
        for f in 0..<m {
            for d in 0..<3 {
                let dblAd = proj_doublearea(d, (d + 1) % 3, f)
                dblA[f] += (dblAd * dblAd)
            }
        }
        dblA <<== dblA.array().sqrt()
        
    case 2:
        dblA.resize(m)
        
        for f in 0..<m {
            dblA[f] = proj_doublearea(0, 1, f)
        }
        
    default:
       fatalError()
    }
}

public func doubleArea<M1: Matrix, M2: Matrix>(V: M1, F: M2, dblA: inout Vec<Float>) where M1.Element == Float, M2.Element == Int {
    let dim = V.cols
    let m = F.rows
    
    // Compute edge lengths
    let proj_doublearea: (Int, Int, Int) -> Float = { x, y, f in
        let rx = V[F[f, 0], x] - V[F[f, 2], x]
        let sx = V[F[f, 1], x] - V[F[f, 2], x]
        let ry = V[F[f, 0], y] - V[F[f, 2], y]
        let sy = V[F[f, 1], y] - V[F[f, 2], y]
        
        return rx * sy - ry * sx
    }
    
    switch dim {
    case 3:
        dblA = .Zero(m)
        
        for f in 0..<m {
            for d in 0..<3 {
                let dblAd = proj_doublearea(d, (d + 1) % 3, f)
                dblA[f] += (dblAd * dblAd)
            }
        }
        dblA <<== dblA.array().sqrt()
        
    case 2:
        dblA.resize(m)
        
        for f in 0..<m {
            dblA[f] = proj_doublearea(0, 1, f)
        }
        
    default:
       fatalError()
    }
}

//
// Inputs:
//   l  #F by dim list of edge lengths using
//     for triangles, columns correspond to edges 23,31,12
//   nan_replacement  what value should be used for triangles whose given
//     edge lengths do not obey the triangle inequality. These may be very
//     wrong (e.g., [100 1 1]) or may be nearly degenerate triangles whose
//     floating point side length computation leads to breach of the triangle
//     inequality. One may wish to set this parameter to 0 if side lengths l
//     are _known_ to come from a valid embedding (e.g., some mesh (V,F)). In
//     that case, the only circumstance the triangle inequality is broken is
//     when the triangle is nearly degenerate and floating point error
//     dominates: hence replacing with zero is reasonable.
// Outputs:
//   dblA  #F list of triangle double areas
public func doublearea(_ ul: Matd, _ nan_replacement: Double, _ dblA: inout Vec<Double>) {
    // only support triangles
    assert(ul.cols == 3)
    // number of triangles
    let m: Int = ul.rows
    var l: Mat<Double> = .init()
    var tmp: Mati = .init()
    
    geom_sort(ul, 2, false, &l, &tmp)
    
    // resize output
    dblA.resize(l.rows)
    for i in 0..<m {
        // Kahan's Heron's formula
        let arg = (l[i, 0] + (l[i, 1] + l[i, 2])) *
                  (l[i, 2] - (l[i, 0] - l[i, 1])) *
                  (l[i, 2] + (l[i, 0] - l[i, 1])) *
                  (l[i, 0] + (l[i, 1] - l[i, 2]))
        dblA[i] = 2.0 * 0.25 * sqrt(arg)
        // Alec: If the input edge lengths were computed from floating point
        // vertex positions then there's no guarantee that they fulfill the
        // triangle inequality (in their floating point approximations). For
        // nearly degenerate triangles the round-off error during side-length
        // computation may be larger than (or rather smaller) than the height of
        // the triangle. In "Lecture Notes on Geometric Robustness" Shewchuck 09,
        // Section 3.1 http://www.cs.berkeley.edu/~jrs/meshpapers/robnotes.pdf,
        // he recommends computing the triangle areas for 2D and 3D using 2D
        // signed areas computed with determinants.
        
        /*
         assert(
                 (nan_replacement == nan_replacement ||
                   (l(i,2) - (l(i,0)-l(i,1)))>=0)
                   && "Side lengths do not obey the triangle inequality.");
         */
    }
}
