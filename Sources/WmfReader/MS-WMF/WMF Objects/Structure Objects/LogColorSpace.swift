//
//  LogColorSpace.swift
//  
//
//  Created by Hugh Bellamy on 02/12/2020.
//

import DataStream

/// [MS-WMF] 2.2.2.11 LogColorSpace Object
/// The LogColorSpace Object specifies a logical color space for the playback device context, which can be the name of a color profile
/// in ASCII characters.
public struct LogColorSpace {
    public let signature: UInt32
    public let version: UInt32
    public let size: UInt32
    public let colorSpaceType: LogicalColorSpace
    public let intent: GamutMappingIntent
    public let endpoints: CIEXYZTriple
    public let gammaRed: Int32
    public let gammaGreen: Int32
    public let gammaBlue: Int32
    public let filename: String
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// Signature (4 bytes): A 32-bit unsigned integer that specifies the signature of color space objects; it MUST be set to the
        /// value 0x50534F43, which is the ASCII encoding of the string "PSOC".
        self.signature = try dataStream.read(endianess: .littleEndian)
        guard self.signature == 0x50534F43 else {
            throw WmfReadError.corrupted
        }
        
        /// Version (4 bytes): A 32-bit unsigned integer that defines a version number; it MUST be 0x00000400.
        self.version = try dataStream.read(endianess: .littleEndian)
        guard self.version == 0x00000400 else {
            throw WmfReadError.corrupted
        }
        
        /// Size (4 bytes): A 32-bit unsigned integer that defines the size of this object, in bytes.
        self.size = try dataStream.read(endianess: .littleEndian)
        guard self.size == 0x00000148 else {
            throw WmfReadError.corrupted
        }
        
        /// ColorSpaceType (4 bytes): A 32-bit signed integer that specifies the color space type. It MUST be defined in the
        /// LogicalColorSpace Enumeration (section 2.1.1.14). If this value is LCS_sRGB or LCS_WINDOWS_COLOR_SPACE, the
        /// sRGB color space MUST be used.
        self.colorSpaceType = try LogicalColorSpace(dataStream: &dataStream)
        
        /// Intent (4 bytes): A 32-bit signed integer that defines the gamut mapping intent. It MUST be defined in the
        /// GamutMappingIntent Enumeration (section 2.1.1.11).
        self.intent = try GamutMappingIntent(dataStream: &dataStream)
        
        /// Endpoints (36 bytes): A CIEXYZTriple Object (section 2.2.2.7) that defines the CIE chromaticity x, y, and z coordinates of
        /// the three colors that correspond to the RGB endpoints for the logical color space associated with the bitmap. If the
        /// ColorSpaceType field does not specify LCS_CALIBRATED_RGB, this field MUST be ignored.
        self.endpoints = try CIEXYZTriple(dataStream: &dataStream)
        
        /// GammaRed (4 bytes): A 32-bit fixed point value that defines the toned response curve for red. If the ColorSpaceType field
        /// does not specify LCS_CALIBRATED_RGB, this field MUST be ignored.
        self.gammaRed = try dataStream.read(endianess: .littleEndian)
        
        /// GammaGreen (4 bytes): A 32-bit fixed point value that defines the toned response curve for green. If the ColorSpaceType
        /// field does not specify LCS_CALIBRATED_RGB, this field MUST be ignored.
        self.gammaGreen = try dataStream.read(endianess: .littleEndian)
        
        /// GammaBlue (4 bytes): A 32-bit fixed point value that defines the toned response curve for blue. If the ColorSpaceType
        /// field does not specify LCS_CALIBRATED_RGB, this field MUST be ignored.
        self.gammaBlue = try dataStream.read(endianess: .littleEndian)
        
        /// Filename (260 bytes): An optional, ASCII charactger string that specifies the name of a file that contains a color profile.
        /// If a file name is specified, and the ColorSpaceType field is set to LCS_CALIBRATED_RGB, the other fields of this
        /// structure SHOULD be ignored.
        /// The Endpoints, GammaRed, GammaGreen, and GammaBlue fields are used to specify a logical color space. The Endpoints
        /// field is a CIEXYZTriple Object that contains the x, y, and z values of the RGB endpoint of the color space.
        /// The relation between tri-stimulus values X,Y,Z and chromaticity values x,y,z is expressed as follows.
        /// x = X/(X+Y+Z)
        /// y = Y/(X+Y+Z)
        /// z = Z/(X+Y+Z)
        self.filename = try dataStream.readString(count: 260, encoding: .ascii)!.trimmingCharacters(in: ["\0"])
        
        guard dataStream.position - startPosition == self.size else {
            throw WmfReadError.corrupted
        }
    }
}
