//
//  META_ESCAPE.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.3.6.1 META_ESCAPE Record
/// The META_ESCAPE Record specifies extensions to WMF functionality that are not directly available through other records defined in the
/// RecordType Enumeration (section 2.1.1.1). The MetafileEscapes Enumeration (section 2.1.1.17) lists these extensions.
/// Every META_ESCAPE MUST include a MetafileEscapes function specifier, followed by arbitrary data. The data SHOULD NOT contain
/// position-specific data that assumes the location of a particular record within the metafile, because one metafile might be embedded
/// within another.
/// See section 2.3.6 for the specification of other Escape Record Types.
public struct META_ESCAPE {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let data: EscapeData
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        self.recordSize = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize >= 3 else {
            throw WmfReadError.corrupted
        }
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_ESCAPE.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_ESCAPE.rawValue & 0xFF else {
            throw WmfReadError.corrupted
        }
        
        func readString(recordSize: UInt32) throws -> String {
            let string = try dataStream.readString(count: Int(recordSize * 2) - 6, encoding: .ascii)?.trimmingCharacters(in: ["\0"]) ?? ""
            guard (dataStream.position - startPosition) / 2 == recordSize else {
                throw WmfReadError.corrupted
            }
            
            return string
        }
        
        // No data or short data: must be empty string.
        if self.recordSize < 5 {
            self.data = .string(try readString(recordSize: recordSize))
            return
        }
        
        // Peek at the escape function. If it is invalid, interpret this as a string.
        let position = dataStream.position
        guard MetafileEscapes(rawValue: try dataStream.read(endianess: .littleEndian)) != nil else {
            dataStream.position = position
            self.data = .string(try readString(recordSize: recordSize))
            return
        }
        
        // Peek at the byte count. If it is invalid, interpret this as a string.
        let byteCount: UInt16 = try dataStream.read(endianess: .littleEndian)
        guard recordSize == 5 + byteCount / 2 else {
            dataStream.position = position
            self.data = .string(try readString(recordSize: recordSize))
            return
        }

        dataStream.position = position
        self.data = .escape(try META_ESCAPEDATA(dataStream: &dataStream, recordSize: self.recordSize))
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw WmfReadError.corrupted
        }
    }
    
    public enum EscapeData {
        case string(_: String)
        case escape(_: META_ESCAPEDATA)
    }
    
    public struct META_ESCAPEDATA {
        public let escapeFunction: MetafileEscapes
        public let byteCount: UInt16
        public let escapeData: [UInt8]

        public init(dataStream: inout DataStream, recordSize: UInt32) throws {
            /// EscapeFunction (2 bytes): A 16-bit unsigned integer that defines the escape function. The value MUST be from the
            /// MetafileEscapes Enumeration.
            self.escapeFunction = try MetafileEscapes(dataStream: &dataStream)
            
            /// ByteCount (2 bytes): A 16-bit unsigned integer that specifies the size, in bytes, of the EscapeData field.
            self.byteCount = try dataStream.read(endianess: .littleEndian)
            guard recordSize == 5 + self.byteCount / 2 else {
                throw WmfReadError.corrupted
            }
            
            /// EscapeData (variable): An array of bytes of size ByteCount.
            self.escapeData = try dataStream.readBytes(count: Int(self.byteCount))
        }
    }
}
