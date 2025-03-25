import Foundation

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("connectivity_state_plus_connectivity_state_plus.bundle").path
        let buildPath = "/Users/yuyl_field/Code/clobotics/rea-flutter/modules/connectivity_state_plus/ios/connectivity_state_plus/.build/arm64-apple-macosx/debug/connectivity_state_plus_connectivity_state_plus.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            // Users can write a function called fatalError themselves, we should be resilient against that.
            Swift.fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}