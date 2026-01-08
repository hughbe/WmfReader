# WmfReader

Swift definitions for structures, enumerations and functions defined in [MS-WMF](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-wmf/).

## Example Usage

Add the following line to your project's SwiftPM dependencies:
```swift
.package(url: "https://github.com/hughbe/WmfReader", from: "1.0.0"),
```

```swift
import WmfReader

let data = Data(contentsOfFile: "<path-to-file>.wmf")!
let file = try WmfFile(data: data)
try file.enumerateRecords { record in
    print("Record: \(record)")
    return .continue
}
```


