//
//  META_POLYGON.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.3.3.15 META_POLYGON Record
/// The META_POLYGON Record paints a polygon consisting of two or more vertices connected by straight lines. The polygon is outlined by
/// using the pen and filled by using the brush and polygon fill mode that are defined in the playback device context.
/// See section 2.3.3 for the specification of other Drawing Records.
public struct META_POLYGON {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let numberOfPoints: UInt16
    public let aPoints: [PointS]
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        self.recordSize = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize >= 4 else {
            throw WmfReadError.corrupted
        }
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_POLYGON.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_POLYGON.rawValue & 0xFF else {
            throw WmfReadError.corrupted
        }
        
        /// NumberOfPoints (2 bytes): A 16-bit signed integer that defines the number of points in the array. This value must be greater than
        /// or equal to 2.
        self.numberOfPoints = try dataStream.read(endianess: .littleEndian)
        guard self.numberOfPoints >= 2 && self.recordSize == 4 + 2 * self.numberOfPoints else {
            throw WmfReadError.corrupted
        }
        
        /// aPoints (variable): A NumberOfPoints array of 32-bit PointS Objects (section 2.2.2.16), in logical units.
        var aPoints: [PointS] = []
        aPoints.reserveCapacity(Int(self.numberOfPoints))
        for _ in 0..<self.numberOfPoints {
            aPoints.append(try PointS(dataStream: &dataStream))
        }
        
        self.aPoints = aPoints
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw WmfReadError.corrupted
        }
    }
}
