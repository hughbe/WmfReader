//
//  MetafileEscapes.swift
//  
//
//  Created by Hugh Bellamy on 30/11/2020.
//

/// [MS-WMF] 2.1.1.17 MetafileEscapes Enumeration
/// The MetafileEscapes Enumeration specifies printer driver functionality that might not be directly accessible through WMF records defined
/// in the RecordType Enumeration (section 2.1.1.1).
/// These values are used by Escape Record Types (section 2.3.6).
/// typedef enum
/// {
///  NEWFRAME = 0x0001,
///  ABORTDOC = 0x0002,
///  NEXTBAND = 0x0003,
///  SETCOLORTABLE = 0x0004,
///  GETCOLORTABLE = 0x0005,
///  FLUSHOUT = 0x0006,
///  DRAFTMODE = 0x0007,
///  QUERYESCSUPPORT = 0x0008,
///  SETABORTPROC = 0x0009,
///  STARTDOC = 0x000A,
///  ENDDOC = 0x000B,
///  GETPHYSPAGESIZE = 0x000C,
///  GETPRINTINGOFFSET = 0x000D,
///  GETSCALINGFACTOR = 0x000E,
///  META_ESCAPE_ENHANCED_METAFILE = 0x000F,
///  SETPENWIDTH = 0x0010,
///  SETCOPYCOUNT = 0x0011,
///  SETPAPERSOURCE = 0x0012,
///  PASSTHROUGH = 0x0013,
///  GETTECHNOLOGY = 0x0014,
///  SETLINECAP = 0x0015,
///  SETLINEJOIN = 0x0016,
///  SETMITERLIMIT = 0x0017,
///  BANDINFO = 0x0018,
///  DRAWPATTERNRECT = 0x0019,
///  GETVECTORPENSIZE = 0x001A,
///  GETVECTORBRUSHSIZE = 0x001B,
///  ENABLEDUPLEX = 0x001C,
///  GETSETPAPERBINS = 0x001D,
///  GETSETPRINTORIENT = 0x001E,
///  ENUMPAPERBINS = 0x001F,
///  SETDIBSCALING = 0x0020,
///  EPSPRINTING = 0x0021,
///  ENUMPAPERMETRICS = 0x0022,
///  GETSETPAPERMETRICS = 0x0023,
///  POSTSCRIPT_DATA = 0x0025,
///  POSTSCRIPT_IGNORE = 0x0026,
///  GETDEVICEUNITS = 0x002A,
///  GETEXTENDEDTEXTMETRICS = 0x0100,
///  GETPAIRKERNTABLE = 0x0102,
///  EXTTEXTOUT = 0x0200,
///  GETFACENAME = 0x0201,
///  DOWNLOADFACE = 0x0202,
///  METAFILE_DRIVER = 0x0801,
///  QUERYDIBSUPPORT = 0x0C01,
///  BEGIN_PATH = 0x1000,
///  CLIP_TO_PATH = 0x1001,
///  END_PATH = 0x1002,
///  OPENCHANNEL = 0x100E,
///  DOWNLOADHEADER = 0x100F,
///  CLOSECHANNEL = 0x1010,
///  POSTSCRIPT_PASSTHROUGH = 0x1013,
///  ENCAPSULATED_POSTSCRIPT = 0x1014,
///  POSTSCRIPT_IDENTIFY = 0x1015,
///  POSTSCRIPT_INJECTION = 0x1016,
///  CHECKJPEGFORMAT = 0x1017,
///  CHECKPNGFORMAT = 0x1018,
///  GET_PS_FEATURESETTING = 0x1019,
///  MXDC_ESCAPE = 0x101A,
///  SPCLPASSTHROUGH2 = 0x11D8
/// } MetafileEscapes;
public enum MetafileEscapes: UInt16, DataStreamCreatable {
    /// NEWFRAME: Notifies the printer driver that the application has finished writing to a page.
    case NEWFRAME = 0x0001
    
    /// ABORTDOC: Stops processing the current document.
    case ABORTDOC = 0x0002
    
    /// NEXTBAND: Notifies the printer driver that the application has finished writing to a band.
    case NEXTBAND = 0x0003
    
    /// SETCOLORTABLE: Sets color table values.
    case SETCOLORTABLE = 0x0004
    
