# SparseMatrix Extensions

This Swift library provides extensions to the SparseMatrix_Double class, enhancing its functionality for handling sparse matrix data structures. The sparse matrix representation is beneficial for matrices with a significant number of zero elements, as it allows for efficient memory usage and faster computations.

## Features
* Creation of sparse matrices from triplets (row, column, value)
* Conversion of sparse matrices back to triplets
* Concatenation of two sparse matrices along row or column axis

## Usage
### Creating a SparseMatrix_Double from triplets
```
import simd
import Accelerate

let triplets: [Triplet] = [
    .init(row: 0, col: 0, value: 1.0),
    .init(row: 1, col: 1, value: 2.0),
    .init(row: 2, col: 2, value: 3.0)
]

let rowCount: Int32 = 3
let columnCount: Int32 = 3

let sparseMatrix = SparseMatrix_Double.fromTriplets(triplets: triplets, rowCount: rowCount, columnCount: columnCount)
```

### Concatenating two SparseMatrix_Double instances
```
let a = SparseMatrix_Double.fromTriplets(triplets: [...], rowCount: rowCountA, columnCount: columnCountA)
let b = SparseMatrix_Double.fromTriplets(triplets: [...], rowCount: rowCountB, columnCount: columnCountB)

// Concatenate along the row axis
let concatenatedMatrixRow = SparseMatrix_Double.concat(a: a, b: b, axis: .row)

// Concatenate along the column axis
let concatenatedMatrixColumn = SparseMatrix_Double.concat(a: a, b: b, axis: .column)
```

## Dependencies
simd for vector and matrix operations
Accelerate for efficient linear algebra operations
