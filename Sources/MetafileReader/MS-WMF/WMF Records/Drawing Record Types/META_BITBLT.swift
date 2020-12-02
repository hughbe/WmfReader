//
//  META_BITBLT.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream
import Foundation

/// [MS-WMF] 2.3.1.1 META_BITBLT Record
/// The META_BITBLT Record specifies the transfer of a block of pixels according to a raster operation.The destination of the transfer
/// is the current output region in the playback device context.
/// There are two forms of META_BITBLT, one which specifies a bitmap as the source, and the other which uses the playback device
/// context as the source. The fields that are the same in the two forms of META_BITBLT are defined below. The subsections that follow
/// specify the packet structures of the two forms of META_BITBLT.
/// The RecordSize and RecordFunction fields SHOULD be used to differentiate between the two forms of META_BITBLT. If the following
/// Boolean expression is TRUE, a source bitmap is not specified in the record. RecordSize == ((RecordFunction >> 8) + 3)
public struct META_BITBLT {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let rasterOperation: UInt32
    public let ySrc: Int16
    public let xSrc: Int16
    public let reserved: UInt16?
    public let height: Int16
    public let width: Int16
    public let yDest: Int16
    public let xDest: Int16
    public let target: Bitmap16?
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        self.recordSize = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize >= 8 else {
            throw MetafileReadError.corrupted
        }
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_BITBLT.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_BITBLT.rawValue & 0xFF else {
            throw MetafileReadError.corrupted
        }
        
        let noTarget = self.recordSize == ((self.recordFunction >> 8) + 3)

        /// RasterOperation: A 32-bit unsigned integer that defines how the source pixels, the current brush in the playback device
        /// context, and the destination pixels are to be combined to form the new image. This code MUST be one of the values in
        /// the Ternary Raster Operation Enumeration (section 2.1.1.31).
        self.rasterOperation = try dataStream.read(endianess: .littleEndian)
        
        /// YSrc: A 16-bit signed integer that defines the y-coordinate, in logical units, of the upper-left corner of the source rectangle.
        self.ySrc = try dataStream.read(endianess: .littleEndian)
        
        /// XSrc: A 16-bit signed integer that defines the x-coordinate, in logical units, of the upper-left corner of the source rectangle.
        self.xSrc = try dataStream.read(endianess: .littleEndian)
            
        /// [MS-WMF] 2.3.1.1.2 Without Bitmap
        /// This section specifies the structure of the META_BITBLT Record (section 2.3.1.1) when it does not contain an embedded source
        /// bitmap. The source for this operation is the current region in the playback device context.
        /// Fields not specified in this section are specified in the META_BITBLT Record section.
        /// Reserved (2 bytes): This field MUST be ignored.
        if noTarget {
            self.reserved = try dataStream.read(endianess: .littleEndian)
        } else {
            self.reserved = nil
        }
        
        /// Height: A 16-bit signed integer that defines the height, in logical units, of the source and destination rectangles.
        self.height = try dataStream.read(endianess: .littleEndian)
        
        /// Width: A 16-bit signed integer that defines the width, in logical units, of the source and destination rectangles.
        self.width = try dataStream.read(endianess: .littleEndian)
        
        /// YDest: A 16-bit signed integer that defines the y-coordinate, in logical units, of the upper-left corner of the destination
        /// rectangle.
        self.yDest = try dataStream.read(endianess: .littleEndian)
        
        /// XDest: A 16-bit signed integer that defines the x-coordinate, in logical units, of the upper-left corner of the destination
        /// rectangle.
        self.xDest = try dataStream.read(endianess: .littleEndian)
        
        /// [MS-WMF] 2.3.1.1.1 With Bitmap
        /// This section specifies the structure of the META_BITBLT Record (section 2.3.1.1) when it contains an embedded bitmap.
        /// Fields not specified in this section are specified in the META_BITBLT Record section.
        /// Target (variable): A variable-sized Bitmap16 Object (section 2.2.2.1) that defines source image content. This object MUST
        /// be specified, even if the raster operation does not require a source.
        if !noTarget {
            self.target = try Bitmap16(dataStream: &dataStream)
        } else {
            self.target = nil
        }

        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
            throw MetafileReadError.corrupted
        }
    }
}
