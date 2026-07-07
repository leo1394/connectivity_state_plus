---
name: connectivity_state_plus
description: Use when coding with connectivity_state_plus: checking and streaming ConnectivityState, reachability via setAddressCheckOption, restricted network handling, VPN checks, and platform caveats.
---

# connectivity_state_plus Agent Context

Use this Flutter plugin to detect connectivity state across platforms. It reports `ConnectivityState` values such as `wifi`, `mobile`, `restricted`, `vpn`, `none`, `other`, and `unknown`.

## Import

```dart
import 'package:connectivity_state_plus/connectivity_state_plus.dart';
```

## Reachability Configuration

Set an address to actively verify internet reachability. If the device has Wi-Fi/mobile but cannot reach the endpoint, the state becomes `ConnectivityState.restricted`.

```dart
Connectivity().setAddressCheckOption("https://pub.dev");
```

## Listen for Changes

```dart
late final StreamSubscription<ConnectivityState> subscription;

@override
void initState() {
  super.initState();
  subscription = Connectivity().onConnectivityChanged.listen((state) {
    if (state == ConnectivityState.none) {
      // offline UI
    }
  });
}

@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

## Current State and VPN

```dart
final state = await Connectivity().checkConnectivity();

final vpnState = await Connectivity().checkVPNConnectivity();
// VPN check is meaningful on supported desktop/mobile platforms; otherwise
// expect other/unknown/none behavior depending on platform.
```

## Notes for Agents

- `Connectivity()` is a singleton factory; do not keep creating competing platform listeners.
- Always cancel stream subscriptions.
- Android background connectivity broadcasts are limited; check state when app resumes.
- iOS/macOS path monitor may emit multiple or noisy transitions.
- `checkConnectivity` is a connectivity signal, not a guarantee every API call will succeed; use `setAddressCheckOption` for stronger reachability detection.
