//
//  DRAWPATTERNRECT.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.3.6.10 DRAWPATTERNRECT Record
/// The DRAWPATTERNRECT Record draws a rectangle with a defined pattern.
/// See section 2.3.6 for the specification of other Escape Record Types.
public struct DRAWPATTERNRECT {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let escapeFunction: MetafileEscapes
    public let byteCount: UInt16
    public let position: PointL
    public let size: PointL
    public let style: UInt16
    public let pattern: UInt16
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        self.recordSize = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize == 15 else {
            throw WmfReadError.corrupted
        }
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_ESCAPE.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_ESCAPE.rawValue & 0xFF else {
            throw WmfReadError.corrupted
        }
        
        /// EscapeFunction (2 bytes): A 16-bit unsigned integer that defines the escape function. The value MUST be 0x0019
        /// (DRAWPATTERNRECT) from the MetafileEscapes Enumeration (section 2.1.1.17) table.
        self.escapeFunction = try MetafileEscapes(dataStream: &dataStream)
        guard self.escapeFunction == .DRAWPATTERNRECT else {
            throw WmfReadError.corrupted
        }
        
        /// ByteCount (2 bytes): A 16-bit unsigned integer that specifies the size, in bytes, of the record data that follows.
        /// This MUST be 0x0014.
        self.byteCount = try dataStream.read(endianess: .littleEndian)
        guard self.byteCount == 0x0014 else {
            throw WmfReadError.corrupted
        }
        
        /// Position (8 bytes): A PointL Object (section 2.2.2.15) that defines the position of the rectangle.
        self.position = try PointL(dataStream: &dataStream)
        
        /// Size (8 bytes): A PointL Object that defines the dimensions of the rectangle.
        self.size = try PointL(dataStream: &dataStream)
       
        /// Style (2 bytes): A 16-bit unsigned integer that defines the style.
        self.style = try dataStream.read(endianess: .littleEndian)
        
        /// Pattern (2 bytes): A 16-bit unsigned integer that defines the pattern.
        self.pattern = try dataStream.read(endianess: .littleEndian)
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw WmfReadError.corrupted
        }
    }
}
