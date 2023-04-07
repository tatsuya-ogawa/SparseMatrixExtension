import simd
import Accelerate
extension SparseMatrix_Double{
    public struct Triplet{
        public var row:Int
        public var col:Int
        public var value:Double
        public init(row: Int, col: Int, value: Double) {
            self.row = row
            self.col = col
            self.value = value
        }
    }
    public static func fromTriplets(triplets:[Triplet],rowCount:Int32,columnCount:Int32)->SparseMatrix_Double{
        let attributes = SparseAttributes_t()
        
        var row: [Int32] =      triplets.map{Int32($0.row)}
        var column: [Int32] =     triplets.map{Int32($0.col)}
        var values =             triplets.map{$0.value}
        
        let blockCount = triplets.count
        let blockSize = 1
        
        return SparseConvertFromCoordinate(rowCount, columnCount,
                                           blockCount, UInt8(blockSize),
                                           attributes,
                                           &row, &column,
                                           &values)
    }
    public func toTriplets()->[Triplet]{
        return (0..<self.structure.columnCount).enumerated().flatMap{(columnIndice,columnStart) in
            return (self.structure.columnStarts[Int(columnStart)]..<self.structure.columnStarts[Int(columnStart)+1]).enumerated().map{ (valueIndice,rowIndice) in
                return Triplet(row: Int(self.structure.rowIndices[rowIndice]), col: columnIndice, value: self.data[valueIndice])
            }
        }
    }
    public enum ConcatAxis{
        case row
        case column
    }
    public static func concat(a:SparseMatrix_Double,b:SparseMatrix_Double,axis:ConcatAxis)->SparseMatrix_Double{
        switch axis{
        case .row: do {
            return SparseMatrix_Double.fromTriplets(triplets: a.toTriplets() + b.toTriplets(), rowCount: a.structure.rowCount + b.structure.rowCount, columnCount: a.structure.columnCount)
        }
        case .column: do {
            return SparseMatrix_Double.fromTriplets(triplets: a.toTriplets() + b.toTriplets(), rowCount: a.structure.rowCount + b.structure.rowCount, columnCount: a.structure.columnCount)
        }
        }
    }
}
