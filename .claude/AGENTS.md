# connectivity_state_plus

Use `Connectivity().onConnectivityChanged` to listen for `ConnectivityState`, and cancel the subscription. Use `Connectivity().checkConnectivity()` for current state. Call `setAddressCheckOption("https://...")` to convert captive-portal/DNS failures into `ConnectivityState.restricted`.
