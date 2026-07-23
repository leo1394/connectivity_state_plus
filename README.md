# connectivity_state_plus

[![pub package](https://img.shields.io/pub/v/connectivity_state_plus.svg)](https://pub.dev/packages/connectivity_state_plus)
[![pub points](https://img.shields.io/pub/points/connectivity_state_plus?color=2E8B57&label=pub%20points)](https://pub.dev/packages/connectivity_state_plus/score)
[![GitHub Issues](https://img.shields.io/github/issues/leo1394/connectivity_state_plus.svg?branch=master)](https://github.com/leo1394/connectivity_state_plus/issues)
[![GitHub Forks](https://img.shields.io/github/forks/leo1394/connectivity_state_plus.svg?branch=master)](https://github.com/leo1394/connectivity_state_plus/network)
[![GitHub Stars](https://img.shields.io/github/stars/leo1394/connectivity_state_plus.svg?branch=master)](https://github.com/leo1394/connectivity_state_plus/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT%20-blue.svg)](https://raw.githubusercontent.com/leo1394/connectivity_state_plus/master/LICENSE)

`connectivity_state_plus` monitors WiFi, cellular, and restricted network states across Flutter platforms. In addition to detecting the active network interface, it can verify real TCP reachability to a configured host and port, avoiding false positives when a device is connected to WiFi or cellular but the required service cannot be reached.


## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |

## Requirements

- Flutter >=3.19.0
- Dart >=3.3.0 <4.0.0
- iOS >=12.0
- MacOS >=10.14
- Android `compileSDK` 34
- Java 17
- Android Gradle Plugin >=8.3.0
- Gradle wrapper >=8.4

## Getting started
published on pub.dev, run this Flutter command
```shell
flutter pub add connectivity_state_plus
```

## Real TCP Reachability

Configure the singleton `Connectivity` instance with the address your application needs to reach. The plugin parses the host and port, then attempts a real TCP connection. When WiFi or cellular is available but the configured service cannot be reached, it returns `ConnectivityState.restricted`.

Explicit ports are supported:

```dart
Connectivity().setAddressCheckOption('http://192.168.54.37:8080');
```

When no port is specified, HTTP uses port 80 and HTTPS uses port 443:

```dart
Connectivity().setAddressCheckOption('https://pub.dev');
```

Probe results are cached for 5 seconds, and concurrent checks share the same in-progress probe. This reduces socket creation when a host application calls `checkConnectivity()` frequently. Changing the configured address invalidates the cache immediately.

To perform a one-time reachability check without changing the address configured by `setAddressCheckOption`, pass the address directly:

```dart
final bool isReachable = await Connectivity()
    .checkAddressConnectivity('http://10.192.13.98:8087');
```

One-time checks are not cached.

> This is a TCP reachability check, not an HTTP health check. A successful TCP handshake is considered reachable regardless of the HTTP response status. Use an application-level HTTP request when response content or status codes must also be validated.

## Usage

Sample usage to listen for active connectivity state changes by subscribing to the stream.
```dart
import 'package:connectivity_state_plus/connectivity_state_plus.dart';

@override
initState() {
  super.initState();

  StreamSubscription<ConnectivityState> subscription = Connectivity().onConnectivityChanged.listen((ConnectivityState result) {
    // Received changes in available connectivity state!
  });
}

// Be sure to cancel subscription
@override
dispose() {
  subscription.cancel();
  super.dispose();
}
```
Sample usage to check currently available connection state:

```dart
import 'package:connectivity_state_plus/connectivity_state_plus.dart';

final ConnectivityState connectivityState = await (Connectivity().checkConnectivity());
```

Sample usage for detecting whether the current network connection uses a VPN:
[Note]: Only worked on iOS and macOS, otherwise would return `ConnectivityState.other` or `ConnectivityState.unknown` 
```dart
import 'package:connectivity_state_plus/connectivity_state_plus.dart';

final ConnectivityState connectivityState = await (Connectivity().checkVPNConnectivity());
```


## Platform Support

The following table shows which `ConnectivityState` values are supported per platform.

|            | Android | iOS | Web | MacOS | Windows | Linux |
|------------|:-------:|:---:|:---:|:-----:|:-------:|:-----:|
| restricted | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| wifi       | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| mobile     | :white_check_mark: | :white_check_mark: |                    | :white_check_mark: |                    |                    |
| vpn        | :white_check_mark: |                    |                    |                    | :white_check_mark: | :white_check_mark: |
| other      | :white_check_mark: | :white_check_mark: |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |

_`none` and `unknown` are supported on all platforms by default._

### Android

Connectivity changes are no longer communicated to Android apps in the background starting with Android O (8.0). You should always check for connectivity status when your app is resumed. The broadcast is only useful when your application is in the foreground.

### iOS & MacOS

On iOS simulators, the connectivity types stream might not update when Wi-Fi status changes. This is a known issue.

Starting with iOS 12 and MacOS 10.14, the implementation uses `NWPathMonitor` to obtain the enabled connectivity types. We noticed that this observer can give multiple or unreliable results. For example, reporting connectivity "none" followed by connectivity "wifi" right after reconnecting.

We recommend to use the `onConnectivityChanged` with this limitation in mind, as the method doesn't filter events, nor it ensures distinct values.

### Web

In order to retrieve information about the quality/speed of a browser's connection, the web implementation of the `connectivity` plugin uses the browser's [**NetworkInformation** Web API](https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation), which as of this writing (June 2020) is still "experimental", and not available in all browsers:

![Data on support for the netinfo feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/netinfo.png)

On desktop browsers, this API only returns a very broad set of connectivity statuses (One of `'slow-2g', '2g', '3g', or '4g'`), and may _not_ provide a Stream of changes. Firefox still hasn't enabled this feature by default.


## Learn more

- [API Documentation](https://pub.dev/documentation/connectivity_state_plus/latest/connectivity_state_plus/connectivity_state_plus-library.html)
