enum ConnectivityState {
  /// WiFi: Device connected via Wi-Fi
  wifi,

  /// Mobile: Device connected to cellular network
  mobile,

  /// None: Device not connected to any network
  none,

  /// Restricted: Device connected to Wi-Fi/cellular, not accessible to address checked
  restricted,

  /// VPN: Device connected to a VPN, Only Supported on iOS and macOS
  vpn,

  /// Unknown: not sure if Device is connected to a VPN
  unknown
}
