//
//  triangulate.swift
//  GeometryProcessing
//
//  Created by Reza on 7/11/23.
//

import Foundation
import Matrix

// Triangulate the interior of a polygon using the triangle library.
//
// Inputs:
//   V #V by 2 list of 2D vertex positions
//   E #E by 2 list of vertex ids forming unoriented edges of the boundary of the polygon
//   H #H by 2 coordinates of points contained inside holes of the polygon
//   flags  string of options pass to triangle (see triangle documentation)
// Outputs:
//   V2  #V2 by 2  coordinates of the vertives of the generated triangulation
//   F2  #F2 by 3  list of indices forming the faces of the generated triangulation
//

public func triangulate(_ V: Matd, _ E: Mati, _ H: Matd, _ flags: String, _ V2: inout Matd, _ F2: inout Mati) {
    var VM = Veci()
    var EM = Veci()
    var VM2 = Veci()
    var EM2 = Veci()
    
    return triangulate(V, E, H, VM, EM, flags, &V2, &F2, &VM2, &EM2)
}

// Triangulate the interior of a polygon using the triangle library.
//
// Inputs:
//   V #V by 2 list of 2D vertex positions
//   E #E by 2 list of vertex ids forming unoriented edges of the boundary of the polygon
//   H #H by 2 coordinates of points contained inside holes of the polygon
//   M #V list of markers for input vertices
//   flags  string of options pass to triangle (see triangle documentation)
// Outputs:
//   V2  #V2 by 2  coordinates of the vertives of the generated triangulation
//   F2  #F2 by 3  list of indices forming the faces of the generated triangulation
//   M2  #V2 list of markers for output vertices
//
// TODO: expose the option to prevent Steiner points on the boundary
public func triangulate(_ V: Matd, _ E: Mati, _ H: Matd, _ VM: Veci, _ EM: Veci, _ flags: String, _ V2: inout Matd, _ F2: inout Mati, _ VM2: inout Veci, _ EM2: inout Veci) {
    
    assert((VM.count == 0 || V.rows == VM.count), "Vertex markers must be empty or same size as V")
    assert((EM.count == 0 || E.rows == EM.count), "Segment markers must be empty or same size as E")
    assert(V.cols == 2)
    assert(E.size.count == 0 || E.cols == 2)
    assert(H.size.count == 0 || H.cols == 2)
    
    // prepare the flags
    var full_flags: String = flags + "pz" + ((EM.size.count != 0) || (VM.size.count != 0) ? "" : "B")
    
    var MapXdr: Matd
    var MapXir: Mati
    
    // Prepare the input struct
    fatalError("To be implemented")
}