    /// GETCOLORTABLE: Gets color table values.
    case GETCOLORTABLE = 0x0005
    
    /// FLUSHOUT: Causes all pending output to be flushed to the output device.
    case FLUSHOUT = 0x0006
    
    /// DRAFTMODE: Indicates that the printer driver SHOULD print text only, and no graphics.
    case DRAFTMODE = 0x0007

    /// QUERYESCSUPPORT: Queries a printer driver to determine whether a specific escape function is supported on the output device it drives.
    case QUERYESCSUPPORT = 0x0008

    /// SETABORTPROC: Sets the application-defined function that allows a print job to be canceled during printing.
    case SETABORTPROC = 0x0009

    /// STARTDOC: Notifies the printer driver that a new print job is starting.
    case STARTDOC = 0x000A

    /// ENDDOC: Notifies the printer driver that the current print job is ending.
    case ENDDOC = 0x000B

    /// GETPHYSPAGESIZE: Retrieves the physical page size currently selected on an output device.
    case GETPHYSPAGESIZE = 0x000C

    /// GETPRINTINGOFFSET: Retrieves the offset from the upper-left corner of the physical page where the actual printing or drawing begins.
    case GETPRINTINGOFFSET = 0x000D

    /// GETSCALINGFACTOR: Retrieves the scaling factors for the x-axis and the y-axis of a printer.
    case GETSCALINGFACTOR = 0x000E

    /// META_ESCAPE_ENHANCED_METAFILE: Used to embed an enhanced metafile format (EMF) metafile within a WMF metafile.
    case META_ESCAPE_ENHANCED_METAFILE = 0x000F

    /// SETPENWIDTH: Sets the width of a pen in pixels.
    case SETPENWIDTH = 0x0010

    /// SETCOPYCOUNT: Sets the number of copies.
    case SETCOPYCOUNT = 0x0011

    /// SETPAPERSOURCE: Sets the source, such as a particular paper tray or bin on a printer, for output forms.
    case SETPAPERSOURCE = 0x0012

    /// PASSTHROUGH: This record passes through arbitrary data.
    case PASSTHROUGH = 0x0013

    /// GETTECHNOLOGY: Gets information concerning graphics technology that is supported on a device.
    case GETTECHNOLOGY = 0x0014

    /// SETLINECAP: Specifies the line-drawing mode to use in output to a device.
    case SETLINECAP = 0x0015

    /// SETLINEJOIN: Specifies the line-joining mode to use in output to a device.
    case SETLINEJOIN = 0x0016

    /// SETMITERLIMIT: Sets the limit for the length of miter joins to use in output to a device.
    case SETMITERLIMIT = 0x0017

    /// BANDINFO: Retrieves or specifies settings concerning banding on a device, such as the number of bands.
    case BANDINFO = 0x0018

    /// DRAWPATTERNRECT: Draws a rectangle with a defined pattern.
    case DRAWPATTERNRECT = 0x0019

    /// GETVECTORPENSIZE: Retrieves the physical pen size currently defined on a device.
    case GETVECTORPENSIZE = 0x001A

    /// GETVECTORBRUSHSIZE: Retrieves the physical brush size currently defined on a device.
    case GETVECTORBRUSHSIZE = 0x001B

    /// ENABLEDUPLEX: Enables or disables double-sided (duplex) printing on a device.
    case ENABLEDUPLEX = 0x001C

    /// GETSETPAPERBINS: Retrieves or specifies the source of output forms on a device.
    case GETSETPAPERBINS = 0x001D

    /// GETSETPRINTORIENT: Retrieves or specifies the paper orientation on a device.
    case GETSETPRINTORIENT = 0x001E

    /// ENUMPAPERBINS: Retrieves information concerning the sources of different forms on an output device.
    case ENUMPAPERBINS = 0x001F

    /// SETDIBSCALING: Specifies the scaling of device-independent bitmaps (DIBs).
    case SETDIBSCALING = 0x0020

    /// EPSPRINTING: Indicates the start and end of an encapsulated PostScript (EPS) section.
    case EPSPRINTING = 0x0021

    /// ENUMPAPERMETRICS: Queries a printer driver for paper dimensions and other forms data.
    case ENUMPAPERMETRICS = 0x0022

