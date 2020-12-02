//
//  META_SELECTCLIPREGION.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.3.4.9 META_SELECTCLIPREGION Record
/// The META_SELECTCLIPREGION Record specifies a Region Object (section 2.2.1.5) to be the current clipping region.
/// The WMF Object Table refers to an indexed table of WMF Objects (section 2.2) that are defined in the metafile. See section 3.1.4.1 formore information.
/// See section 2.3.4 for the specification of other Object Records.
public struct META_SELECTCLIPREGION {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let region: UInt16
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        self.recordSize = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize == 4 else {
            throw MetafileReadError.corrupted
        }
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_SELECTCLIPREGION.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_SELECTCLIPREGION.rawValue & 0xFF else {
            throw MetafileReadError.corrupted
        }
        
        /// Region (2 bytes): A 16-bit unsigned integer used to index into the WMF Object Table (section 3.1.4.1) to get the region
        /// to be inverted.
        self.region = try dataStream.read(endianess: .littleEndian)
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw MetafileReadError.corrupted
        }
    }
}
