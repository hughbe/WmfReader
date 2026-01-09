//
//  PenStyle.swift
//  
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream

/// [MS-WMF] 2.1.1.23 PenStyle Enumeration
/// The 16-bit PenStyle Enumeration is used to specify different types of pens that can be used in graphics operations.
/// Various styles can be combined by using a logical OR statement, one from each subsection of Style, EndCap, Join, and Type (Cosmetic).
/// typedef enum
/// {
///  PS_COSMETIC = 0x0000,
///  PS_ENDCAP_ROUND = 0x0000,
///  PS_JOIN_ROUND = 0x0000,
///  PS_SOLID = 0x0000,
///  PS_DASH = 0x0001,
///  PS_DOT = 0x0002,
///  PS_DASHDOT = 0x0003,
///  PS_DASHDOTDOT = 0x0004,
///  PS_NULL = 0x0005,
///  PS_INSIDEFRAME = 0x0006,
///  PS_USERSTYLE = 0x0007,
///  PS_ALTERNATE = 0x0008,
///  PS_ENDCAP_SQUARE = 0x0100,
///  PS_ENDCAP_FLAT = 0x0200,
///  PS_JOIN_BEVEL = 0x1000,
///  PS_JOIN_MITER = 0x2000
/// } PenStyle;
public struct PenStyle {
    public let style: Style
    public let endCap: EndCap
    public let join: Join
    public let type: PenType
    
    public init(dataStream: inout DataStream) throws {
        try self.init(rawValue: try dataStream.read(endianess: .littleEndian))
    }
    
    public init(rawValue: UInt16) throws {
        guard let style = Style(rawValue: rawValue & 0x000F) else {
            throw WmfReadError.corrupted
        }
        
        self.style = style
        
        guard let endCap = EndCap(rawValue: rawValue & 0x0F00) else {
            throw WmfReadError.corrupted
        }
        
        self.endCap = endCap
        
        guard let join = Join(rawValue: rawValue & 0xF000) else {
            throw WmfReadError.corrupted
        }
        
        self.join = join
        
        self.type = .cosmetic
    }
    
    public enum Style: UInt16 {
        /// PS_SOLID: The pen is solid.
        case solid = 0x0000
        
        /// PS_DASH: The pen is dashed.
        case dash = 0x0001
        
        /// PS_DOT: The pen is dotted.
        case dot = 0x0002
        
        /// PS_DASHDOT: The pen has alternating dashes and dots.
        case dashDot = 0x0003
        
        /// PS_DASHDOTDOT: The pen has dashes and double dots.
        case dashDotDot = 0x0004
        
        /// PS_NULL: The pen is invisible.
        case null = 0x0005
        
        /// PS_INSIDEFRAME: The pen is solid. When this pen is used in any drawing record that takes a bounding rectangle, the dimensions of
        /// the figure are shrunk so that it fits entirely in the bounding rectangle, taking into account the width of the pen.
        case insideFrame =  0x0006
        
        /// PS_USERSTYLE: The pen uses a styling array supplied by the user.
        case userStyle = 0x0007

        /// PS_ALTERNATE: The pen sets every other pixel (this style is applicable only for cosmetic pens).
        case alternate = 0x0008
    }
    
    public enum EndCap: UInt16 {
        /// PS_ENDCAP_ROUND: Line end caps are round.
        case round = 0x00000

        /// PS_ENDCAP_SQUARE: Line end caps are square.
        case square = 0x0100
        
        /// PS_ENDCAP_FLAT: Line end caps are flat.
        case flat = 0x0200
    }
    
    public enum Join: UInt16 {
        /// PS_JOIN_ROUND: Line joins are round.
        case round = 0x0000
        
        /// PS_JOIN_BEVEL: Line joins are beveled.
        case bevel = 0x1000
        
        /// PS_JOIN_MITER: Line joins are mitered when they are within the current limit set by the SETMITERLIMIT Record (section 2.3.6.42).
        /// A join is beveled when it would exceed the limit.
        case miter = 0x2000
    }

    public enum PenType: UInt16 {
        /// PS_COSMETIC: The pen is cosmetic.
        case cosmetic = 0x0000
    }
}
