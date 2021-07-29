# AINetworkCalls

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url] 
![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)

A Network calls helper library that depends on Alamofire and SwiftyJSON to provide an easy to use way to call your APIs

## Requirements

- iOS 12.0+
- Xcode 10.0+

## Installation

#### Swift Package Manager

You can use SPM to install `AINetworkCalls` by adding it to your `Package.swift`:

```
.package(url: "https://github.com/AlexyIbrahim/AINetworkCalls.git", from: "1.2.1")
```

## Usage example

Add this anywhere in your application

```
extension AIEndpoint {
    public static let endpointName = AIEndpoint(rawValue: "https://endpointValue/")
}
```

Code:

```swift
AINetworkCalls.get(endpoint: .endpointName, function: "get", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true, successCallback: { (response: JSON) in
	print("json response: \(String(describing: response))")
}) { (json, error) in
	print("error json: \(String(describing: json))")
}
```

## Meta

Alexy Ibrahim – [@Github](https://github.com/alexyibrahim) – alexy.ib@gmail.com

See ``LICENSE`` for more information.

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.md

# 
