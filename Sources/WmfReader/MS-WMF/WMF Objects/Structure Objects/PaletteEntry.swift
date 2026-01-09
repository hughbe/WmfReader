//
//  PaletteEntry.swift
//  
//
//  Created by Hugh Bellamy on 02/12/2020.
//

import DataStream

/// [MS-WMF] 2.2.2.13 PaletteEntry Object
/// The PaletteEntry Object defines the color and usage of an entry in a palette
public struct PaletteEntry {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public let values: PaletteEntryFlag
    
    public init(dataStream: inout DataStream) throws {
        /// Red (1 byte): An 8-bit unsigned integer that defines the red intensity value for the palette entry
        self.red = try dataStream.read()
        
        /// Green (1 byte): An 8-bit unsigned integer that defines the green intensity value for the palette entry.
        self.green = try dataStream.read()
        
        /// Blue (1 byte): An 8-bit unsigned integer that defines the blue intensity value for the palette entry.
        self.blue = try dataStream.read()

        /// Values (1 byte): An 8-bit unsigned integer that defines how the palette entry is to be used. The Values field MUST be
        /// 0x00 or one of the values in the PaletteEntryFlag Enumeration (section 2.1.1.22) table.
        self.values = try PaletteEntryFlag(dataStream: &dataStream)
    }
}
