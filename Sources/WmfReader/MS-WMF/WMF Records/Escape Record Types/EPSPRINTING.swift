//
//  EPSPRINTING.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.3.6.14 EPSPRINTING Record
/// The EPSPRINTING Record indicates the start or end of Encapsulated PostScript (EPS) printing.
/// See section 2.3.6 for the specification of other Escape Record Types.
public struct EPSPRINTING {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let escapeFunction: MetafileEscapes
    public let byteCount: UInt16
    public let setEpsPrinting: UInt16
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        self.recordSize = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize == 6 else {
            throw WmfReadError.corrupted
        }
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_ESCAPE.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_ESCAPE.rawValue & 0xFF else {
            throw WmfReadError.corrupted
        }
        
        /// EscapeFunction (2 bytes): A 16-bit unsigned integer that defines the escape function. The value MUST be 0x0021
        /// (EPSPRINTING) from the MetafileEscapes Enumeration (section 2.1.1.17) table.
        self.escapeFunction = try MetafileEscapes(dataStream: &dataStream)
        guard self.escapeFunction == .EPSPRINTING else {
            throw WmfReadError.corrupted
        }
        
        /// ByteCount (2 bytes): A 16-bit unsigned integer that specifies the size, in bytes, of the SetEpsPrinting field.
        /// This MUST be 0x0002.
        self.byteCount = try dataStream.read(endianess: .littleEndian)
        guard self.byteCount == 0x0002 else {
            throw WmfReadError.corrupted
        }
        
        /// SetEpsPrinting (2 bytes): A 16-bit unsigned integer that indicates the start or end of EPS printing.
        /// If the value is nonzero, the start of EPS printing is indicated; otherwise, the end is indicated.
        /// Value Meaning
        /// Start 0x0000 < value The start of EPS printing.
        /// End 0x0000 The end of EPS printing.
        self.setEpsPrinting = try dataStream.read(endianess: .littleEndian)
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw WmfReadError.corrupted
        }
    }
}
