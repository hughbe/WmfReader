//
//  META_TEXTOUT.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream
import Foundation

/// [MS-WMF] 2.3.3.20 META_TEXTOUT Record
/// The META_TEXTOUT Record outputs a character string at the specified location by using the font, background color, and text
/// color that are defined in the playback device context.
/// See section 2.3.3 for the specification of other Drawing Records.
public struct META_TEXTOUT {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let stringLength: Int16
    public let string: String
    public let yStart: Int16
    public let xStart: Int16
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        self.recordSize = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize >= 6 else {
            throw WmfReadError.corrupted
        }
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_TEXTOUT.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_TEXTOUT.rawValue & 0xFF else {
            throw WmfReadError.corrupted
        }
        
        /// StringLength (2 bytes): A 16-bit signed integer that defines the length of the string, in bytes, pointed to by String.
        self.stringLength = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize == 6 + Int(ceil(Double(stringLength) / 2)) else {
            throw WmfReadError.corrupted
        }
        
        /// String (variable): The size of this field MUST be a multiple of two. If StringLength is an odd number, then this field MUST
        /// be of a size greater than or equal to StringLength + 1. A variable-length string that specifies the text to be drawn. The
        /// string does not need to be null-terminated, because StringLength specifies the length of the string. The string is written
        /// at the location specified by the XStart and YStart fields. See section 2.3.3.5 for information about the encoding of the field.
        self.string = try dataStream.readString(count: Int(self.stringLength), encoding: .ascii) ?? ""
        
        if (self.stringLength % 2) != 0 {
            let _: UInt8 = try dataStream.read()
        }
        
        /// YStart (2 bytes): A 16-bit signed integer that defines the vertical (y-axis) coordinate, in logical units, of the point where
        /// drawing is to start.
        self.yStart = try dataStream.read(endianess: .littleEndian)
        
        /// XStart (2 bytes): A 16-bit signed integer that defines the horizontal (x-axis) coordinate, in logical units, of the point where
        /// drawing is to start.
        self.xStart = try dataStream.read(endianess: .littleEndian)
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw WmfReadError.corrupted
        }
    }
}
