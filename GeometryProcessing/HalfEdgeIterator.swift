//
//  HalfEdgeIterator.swift
//  GeometryProcessing
//
//  Created by Reza on 8/9/23.
//

import Foundation
import Matrix

// HalfEdgeIterator - Fake halfedge for fast and easy navigation
// on triangle meshes with vertex_triangle_adjacency and
// triangle_triangle adjacency
//
// Note: this is different to classical Half Edge data structure.
//    Instead, it follows cell-tuple in [Brisson, 1989]
//    "Representing geometric structures in d dimensions: topology and order."
//    This class can achieve local navigation similar to half edge in OpenMesh
//    But the logic behind each atom operation is different.
//    So this should be more properly called TriangleTupleIterator.
//
// Each tuple contains information on (face, edge, vertex)
//    and encoded by (face, edge \in {0,1,2}, bool reverse)
//
// Inputs:
//    F #F by 3 list of "faces"
//    FF #F by 3 list of triangle-triangle adjacency.
//    FFi #F by 3 list of FF inverse. For FF and FFi, refer to
//        "triangle_triangle_adjacency.h"
// Usages:
//    FlipF/E/V changes solely one actual face/edge/vertex resp.
//    NextFE iterates through one-ring of a vertex robustly.
//
public class HalfEdgeIterator<MF: Matrix, MFF: Matrix, MFFI: Matrix> where MF.Element == Int, MFF.Element == Int, MFFI.Element == Int {
    // MARK: - Properties
    private var fi: Int
    private var ei: Int
    private var reverse: Bool
    private let F: MF
    private let FF: MFF
    private let FFi: MFFI
    
    // MARK: - Initialization
    // Init the HalfEdgeIterator by specifying Face,Edge Index and Orientation
    public init(_ _F: MF, _ _FF: MFF, _ _FFi: MFFI, _ _fi: Int, _ _ei: Int, _ _reverse: Bool = false) {
        fi = _fi
        ei = _ei
        reverse = _reverse
        F = _F
        FF = _FF
        FFi = _FFi
    }
    
    // MARK: - Methods
    /// Change face
    public func flipF() {
        if (isBorder()) { return }
        
        let fin: Int = FF[fi, ei]
        let ein: Int = FFi[fi, ei]
        
        fi = fin
        ei = ein
        reverse = !reverse
    }
    
    /// Change edge
    public func flipE() {
        if (!reverse) {
            ei = (ei + 2) % 3 // ei - 1
        } else {
            ei = (ei + 1) % 3
        }
        
        reverse = !reverse
    }
    
    /// Change vertex
    public func flipV() {
        reverse = !reverse
    }
    
    public func isBorder() -> Bool {
        return FF[fi, ei] == -1
    }
    
    /*!
    * Returns the next edge skipping the border
    *      _________
    *     /\ c | b /\
    *    /  \  |  /  \
    *   / d  \ | / a  \
    *  /______\|/______\
    *          v
    * In this example, if a and d are of-border and the pos is iterating
    counterclockwise, this method iterate through the faces incident on vertex
    v,
     * producing the sequence a, b, c, d, a, b, c, ...
    */
    public func NextFE() -> Bool {
        if (isBorder()) { // we are on a border
            repeat {
                flipF()
                flipE()
            } while (!isBorder())
            flipE()
            return false
        } else {
            flipF()
            flipE()
            return true
        }
    }
    
    /// Get vertex index
    public func Vi() -> Int {
        assert(fi >= 0)
        assert(fi < F.rows)
        assert(ei >= 0)
        assert(ei <= 2)
        
        if (!reverse) {
            return F[fi, ei]
        } else {
            return F[fi, (ei + 1) % 3]
        }
    }
    
    /// Get face index
    public func Fi() -> Int {
        return fi
    }
    
    /// Get edge index
    public func Ei() -> Int {
        return ei
    }
}

extension HalfEdgeIterator: Equatable {
    public static func ==(lhs: HalfEdgeIterator, rhs: HalfEdgeIterator) -> Bool {
        return (lhs.fi == rhs.fi &&
                lhs.ei == rhs.ei &&
                lhs.reverse == rhs.reverse &&
                lhs.F == rhs.F &&
                lhs.FF == rhs.FF &&
                lhs.FFi == rhs.FFi)
    }
}
