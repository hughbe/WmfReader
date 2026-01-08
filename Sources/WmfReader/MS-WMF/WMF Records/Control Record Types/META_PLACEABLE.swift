//
//  META_PLACEABLE.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.3.2.3 META_PLACEABLE Record
/// The META_PLACEABLE Record is the first record in a placeable WMF metafile, which is an extension to the WMF metafile format.<55>
/// The information in this extension allows the specification of the placement and size of the target image, which makes it adaptable to
/// different output devices.
/// The META_PLACEABLE MUST be the first record of the metafile, located immediately before the META_HEADER Record (section 2.3.2.2).
/// See section 2.3.2 for the specification of similar records.
public struct META_PLACEABLE {
    public let key: UInt32
    public let hWmf: UInt16
    public let boundingBox: Rect
    public let inch: UInt16
    public let reserved: UInt32
    public let checksum: UInt16
    
    public init(dataStream: inout DataStream) throws {
        /// Key (4 bytes): Identification value that indicates the presence of a placeable metafile header. This value MUST be 0x9AC6CDD7.
        self.key = try dataStream.read(endianess: .littleEndian)
        guard self.key == 0x9AC6CDD7 else {
            throw WmfReadError.corrupted
        }
        
        /// HWmf (2 bytes): The resource handle to the metafile, when the metafile is in memory. When the metafile is on disk, this field MUST
        /// contain 0x0000. This attribute of the metafile is specified in the Type field of the META_HEADER Record.
        self.hWmf = try dataStream.read(endianess: .littleEndian)
        
        /// BoundingBox (8 bytes): The rectangle in the playback context (or simply the destination rectangle), measured in logical units, for
        /// displaying the metafile. The size of a logical unit is specified by the Inch field. See section 2.2.2.18 for details about the
        /// structure of the BoundingBox field.
        self.boundingBox = try Rect(dataStream: &dataStream)
        
        /// Inch (2 bytes): The number of logical units per inch used to represent the image. This value can be used to scale an image.
        /// By convention, an image is considered to be recorded at 1440 logical units (twips) per inch. Thus, a value of 720 specifies that
        /// the image SHOULD be rendered at twice its normal size, and a value of 2880 specifies that the image SHOULD be rendered at
        /// half its normal size.
        self.inch = try dataStream.read(endianess: .littleEndian)
        
        /// Reserved (4 bytes): A field that is not used and MUST be set to 0x00000000.
        self.reserved = try dataStream.read(endianess: .littleEndian)
        guard self.reserved == 0x00000000 else {
            throw WmfReadError.corrupted
        }
        
        /// Checksum (2 bytes): A checksum for the previous 10 16-bit values in the header. This value can be used to determine whether the
        /// metafile has become corrupted. The value is calculated by initializing the checksum to zero and then XORing it one at a time
        /// with the 10 16-bit values in the header.
        self.checksum = try dataStream.read(endianess: .littleEndian)
        let calculatedChecksum =
            UInt16((self.key & 0xFFFF)) ^
            UInt16(((self.key >> 16) & 0xFFFF)) ^
            self.hWmf ^
            UInt16(bitPattern: self.boundingBox.left) ^
            UInt16(bitPattern: self.boundingBox.top) ^
            UInt16(bitPattern: self.boundingBox.right) ^
            UInt16(bitPattern: self.boundingBox.bottom) ^
            self.inch ^
            UInt16((self.reserved & 0xFFFF)) ^
            UInt16(((self.reserved >> 16) & 0xFFFF))
        guard self.checksum == calculatedChecksum else {
            throw WmfReadError.corrupted
        }
    }
}
