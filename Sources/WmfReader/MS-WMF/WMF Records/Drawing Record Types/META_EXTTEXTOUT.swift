//
//  META_EXTTEXTOUT.swift
//
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream
import Foundation

/// [MS-WMF] 2.3.3.5 META_EXTTEXTOUT Record
/// The META_EXTTEXTOUT Record outputs text by using the font, background color, and text color that are defined in the playback device
/// context. Optionally, dimensions can be provided for clipping, opaquing, or both.
public struct META_EXTTEXTOUT {
    public let recordSize: UInt32
    public let recordFunction: UInt16
    public let y: Int16
    public let x: Int16
    public let stringLength: Int16
    public let fwOpts: ExtTextOutOptions
    public let rectangle: Rect?
    public let string: String
    public let dx: [Int16]?
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// RecordSize (4 bytes): A 32-bit unsigned integer that defines the number of 16-bit WORD structures, defined in [MS-DTYP]
        /// section 2.2.61, in the record.
        self.recordSize = try dataStream.read(endianess: .littleEndian)
        guard self.recordSize >= 7 else {
            throw WmfReadError.corrupted
        }
        
        /// RecordFunction (2 bytes): A 16-bit unsigned integer that defines this WMF record type. The lower byte MUST match the lower byte
        /// of the RecordType Enumeration (section 2.1.1.1) table value META_EXTTEXTOUT.
        self.recordFunction = try dataStream.read(endianess: .littleEndian)
        guard self.recordFunction & 0xFF == RecordType.META_EXTTEXTOUT.rawValue & 0xFF else {
            throw WmfReadError.corrupted
        }
        
        /// Y (2 bytes): A 16-bit signed integer that defines the y-coordinate, in logical units, where the text string is to be located.
        self.y = try dataStream.read(endianess: .littleEndian)
        
        /// X (2 bytes): A 16-bit signed integer that defines the x-coordinate, in logical units, where the text string is to be located.
        self.x = try dataStream.read(endianess: .littleEndian)
        
        /// StringLength (2 bytes): A 16-bit signed integer that defines the length of the string.
        self.stringLength = try dataStream.read(endianess: .littleEndian)
        let minExpectedSize = 7 + Int(ceil(Double(stringLength) / 2))
        guard self.recordSize >= minExpectedSize else {
            throw WmfReadError.corrupted
        }
        
        /// fwOpts (2 bytes): A 16-bit unsigned integer that defines the use of the application-defined rectangle. This member can be a
        /// combination of one or more values in the ExtTextOutOptions Flags (section 2.1.2.2).
        let fwOpts = try ExtTextOutOptions(dataStream: &dataStream)
        self.fwOpts = fwOpts
        
        let shouldHaveRectangle = fwOpts.contains(.clipped) || fwOpts.contains(.opaque)
        let expectedSize = minExpectedSize + (shouldHaveRectangle ? 4 : 0)
        guard self.recordSize >= expectedSize else {
            throw WmfReadError.corrupted
        }

        /// Rectangle (8 bytes): An optional 8-byte Rect Object (section 2.2.2.18) that defines the dimensions, in logical coordinates, of a
        /// rectangle that is used for clipping, opaquing, or both.
        if shouldHaveRectangle {
            self.rectangle = try Rect(dataStream: &dataStream)
        } else {
            self.rectangle = nil
        }
        
        /// String (variable): A variable-length string that specifies the text to be drawn. The string does not need to be null-terminated,
        /// because StringLength specifies the length of the string. If the length is odd, an extra byte is placed after it so that the following
        /// member (optional Dx) is aligned on a 16-bit boundary.
        self.string = try dataStream.readString(count: Int(stringLength), encoding: .ascii) ?? ""
        
        if self.stringLength % 2 != 0 {
            let _: UInt8 = try dataStream.read()
        }
        
        if self.recordSize == expectedSize {
            self.dx = nil
            return
        } else if self.recordSize < expectedSize + Int(stringLength) {
            // No space for dx. Skip these bytes.
            // Skip this so that we don't crash.
            while (dataStream.position - startPosition) / 2  < self.recordSize {
                let _: UInt16 = try dataStream.read(endianess: .littleEndian)
            }

            self.dx = nil
            return
        }
        
        /// Dx (variable): An optional array of 16-bit signed integers that indicate the distance between origins of adjacent character cells.
        /// For example, Dx[i] logical units separate the origins of character cell i and character cell i + 1. If this field is present, there
        /// MUST be the same number of values as there are characters in the string.
        var dx: [Int16] = []
        dx.reserveCapacity(Int(self.stringLength))
        for _ in 0..<self.stringLength {
            dx.append(try dataStream.read(endianess: .littleEndian))
        }
        
        self.dx = dx
        
        // Seen some cases where there is zero padding of a few more bytes...
        // Skip this so that we don't crash.
        while (dataStream.position - startPosition) / 2  < self.recordSize {
            let _: UInt16 = try dataStream.read(endianess: .littleEndian)
        }
        
        guard (dataStream.position - startPosition) / 2 == self.recordSize else {
             throw WmfReadError.corrupted
        }
    }
}
