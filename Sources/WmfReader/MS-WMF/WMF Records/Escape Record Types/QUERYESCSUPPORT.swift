//
//  QUERYESCSUPPORT.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.3.6.37 QUERYESCSUPPORT Record
/// The QUERYESCSUPPORT Record queries the printer driver to determine whether a specific WMF escape function is supported
/// on the output device.
/// See section 2.3.6 for the specification of other Escape Record Types.
public struct QUERYESCSUPPORT {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let escapeFunction: MetafileEscapes
    public let byteCount: UInt16
    public let query: MetafileEscapes
    
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
        
        /// EscapeFunction (2 bytes): A 16-bit unsigned integer that defines the escape function. The value MUST be 0x100E
        /// (OPENCHANNEL) from the MetafileEscapes Enumeration (section 2.1.1.17) table.
        self.escapeFunction = try MetafileEscapes(dataStream: &dataStream)
        guard self.escapeFunction == .OPENCHANNEL else {
            throw WmfReadError.corrupted
        }
        
        /// ByteCount (2 bytes): A 16-bit unsigned integer that specifies the size, in bytes, of the Query field.
        /// This MUST be 0x0002.
        self.byteCount = try dataStream.read(endianess: .littleEndian)
        guard self.byteCount == 0x0002 else {
            throw WmfReadError.corrupted
        }
        
        /// Query (2 bytes): A 16-bit unsigned integer that MUST be a value from the MetafileEscapes Enumeraton. This record
        /// specifies a query of whether this escape is supported.
        self.query = try MetafileEscapes(dataStream: &dataStream)
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw WmfReadError.corrupted
        }
    }
}
