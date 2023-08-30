//
//  Triangulate.swift
//  GeometryProcessing
//
//  Created by Reza on 8/28/23.
//

import Foundation
import Matrix

/// Triangulate the interior of a polygon using the triangle library.
///
/// @param[in] V #V by 2 list of 2D vertex positions
/// @param[in] E #E by 2 list of vertex ids forming unoriented edges of the boundary of the polygon
/// @param[in] H #H by 2 coordinates of points contained inside holes of the polygon
/// @param[in] VM #V list of markers for input vertices
/// @param[in] EM #E list of markers for input edges
/// @param[in] flags  string of options pass to triangle (see triangle documentation)
/// @param[out] V2  #V2 by 2  coordinates of the vertives of the generated triangulation
/// @param[out] F2  #F2 by 3  list of indices forming the faces of the generated triangulation
/// @param[out] VM2  #V2 list of markers for output vertices
/// @param[out] E2  #E2 by 2 list of output edges
/// @param[out] EM2  #E2 list of markers for output edges
public func triangulate<MV: Matrix, ME: Matrix, HM: Matrix, VMM: Vector, EMM: Vector, V2M: Matrix, F2M: Matrix, VM2M: Matrix, E2M: Matrix, EM2M: Matrix>
(_ V:MV, _ E: ME, _ H: HM, _ VM: VMM, _ EM: EMM, _ flags: String, _ V2: inout V2M, _ F2: inout F2M, _ VM2: inout VM2M, _ E2: inout E2M, _ EM2: inout EM2M)
where MV.Element == Double, ME.Element == Int, HM.Element == Double, V2M.Element == Double, F2M.Element == Int, E2M.Element == Int, VMM.Element == Int, EMM.Element == Int, VM2M.Element == Int, EM2M.Element == Int
{
    assert((VM.size.count == 0 || V.rows == VM.size.count), "Vertex markers must be empty or same size as V")
    assert((EM.size.count == 0 || E.rows == EM.size.count), "Segment markers must be empty or same size as E")
    assert(V.cols == 2)
    assert(E.size.count == 0 || E.cols == 2)
    assert(H.size.count == 0 || H.cols == 2)
    
    // Prepare the flags
    let full_flags: String = flags + "pz" + ((EM.size.count != 0 || VM.size.count != 0) ? "" : "B")
    
    // Prepare the input struct
    var input = triangulateio()
    input.numberofpoints = Int32(V.rows)
    input.pointlist = .allocate(capacity: V.size.count)
    input.pointlist.initialize(from: V.valuesPtr.pointer, count: V.size.count)
    
    input.numberofpointattributes = 0
    input.pointmarkerlist = .allocate(capacity: V.size.count)
    input.pointmarkerlist.initialize(repeating: 0, count: V.size.count)
    for i in 0..<V.rows {
        input.pointmarkerlist[i] = VM.size.count != 0 ? Int32(VM[i]) : 1
    }
    input.trianglelist = nil
    input.numberoftriangles = 0
    input.numberofcorners = 0
    input.numberoftriangleattributes = 0
    input.triangleattributelist = nil
    
    input.numberofsegments = E.size.count != 0 ? Int32(E.rows) : 0
    input.segmentlist = .allocate(capacity: E.size.count)
    for i in 0..<E.size.count {
        input.segmentlist[i] = Int32(E.valuesPtr.pointer[i])
    }
    input.segmentmarkerlist = .allocate(capacity: E.rows)
    input.segmentmarkerlist.initialize(repeating: 0, count: E.rows)
    for i in 0..<E.rows {
        input.segmentmarkerlist[i] = EM.size.count != 0 ? Int32(EM[i]) : 1
    }
    
    input.numberofholes = H.size.count != 0 ? Int32(H.rows) : 0
    input.holelist = .allocate(capacity: H.size.count)
    input.holelist.initialize(repeating: 0.0, count: H.size.count)
    for i in 0..<H.size.count {
        input.holelist[i] = H.valuesPtr.pointer[i]
    }
    input.numberofregions = 0
    
    // Prepare the output struct
    var output = triangulateio()
    output.pointlist = nil
    output.trianglelist = nil
    output.segmentlist = nil
    output.segmentmarkerlist = nil
    output.pointmarkerlist = nil
    
    // Call triangle
    let full_flags_cstring = full_flags.cString(using: .utf8)!
    let flags_ptr: UnsafeMutablePointer<CChar> = .allocate(capacity: full_flags_cstring.count)
    flags_ptr.initialize(from: full_flags_cstring, count: full_flags_cstring.count)
    triangulate(flags_ptr, &input, &output, nil)
    
    // Return the mesh
    // return V2
    let v2_values_ptr: UnsafeMutablePointer<Double> = .allocate(capacity: Int(output.numberofpoints) * 2)
    v2_values_ptr.initialize(from: output.pointlist, count: Int(output.numberofpoints) * 2)
    let v2_ptr = SharedPointer(v2_values_ptr)
    V2 = .init(v2_ptr, [Int(output.numberofpoints), 2])
    // return F2
    let f2_values_ptr: UnsafeMutablePointer<Int> = .allocate(capacity: Int(output.numberoftriangles) * 3)
    for i in 0..<(3 * Int(output.numberoftriangles)) {
        f2_values_ptr[i] = Int(output.trianglelist[i])
    }
    F2 = .init(SharedPointer(f2_values_ptr), [Int(output.numberoftriangles), 3])
    // return E2
    let e2_values_ptr: UnsafeMutablePointer<Int> = .allocate(capacity: Int(output.numberofsegments) * 2)
    for i in 0..<(Int(output.numberofsegments) * 2) {
        e2_values_ptr[i] = Int(output.segmentlist[i])
    }
    E2 = .init(SharedPointer(e2_values_ptr), [Int(output.numberofsegments), 2])
    
    if (VM.size.count != 0) {
        // return VM2
        let vm2_values_ptr: UnsafeMutablePointer<Int> = .allocate(capacity: Int(output.numberofpoints))
        for i in 0..<Int(output.numberofpoints) {
            vm2_values_ptr[i] = Int(output.pointmarkerlist[i])
        }
        VM2 = .init(SharedPointer(vm2_values_ptr), [Int(output.numberofpoints), 1])
    }
    
    if (EM.size.count != 0) {
        // return EM2
        let em2_values_ptr: UnsafeMutablePointer<Int> = .allocate(capacity: Int(output.numberofsegments))
        for i in 0..<Int(output.numberofsegments) {
            em2_values_ptr[i] = Int(output.segmentmarkerlist[i])
        }
        EM2 = .init(SharedPointer(em2_values_ptr), [Int(output.numberofsegments), 1])
    }
    
    // Cleanup in
    input.pointlist?.deallocate()
    input.pointmarkerlist?.deallocate()
    input.segmentlist?.deallocate()
    input.segmentmarkerlist?.deallocate()
    input.holelist?.deallocate()
    
    // Cleanup out
    output.pointlist?.deallocate()
    output.trianglelist?.deallocate()
    output.segmentlist?.deallocate()
    output.segmentmarkerlist?.deallocate()
    output.pointmarkerlist?.deallocate()
}

public func triangulate
<DerivedV: Matrix, DerivedE: Matrix, DerivedH: Matrix, DerivedV2: Matrix, DerivedF2: Matrix>
(_ V: DerivedV, _ E: DerivedE, _ H: DerivedH, _ flags: String, _ V2: inout DerivedV2, _ F2: inout DerivedF2)
where DerivedV.Element == Double, DerivedE.Element == Int, DerivedH.Element == Double, DerivedV2.Element == Double, DerivedF2.Element == Int
{
    var VM = Veci()
    var EM = Veci()
    var VM2 = Veci()
    var EM2 = Veci()
    var E2 = Mati()
    
    return triangulate(V, E, H, VM, EM, flags, &V2, &F2, &VM2, &E2, &EM2)
}
