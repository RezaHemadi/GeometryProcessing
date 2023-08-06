//
//  oriented_facets.swift
//  GeometryProcessing
//
//  Created by Reza on 8/4/23.
//

import Foundation
import Matrix

// ORIENTED_FACETS Determines all "directed
// [facets](https://en.wikipedia.org/wiki/Simplex#Elements)" of a given set of
// simplicial elements. For a manifold triangle mesh, this computes all
// half-edges. For a manifold tetrahedral mesh, this computes all half-faces.
//
// Inputs:
//   F  #F by simplex_size  list of simplices
// Outputs:
//   E  #E by simplex_size-1  list of facets, such that E.row(f+#F*c) is the
//     facet opposite F(f,c)
//
// Note: this is not the same as igl::edges because this includes every
// directed edge including repeats (meaning interior edges on a surface will
// show up once for each direction and non-manifold edges may appear more than
// once for each direction).
//
// Note: This replaces the deprecated `all_edges` function
public func oriented_facets<MF: Matrix, ME: Matrix>(_ F: MF, _ E: inout ME) where MF.Element == Int, ME.Element == Int {
    E.resize(F.rows * F.cols, F.cols - 1)
    
    switch F.cols {
    case 4:
        E.block(0 * F.rows, 0, F.rows, 1) <<== F.col(1)
        E.block(0 * F.rows, 1, F.rows, 1) <<== F.col(3)
        E.block(0 * F.rows, 2, F.rows, 1) <<== F.col(2)
        
        E.block(1 * F.rows, 0, F.rows, 1) <<== F.col(0)
        E.block(1 * F.rows, 1, F.rows, 1) <<== F.col(2)
        E.block(1 * F.rows, 2, F.rows, 1) <<== F.col(3)
        
        E.block(2 * F.rows, 0, F.rows, 1) <<== F.col(0)
        E.block(2 * F.rows, 1, F.rows, 1) <<== F.col(3)
        E.block(2 * F.rows, 2, F.rows, 1) <<== F.col(1)
        
        E.block(3 * F.rows, 0, F.rows, 1) <<== F.col(0)
        E.block(3 * F.rows, 1, F.rows, 1) <<== F.col(1)
        E.block(3 * F.rows, 2, F.rows, 1) <<== F.col(2)
        
        return
        
    case 3:
        E.block(0 * F.rows, 0, F.rows, 1) <<== F.col(1)
        E.block(0 * F.rows, 1, F.rows, 1) <<== F.col(2)
        E.block(1 * F.rows, 0, F.rows, 1) <<== F.col(2)
        E.block(1 * F.rows, 1, F.rows, 1) <<== F.col(0)
        E.block(2 * F.rows, 0, F.rows, 1) <<== F.col(0)
        E.block(2 * F.rows, 1, F.rows, 1) <<== F.col(1)
        
        return
        
    default:
        fatalError("simplex not supported")
    }
}
