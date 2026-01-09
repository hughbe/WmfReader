//
//  GETCOLORTABLE.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.3.6.16 GETCOLORTABLE Record
/// The GETCOLORTABLE Record gets color table values from the printer driver.
/// See section 2.3.6 for the specification of other Escape Record Types.
public struct GETCOLORTABLE {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let escapeFunction: MetafileEscapes
    public let byteCount: UInt16
    public let start: UInt16
    public let colorTableBuffer: [UInt8]
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        let recordSize: UInt32 = try dataStream.read(endianess: .littleEndian)
        guard recordSize >= 6 else {
            throw WmfReadError.corrupted
        }
        
        self.recordSize = recordSize
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_ESCAPE.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_ESCAPE.rawValue & 0xFF else {
            throw WmfReadError.corrupted
        }
        
        /// EscapeFunction (2 bytes): A 16-bit unsigned integer that defines the escape function. The value MUST be 0x0005
        /// (GETCOLORTABLE) from the MetafileEscapes Enumeration (section 2.1.1.17) table.
        self.escapeFunction = try MetafileEscapes(dataStream: &dataStream)
        guard self.escapeFunction == .GETCOLORTABLE else {
            throw WmfReadError.corrupted
        }
        
        /// ByteCount (2 bytes): A 16-bit unsigned integer that specifies the size, in bytes, of the record data that follows.
        let byteCount: UInt16 = try dataStream.read(endianess: .littleEndian)
        guard byteCount >= 2 && recordSize == 5 + byteCount / 2 else {
            throw WmfReadError.corrupted
        }
        
        self.byteCount = byteCount
        
        /// Start (2 bytes): A 16-bit unsigned integer that defines the offset from the beginning of the record to the start of the color
        /// table data in the ColorTable field.
        self.start = try dataStream.read(endianess: .littleEndian)
        
        /// ColorTableBuffer (variable): A buffer containing the color table that is obtained from the printer driver, which is not required
        /// to be contiguous with the static part of the record.
        /// UndefinedSpace (variable): An optional field that MUST be ignored.
        /// ColorTable (variable): An array of bytes that define the color table. The location of this field within the record is specified by
        /// the Start field.
        self.colorTableBuffer = try dataStream.readBytes(count: Int(self.byteCount) - 2)
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw WmfReadError.corrupted
        }
    }
}
