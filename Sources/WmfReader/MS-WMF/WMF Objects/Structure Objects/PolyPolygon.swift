//
//  PolyPolygon.swift
//  
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.2.2.17 PolyPolygon Object
/// The PolyPolygon Object defines a series of closed polygons.
public struct PolyPolygon {
    public let numberOfPolygons: UInt16
    public let aPointsPerPolygon: [UInt16]
    public let aPoints: [PointS]
    
    public init(dataStream: inout DataStream, recordSize: UInt32) throws {
        /// NumberOfPolygons (2 bytes): A 16-bit unsigned integer that defines the number of polygons in the object.
        self.numberOfPolygons = try dataStream.read(endianess: .littleEndian)
        guard recordSize >= 4 + self.numberOfPolygons else {
            throw WmfReadError.corrupted
        }
        
        /// aPointsPerPolygon (variable): A NumberOfPolygons array of 16-bit unsigned integers that define the number of points for each
        /// polygon in the object.
        var numberOfPolygonPoints = 0
        var aPointsPerPolygon: [UInt16] = []
        aPointsPerPolygon.reserveCapacity(Int(self.numberOfPolygons))
        for _ in 0..<self.numberOfPolygons {
            let value: UInt16 = try dataStream.read(endianess: .littleEndian)
            aPointsPerPolygon.append(value)
            numberOfPolygonPoints += Int(value)
        }
        
        self.aPointsPerPolygon = aPointsPerPolygon
        
        guard recordSize == 4 + UInt32(self.numberOfPolygons) + 2 * UInt32(numberOfPolygonPoints) else {
            throw WmfReadError.corrupted
        }
        
        /// aPoints (variable): An array of PointS values that define the coordinates of
        /// the polygons. The length of the array is equal to the sum of all 16-bit integers in the
        /// aPointsPerPolygon array.
        var aPoints: [PointS] = []
        aPoints.reserveCapacity(numberOfPolygonPoints)
        for _ in 0..<numberOfPolygonPoints {
            aPoints.append(try PointS(dataStream: &dataStream))
        }
        
        self.aPoints = aPoints       
    }
}
