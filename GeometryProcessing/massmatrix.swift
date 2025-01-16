//
//  massmatrix.swift
//  GeometryProcessing
//
//  Created by Reza on 1/16/25.
//

import Foundation
import Matrix

public enum MassMatrixType {
    // lumping area of each element to corner vertices in equal parts
    case barycentric
    // lumping area by Voronoi dual area
    case voronoi
    // Full (non-diagonal mass matrix) for piecewise linear functions
    case full
    
    case `default`
}

/// Constructs the mass (area) matrix for a given mesh (V,F).
  ///
  /// @tparam DerivedV  derived type of eigen matrix for V (e.g. derived from
  ///     MatrixXd)
  /// @tparam DerivedF  derived type of eigen matrix for F (e.g. derived from
  ///     MatrixXi)
  /// @tparam Scalar  scalar type for eigen sparse matrix (e.g. double)
  /// @param[in] V  #V by dim list of mesh vertex positions
  /// @param[in] F  #F by simplex_size list of mesh elements (triangles or tetrahedra)
  /// @param[in] type  one of the following ints:
  ///     MASSMATRIX_TYPE_BARYCENTRIC  barycentric {default for tetrahedra}
  ///     MASSMATRIX_TYPE_VORONOI voronoi-hybrid {default for triangles}
  ///     MASSMATRIX_TYPE_FULL full
  /// @param[out] M  #V by #V mass matrix
  ///
  /// \see cotmatrix
  ///
public func massmatrix<MV: Matrix, MF: Matrix>(_ V: MV, _ F: MF, type: MassMatrixType) -> SparseMatrix<MV.Element> where MV.RowType: Vector, MF.Element == Int, MV.Element == Double, MV.RowType.Element == Double {
    var effType: MassMatrixType = (type == .default ? .voronoi : type)
    var l: Matd = edge_lengths(vertices: V, faces: F)
    let output = massmatrix_intrinsic(l, F, type: effType)
    return output
}
