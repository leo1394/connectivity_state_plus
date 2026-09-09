import 'dart:async';
import 'dart:io';

import 'package:connectivity_state_plus/connectivity_state_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class NetworkPlatform extends ConnectivityPlatform {
  List<ConnectivityResult> results = [ConnectivityResult.wifi];
  final events = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => events.stream;
}

void main() {
  late ConnectivityPlatform original;
  late NetworkPlatform platform;
  final connectivity = Connectivity();

  setUp(() {
    original = ConnectivityPlatform.instance;
    platform = NetworkPlatform();
    ConnectivityPlatform.instance = platform;
    connectivity.setAddressCheckOption('');
  });

  tearDown(() async {
    connectivity.setAddressCheckOption('');
    ConnectivityPlatform.instance = original;
    await platform.events.close();
  });

  test('failed server probe does not override system wifi', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close();
    connectivity.setAddressCheckOption('http://127.0.0.1:$port');
    expect(await connectivity.checkConnectivity(), ConnectivityState.restricted);
    expect(await connectivity.checkNetworkConnectivity(), ConnectivityState.wifi);
    expect(await connectivity.checkConnectivity(), ConnectivityState.restricted);
  });

  test('network queries and events never probe the configured server', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    int connections = 0;
    final subscription = server.listen((socket) {
      connections++;
      socket.destroy();
    });
    connectivity.setAddressCheckOption('http://127.0.0.1:${server.port}');
    expect(await connectivity.checkNetworkConnectivity(), ConnectivityState.wifi);
    final event = connectivity.onNetworkConnectivityChanged.first;
    platform.events.add([ConnectivityResult.wifi]);
    expect(await event, ConnectivityState.wifi);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(connections, 0);
    await subscription.cancel();
    await server.close();
  });

  test('interface mapping and priority', () async {
    final cases = <List<ConnectivityResult>, ConnectivityState>{
      []: ConnectivityState.none,
      [ConnectivityResult.none]: ConnectivityState.none,
      [ConnectivityResult.wifi]: ConnectivityState.wifi,
      [ConnectivityResult.mobile]: ConnectivityState.mobile,
      [ConnectivityResult.ethernet]: ConnectivityState.unknown,
      [ConnectivityResult.vpn]: ConnectivityState.vpn,
      [ConnectivityResult.bluetooth]: ConnectivityState.unknown,
      [ConnectivityResult.other]: ConnectivityState.unknown,
      [ConnectivityResult.vpn, ConnectivityResult.ethernet]: ConnectivityState.unknown,
      [ConnectivityResult.ethernet, ConnectivityResult.mobile]: ConnectivityState.mobile,
      [ConnectivityResult.mobile, ConnectivityResult.wifi]: ConnectivityState.wifi,
      [ConnectivityResult.none, ConnectivityResult.wifi]: ConnectivityState.wifi,
    };
    for (final entry in cases.entries) {
      platform.results = entry.key;
      expect(await connectivity.checkNetworkConnectivity(), entry.value);
    }
  });

  test('events report connection transitions and deduplicate mapped states', () async {
    final received = <ConnectivityState>[];
    final subscription = connectivity.onNetworkConnectivityChanged.listen(received.add);
    for (final results in [
      [ConnectivityResult.wifi],
      [ConnectivityResult.wifi, ConnectivityResult.vpn],
      [ConnectivityResult.none],
      [ConnectivityResult.mobile],
      [ConnectivityResult.wifi],
    ]) {
      platform.events.add(results);
    }
    await Future<void>.delayed(Duration.zero);
    expect(received, [ConnectivityState.wifi, ConnectivityState.none,
      ConnectivityState.mobile, ConnectivityState.wifi]);
    await subscription.cancel();
  });
}