    /// GETSETPAPERMETRICS: Retrieves or specifies paper dimensions and other forms data on an output device.
    case GETSETPAPERMETRICS = 0x0023

    /// POSTSCRIPT_DATA: Sends arbitrary PostScript data to an output device.
    case POSTSCRIPT_DATA = 0x0025

    /// POSTSCRIPT_IGNORE: Notifies an output device to ignore PostScript data.
    case POSTSCRIPT_IGNORE = 0x0026

    /// GETDEVICEUNITS: Gets the device units currently configured on an output device.
    case GETDEVICEUNITS = 0x002A

    /// GETEXTENDEDTEXTMETRICS: Gets extended text metrics currently configured on an output device.
    case GETEXTENDEDTEXTMETRICS = 0x0100

    /// GETPAIRKERNTABLE: Gets the font kern table currently defined on an output device.
    case GETPAIRKERNTABLE = 0x0102

    /// EXTTEXTOUT: Draws text using the currently selected font, background color, and text color.
    case EXTTEXTOUT = 0x0200

    /// GETFACENAME: Gets the font face name currently configured on a device.
    case GETFACENAME = 0x0201

    /// DOWNLOADFACE: Sets the font face name on a device.
    case DOWNLOADFACE = 0x0202

    /// METAFILE_DRIVER: Queries a printer driver about the support for metafiles on an output device.
    case METAFILE_DRIVER = 0x0801

    /// QUERYDIBSUPPORT: Queries the printer driver about its support for DIBs on an output device.
    case QUERYDIBSUPPORT = 0x0C01

    /// BEGIN_PATH: Opens a path.
    case BEGIN_PATH = 0x1000

    /// CLIP_TO_PATH: Defines a clip region that is bounded by a path. The input MUST be a 16-bit quantity that defines the action to take.
    case CLIP_TO_PATH = 0x1001

    /// END_PATH: Ends a path.
    case END_PATH = 0x1002

    /// OPENCHANNEL: The same as STARTDOC specified with a NULL document and output filename, data in raw mode, and a type of zero.
    case OPENCHANNEL = 0x100E

    /// DOWNLOADHEADER: Instructs the printer driver to download sets of PostScript procedures.
    case DOWNLOADHEADER = 0x100F

    /// CLOSECHANNEL: The same as ENDDOC. See OPENCHANNEL.
    case CLOSECHANNEL = 0x1010

    /// POSTSCRIPT_PASSTHROUGH: Sends arbitrary data directly to a printer driver, which is expected to process this data only when in PostScript mode. See POSTSCRIPT_IDENTIFY.<14>
    case POSTSCRIPT_PASSTHROUGH = 0x1013

    /// ENCAPSULATED_POSTSCRIPT: Sends arbitrary data directly to the printer driver.
    case ENCAPSULATED_POSTSCRIPT = 0x1014

    /// POSTSCRIPT_IDENTIFY: Sets the printer driver to either PostScript or GDI mode.<15>
    case POSTSCRIPT_IDENTIFY = 0x1015

    /// POSTSCRIPT_INJECTION: Inserts a block of raw data into a PostScript stream. The input MUST be a 32-bit quantity specifying the number of bytes to inject, a 16-bit quantity specifying the injection point, and a 16-bit quantity specifying the page number, followed by the bytes to inject.<16>
    case POSTSCRIPT_INJECTION = 0x1016

    /// CHECKJPEGFORMAT: Checks whether the printer supports a JPEG image.<17>
    case CHECKJPEGFORMAT = 0x1017

    /// CHECKPNGFORMAT: Checks whether the printer supports a PNG image.<18>
    case CHECKPNGFORMAT = 0x1018

    /// GET_PS_FEATURESETTING: Gets information on a specified feature setting for a PostScript printer driver.<19>
    case GET_PS_FEATURESETTING = 0x1019

    /// MXDC_ESCAPE: Enables applications to write documents to a file or to a printer in XML Paper Specification (XPS) format.<20>
    case MXDC_ESCAPE = 0x101A

    /// SPCLPASSTHROUGH2: Enables applications to include private procedures and other arbitrary data in documents.<21>
    case SPCLPASSTHROUGH2 = 0x11D8
}
