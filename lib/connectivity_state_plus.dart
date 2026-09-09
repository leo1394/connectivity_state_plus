// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:collection/collection.dart';
import 'package:connectivity_state_plus/src/connectivity_state.dart';

// Export enums from the platform_interface so plugin users can use them directly.
export 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart'
    show ConnectivityResult;
export 'package:connectivity_state_plus/src/connectivity_state.dart';
export 'src/connectivity_plus_linux.dart'
    if (dart.library.js_interop) 'src/connectivity_plus_web.dart';

/// Discover network connectivity configurations: Distinguish between WI-FI and cellular, check WI-FI status and more.
class Connectivity {
  static String _address = "";
  static const Duration _addressCheckCacheDuration = Duration(seconds: 5);

  bool? _cachedAddressCheckResult;
  DateTime? _cachedAddressCheckTime;
  Future<bool>? _ongoingAddressCheck;
  int _addressCheckGeneration = 0;

  /// Constructs a singleton instance of [Connectivity].
  ///
  /// [Connectivity] is designed to work as a singleton.
  // When a second instance is created, the first instance will not be able to listen to the
  // EventChannel because it is overridden. Forcing the class to be a singleton class can prevent
  // misuse of creating a second instance from a programmer.
  factory Connectivity() {
    _singleton ??= Connectivity._();
    return _singleton!;
  }

  Connectivity._();

  static Connectivity? _singleton;
  factory Connectivity.getInstance() => Connectivity();

  static ConnectivityPlatform get _platform {
    return ConnectivityPlatform.instance;
  }

  /// Exposes connectivity update events from the platform.
  ///
  /// On iOS, the connectivity status might not update when WiFi
  /// status changes, this is a known issue that only affects simulators.
  /// For details see https://github.com/fluttercommunity/plus_plugins/issues/479.
  ///
  /// The emitted list is never empty. In case of no connectivity, the list contains
  /// a single element of [ConnectivityResult.none]. Note also that this is the only
  /// case where [ConnectivityResult.none] is present.
  ///
  /// This method applies [Stream.distinct] over the received events to ensure
  /// only emitting when connectivity changes.
  Stream<ConnectivityState> get onConnectivityChanged {
    return _platform.onConnectivityChanged
        .distinct((a, b) => a.equals(b))
        .transform(
          StreamTransformer<List<ConnectivityResult>,
              ConnectivityState>.fromHandlers(
            handleData: (data, sink) async =>
                sink.add(await _connectivityConvert(data)),
          ),
        );
  }

  /// Reports system network interfaces without probing a server.
  ///
  /// A connected interface allows attempting a request; it does not guarantee
  /// Internet or server availability. This stream never emits restricted.
  Stream<ConnectivityState> get onNetworkConnectivityChanged {
    return _platform.onConnectivityChanged
        .map(_networkConnectivityConvert)
        .distinct();
  }

  /// Reads system network interfaces without TCP probes or cached probe results.
  /// This method never returns restricted and does not guarantee request success.
  Future<ConnectivityState> checkNetworkConnectivity() async {
    return _networkConnectivityConvert(await _platform.checkConnectivity());
  }

  ConnectivityState _networkConnectivityConvert(
      List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityState.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityState.mobile;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityState.unknown;
    }
    if (results.contains(ConnectivityResult.vpn)) {
      return ConnectivityState.vpn;
    }
    if (results.any((result) => result != ConnectivityResult.none)) {
      return ConnectivityState.unknown;
    }
    return ConnectivityState.none;
  }

  /// Checks the connection status of the device.
  ///
  /// Includes a TCP probe when an address has been configured. A restricted
  /// result describes that probe only and must not override HTTP responses.
  /// Use [checkNetworkConnectivity] for system interface state without a probe.
  ///
  /// The returned list is never empty. In case of no connectivity, the list contains
  /// a single element of [ConnectivityResult.none]. Note also that this is the only
  /// case where [ConnectivityResult.none] is present.
  Future<ConnectivityState> checkConnectivity() async {
    List<ConnectivityResult> results = await _platform.checkConnectivity();
    return _connectivityConvert(results);
  }

  /// only supported on iOS and macOS
  Future<ConnectivityState> checkVPNConnectivity() async {
    List<ConnectivityResult> results = await _platform.checkConnectivity();
    if (results.contains(ConnectivityResult.vpn)) {
      return ConnectivityState.vpn;
    }
    if (results.contains(ConnectivityResult.other)) {
      return ConnectivityState.unknown;
    }
    return ConnectivityState.none;
  }

  setAddressCheckOption(String address) {
    if (_address == address) {
      return;
    }
    _address = address;
    _addressCheckGeneration++;
    _cachedAddressCheckResult = null;
    _cachedAddressCheckTime = null;
    _ongoingAddressCheck = null;
  }

  /// Based on rule: Innocent until proven guilty
  /// check if connectivity is reliable
  Future<bool> _isConnectivityReliable() async {
    if (_address.isEmpty) {
      return true;
    }

    final cachedResult = _cachedAddressCheckResult;
    final cachedTime = _cachedAddressCheckTime;
    if (cachedResult != null &&
        cachedTime != null &&
        DateTime.now().difference(cachedTime) < _addressCheckCacheDuration) {
      return cachedResult;
    }

    final ongoingCheck = _ongoingAddressCheck;
    if (ongoingCheck != null) {
      return ongoingCheck;
    }

    final address = _address;
    final generation = _addressCheckGeneration;
    final check = checkAddressConnectivity(address);
    _ongoingAddressCheck = check;
    try {
      final result = await check;
      if (_addressCheckGeneration == generation) {
        _cachedAddressCheckResult = result;
        _cachedAddressCheckTime = DateTime.now();
      }
      return result;
    } finally {
      if (identical(_ongoingAddressCheck, check)) {
        _ongoingAddressCheck = null;
      }
    }
  }

  /// Checks whether [address] is reachable with a one-time TCP connection.
  ///
  /// This does not change the address configured by [setAddressCheckOption]
  /// and does not cache the result.
  Future<bool> checkAddressConnectivity(String address) async {
    try {
      final uri = Uri.parse(address);
      final host = uri.host;
      if (host.isEmpty) {
        return false;
      }
      final port = uri.hasPort
          ? uri.port
          : uri.scheme == 'https'
              ? 443
              : 80;

      final socket =
          await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      socket.destroy();
    } on SocketException {
      return false;
    } on FormatException {
      print('Invalid URL format');
      return false;
    }
    return true;
  }

  /// ConnectivityResult 网络标识ConnectivityState转化
  Future<ConnectivityState> _connectivityConvert(
      List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.wifi)) {
      return await _isConnectivityReliable()
          ? ConnectivityState.wifi
          : ConnectivityState.restricted;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return await _isConnectivityReliable()
          ? ConnectivityState.mobile
          : ConnectivityState.restricted;
    }
    return ConnectivityState.none;
  }
}
