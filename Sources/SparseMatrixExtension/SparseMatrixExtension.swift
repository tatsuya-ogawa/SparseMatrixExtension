import simd
import Accelerate

public struct Triplet<T>{
    public var row:Int
    public var col:Int
    public var value:T
    public init(row: Int, col: Int, value: T) {
        self.row = row
        self.col = col
        self.value = value
    }
}
public enum ConcatAxis{
    case row
    case column
}
private protocol SparseMatrix{
    associatedtype Numeric
    init(structure: SparseMatrixStructure, data: UnsafeMutablePointer<Numeric>)
    var structure: SparseMatrixStructure { get set }
    var data: UnsafeMutablePointer<Numeric> { get set }
    static func fromTriplets(triplets:[Triplet<Numeric>],rowCount:Int32,columnCount:Int32)->Self
    func toTriplets()->[Triplet<Numeric>]
}
private func matrixToTriplets<T:SparseMatrix>(matrix:T)->[Triplet<T.Numeric>]{
    return (0..<matrix.structure.columnCount).enumerated().flatMap{(columnIndice,columnStart) in
        return (matrix.structure.columnStarts[Int(columnStart)]..<matrix.structure.columnStarts[Int(columnStart)+1]).enumerated().map{ (valueIndice,rowIndice) in
            return Triplet<T.Numeric>(row: Int(matrix.structure.rowIndices[rowIndice]), col: columnIndice, value: matrix.data[valueIndice])
        }
    }
}
private func matrixConcat<T:SparseMatrix>(a:T,b:T,axis:ConcatAxis)->T{
    switch axis{
    case .row: do {
        return T.fromTriplets(triplets: a.toTriplets() + b.toTriplets(), rowCount: a.structure.rowCount + b.structure.rowCount, columnCount: a.structure.columnCount)
    }
    case .column: do {
        return T.fromTriplets(triplets: a.toTriplets() + b.toTriplets(), rowCount: a.structure.rowCount + b.structure.rowCount, columnCount: a.structure.columnCount)
    }
    }
}

extension SparseMatrix_Double:SparseMatrix{
    public static func fromTriplets(triplets:[Triplet<Double>],rowCount:Int32,columnCount:Int32)->Self{
        let attributes = SparseAttributes_t()
        var row: [Int32] = triplets.map{Int32($0.row)}
        var column: [Int32] = triplets.map{Int32($0.col)}
        var values = triplets.map{$0.value}
        let blockCount = triplets.count
        let blockSize = 1
        return SparseConvertFromCoordinate(rowCount, columnCount,
                                           blockCount, UInt8(blockSize),
                                           attributes,
                                           &row, &column,
                                           &values)
    }
    public func toTriplets()->[Triplet<Double>]{
        return matrixToTriplets(matrix: self)
    }
    public static func concat(a:Self,b:Self,axis:ConcatAxis)->Self{
        return matrixConcat(a: a,b: b, axis: axis)
    }
}
extension SparseMatrix_Float:SparseMatrix{
    public static func fromTriplets(triplets:[Triplet<Float>],rowCount:Int32,columnCount:Int32)->Self{
        let attributes = SparseAttributes_t()
        var row: [Int32] = triplets.map{Int32($0.row)}
        var column: [Int32] = triplets.map{Int32($0.col)}
        var values = triplets.map{$0.value}
        let blockCount = triplets.count
        let blockSize = 1
        return SparseConvertFromCoordinate(rowCount, columnCount,
                                           blockCount, UInt8(blockSize),
                                           attributes,
                                           &row, &column,
                                           &values)
    }
    public func toTriplets()->[Triplet<Float>]{
        return matrixToTriplets(matrix: self)
    }
    public static func concat(a:SparseMatrix_Float,b:SparseMatrix_Float,axis:ConcatAxis)->SparseMatrix_Float{
        return matrixConcat(a: a,b: b, axis: axis)
    }
}
