enum ConnectivityState {
  /// WiFi: Device connected via Wi-Fi
  wifi,

  /// Mobile: Device connected to cellular network
  mobile,

  /// None: Device not connected to any network
  none,

  /// Restricted: A probe to the configured address failed on Wi-Fi/cellular.
  /// This does not establish that the Internet or other requests are unavailable.
  restricted,

  /// VPN: Device connected to a VPN, Only Supported on iOS and macOS
  vpn,

  /// Unknown: not sure if Device is connected to a VPN
  unknown
}
