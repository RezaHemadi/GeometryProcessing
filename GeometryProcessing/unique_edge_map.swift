//
//  unique_edge_map.swift
//  GeometryProcessing
//
//  Created by Reza on 8/4/23.
//

import Foundation
import Matrix

// Construct relationships between facet "half"-(or rather "viewed")-edges E
// to unique edges of the mesh seen as a graph.
//
// Inputs:
//   F  #F by 3  list of simplices
// Outputs:
//   E  #F*3 by 2 list of all directed edges, such that E.row(f+#F*c) is the
//     edge opposite F(f,c)
//   uE  #uE by 2 list of unique undirected edges
//   EMAP #F*3 list of indices into uE, mapping each directed edge to unique
//     undirected edge so that uE(EMAP(f+#F*c)) is the unique edge
//     corresponding to E.row(f+#F*c)
//   uE2E  #uE list of lists of indices into E of coexisting edges, so that
//     E.row(uE2E[i][j]) corresponds to uE.row(i) for all j in
//     0..uE2E[i].size()-1.
public func unique_edge_map<MuE: Matrix>(_ F: Mati, _ E: inout Mati, _ uE: inout MuE, _ EMAP: inout Veci, _ uE2E: inout [[Int]])
where MuE.Element == Int
{
    unique_edge_map(F, &E, &uE, &EMAP)
    uE2E = .init(repeating: [0, 0], count: uE.rows)
    let ne: Int = E.rows
    assert(EMAP.count == ne)
    
    for e in 0..<ne {
        uE2E[EMAP[e]].append(e)
    }
}

public func unique_edge_map<MuE: Matrix>
(_ F: Mati, _ E: inout Mati, _ uE: inout MuE, _ EMAP: inout Veci)
where MuE.Element == Int
{
    // All occurrences of directed edges
    oriented_facets(F, &E)
    let ne: Int = E.rows
    // This is 2x faster to create than a map from pairs to lists of edges and 5x
    // faster to access (actually access is probably assympotically faster O(1)
    // vs. O(log m)
    var IA = Veci()
    unique_simplices(E, &uE, &IA, &EMAP)
    assert(EMAP.count == ne)
}

// Outputs:
//   uEC  #uE+1 list of cumulative counts of directed edges sharing each
//     unique edge so the uEC(i+1)-uEC(i) is the number of directed edges
//     sharing the ith unique edge.
//   uEE  #E list of indices into E, so that the consecutive segment of
//     indices uEE.segment(uEC(i),uEC(i+1)-uEC(i)) lists all directed edges
//     sharing the ith unique edge.
//
// // Using uE2E
// for(int u = 0;u<uE2E.size();u++)
// {
//   for(int i = 0;i<uE2E[u].size();i++)
//   {
//     // eth directed-edge is ith edge equivalent to uth undirected edge
//     e = uE2E[u][i];
//   }
// }
//
// // Using uEC,uEE
// for(int u = 0;u<uE.size();u++)
// {
//   for(int j = uEC(u);j<uEC(u+1);j++)
//   {
//     e = uEE(j); // i = j-uEC(u);
//   }
// }
//
func unique_edge_map<MuE: Matrix, MuEE: Matrix>
(_ F: Mati, _ E: inout Mati, _ uE: inout MuE, _ EMAP: inout Veci, _ uEC: inout Veci, _ uEE: inout MuEE)
where MuE.Element == Int, MuEE.Element == Int
{
    // Avoid using uE2E
    unique_edge_map(F, &E, &uE, &EMAP)
    var uEK = Veci()
    accumarray(EMAP, 1, &uEK)
    
    assert(uEK.rows == uE.rows)
    
    // base offset in uEE
    cumsum(uEK, 1, true, &uEC)
    assert(uEK.rows + 1 == uEC.rows)
    
    // running inner offset in uEE
    var uEO: Veci = .Zero(uE.rows)
    // flat array of faces inside on each uE
    uEE.resize(EMAP.rows, 1)
    
    for e in 0..<EMAP.rows {
        let ue = EMAP[e]
        let i = uEC[ue] + uEO[ue]
        uEE[i] = e
        uEO[ue] += 1
    }
}
