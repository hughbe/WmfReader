//
//  Font.swift
//  
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.2.1.2 Font Object
/// The Font object specifies the attributes of a logical font.
public struct Font {
    public let height: Int16
    public let width: Int16
    public let escapement: Int16
    public let orientation: Int16
    public let weight: Int16
    public let italic: Bool
    public let underline: Bool
    public let strikeOut: Bool
    public let charSet: UInt8
    public let outPrecision: OutPrecision
    public let clipPrecision: ClipPrecision
    public let quality: FontQuality
    public let pitchAndFamily: PitchAndFamily
    public let facename: String
    
    public init(dataStream: inout DataStream, startPosition: Int, recordSize: UInt32) throws {
        /// Height (2 bytes): A 16-bit signed integer that specifies the height, in logical units, of the font's character cell. The character height
        /// is computed as the character cell height minus the internal leading. The font mapper SHOULD interpret the height as follows.
        /// Value Meaning
        /// value < 0x0000 The font mapper SHOULD transform this value into device units and match its
        /// absolute value against the character height of available fonts.
        /// 0x0000 A default height value MUST be used when creating a physical font.
        /// 0x0000 < value The font mapper SHOULD transform this value into device units and match it
        /// against the cell height of available fonts.
        /// For all height comparisons, the font mapper SHOULD find the largest physical font that does
        /// not exceed the requested size.<40>
        self.height = try dataStream.read(endianess: .littleEndian)
        
        /// Width (2 bytes): A 16-bit signed integer that defines the average width, in logical units, of characters in the font. If Width is 0x0000,
        /// the aspect ratio of the device SHOULD be matched against the digitization aspect ratio of the available fonts to find the closest
        /// match, determined by the absolute value of the difference.
        self.width = try dataStream.read(endianess: .littleEndian)
        
        /// Escapement (2 bytes): A 16-bit signed integer that defines the angle, in tenths of degrees, between the escapement vector and the
        /// x-axis of the device. The escapement vector is parallel to the base line of a row of text.
        self.escapement = try dataStream.read(endianess: .littleEndian)
        
        /// Orientation (2 bytes): A 16-bit signed integer that defines the angle, in tenths of degrees, between each character's base line and
        /// the x-axis of the device.
        self.orientation = try dataStream.read(endianess: .littleEndian)
        
        /// Weight (2 bytes): A 16-bit signed integer that defines the weight of the font in the range 0 through 1000. For example, 400 is normal
        /// and 700 is bold. If this value is 0x0000, a default weight SHOULD be used.
        self.weight = try dataStream.read(endianess: .littleEndian)
        
        /// Italic (1 byte): A 8-bit Boolean value that specifies the italic attribute of the font.
        /// Value Meaning
        /// FALSE 0x00 This is not an italic font.
        /// TRUE 0x01 This is an italic font.
        self.italic = (try dataStream.read() as UInt8) != 0x00
        
        /// Underline (1 byte): An 8-bit Boolean value that specifies the underline attribute of the font.
        /// Value Meaning
        /// FALSE 0x00 This is not an underline font.
        /// TRUE 0x01 This is an underline font.
        self.underline = (try dataStream.read() as UInt8) != 0x00
        
        /// StrikeOut (1 byte): An 8-bit Boolean value that specifies the strikeout attribute of the font.
        /// Value Meaning
        /// FALSE 0x00 This is not a strikeout font.
        /// TRUE 0x01 This is a strikeout font.
        self.strikeOut = (try dataStream.read() as UInt8) != 0x00
        
        /// CharSet (1 byte): An 8-bit unsigned integer that defines the character set. It SHOULD be set to a value in the CharacterSet
        /// Enumeration (section 2.1.1.5).
        /// The DEFAULT_CHARSET value MAY be used to allow the name and size of a font to fully describe the logical font. If the specified
        /// font name does not exist, a font in another character set MAY be substituted. The DEFAULT_CHARSET value is set to a value
        /// based on the current system locale.
        /// For example, when the system locale is United States, it is set to ANSI_CHARSET.
        /// If a typeface name in the FaceName field is specified, the CharSet value MUST match the character set of that typeface.
        self.charSet = try dataStream.read()
        
        /// OutPrecision (1 byte): An 8-bit unsigned integer that defines the output precision. The output precision defines how closely the
        /// output matches the requested font height, width, character orientation, escapement, pitch, and font type. It MUST be one of the
        /// values from the OutPrecision Enumeration (section 2.1.1.21).
        /// Applications can use the OUT_DEVICE_PRECIS, OUT_RASTER_PRECIS, OUT_TT_PRECIS, and OUT_PS_ONLY_PRECIS values
        /// to control how the font mapper selects a font when the operating system contains more than one font with a specified name. For
        /// example, if an operating system contains a font named "Symbol" in raster and TrueType forms, specifying OUT_TT_PRECIS forces
        /// the font mapper to select the TrueType version. Specifying OUT_TT_ONLY_PRECIS forces the font mapper to select a TrueType font,
        /// even if it substitutes a TrueType font of another name.
        self.outPrecision = try OutPrecision(dataStream: &dataStream)
        
        /// ClipPrecision (1 byte): An 8-bit unsigned integer that defines the clipping precision. The clipping precision defines how to clip
        /// characters that are partially outside the clipping region. It MUST be a combination of one or more of the bit settings in the
        /// ClipPrecision Flags (section 2.1.2.1).
        self.clipPrecision = try ClipPrecision(dataStream: &dataStream)
        
        /// Quality (1 byte): An 8-bit unsigned integer that defines the output quality. The output quality defines how carefully to attempt to match
        /// the logical font attributes to those of an actual physical font. It MUST be one of the values in the FontQuality Enumeration
        /// (section 2.1.1.10).
        self.quality = try FontQuality(dataStream: &dataStream)
        
        /// PitchAndFamily (1 byte): A PitchAndFamily Object (section 2.2.2.14) that defines the pitch and the family of the font. Font families
        /// specify the look of fonts in a general way and are intended for specifying fonts when the exact typeface wanted is not available.
        self.pitchAndFamily = try PitchAndFamily(dataStream: &dataStream)
        
        /// Facename (32 bytes): A null-terminated string of up to 32 8-bit Latin-1 [ISO/IEC-8859-1] ANSI characters that specifies the typeface
        /// name of the font. Any characters following the terminating null are ignored.
        let remainingCount = min(32, recordSize - UInt32(dataStream.position - startPosition) / 2)
        
        guard let s = try dataStream.readString(count: Int(remainingCount) * 2, encoding: .isoLatin1) else {
            throw WmfReadError.corrupted
        }

        if let index = s.firstIndex(of: "\0") {
            self.facename = String(s.prefix(upTo: index))
        } else {
            self.facename = s
        }
    }
}
