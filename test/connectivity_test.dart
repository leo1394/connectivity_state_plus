// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:connectivity_state_plus/connectivity_state_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const List<ConnectivityResult> kCheckConnectivityResult = [
  ConnectivityResult.wifi
];

void main() {
  group('Connectivity', () {
    late Connectivity connectivity;
    MockConnectivityPlatform fakePlatform;
    setUp(() async {
      fakePlatform = MockConnectivityPlatform();
      ConnectivityPlatform.instance = fakePlatform;
      connectivity = Connectivity();
    });

    test('checkConnectivity', () async {
      final result = await connectivity.checkConnectivity();
      expect(result, ConnectivityState.wifi);
    });

    test('checkConnectivity supports address with port', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      connectivity.setAddressCheckOption('http://127.0.0.1:${server.port}');

      try {
        final result = await connectivity.checkConnectivity();
        expect(result, ConnectivityState.wifi);
      } finally {
        await server.close();
        connectivity.setAddressCheckOption('');
      }
    });

    test('checkConnectivity reuses recent address check', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      connectivity.setAddressCheckOption('http://127.0.0.1:${server.port}');

      try {
        final firstResult = await connectivity.checkConnectivity();
        await server.close();
        final secondResult = await connectivity.checkConnectivity();

        expect(firstResult, ConnectivityState.wifi);
        expect(secondResult, ConnectivityState.wifi);
      } finally {
        await server.close();
        connectivity.setAddressCheckOption('');
      }
    });

    test('checkConnectivity shares concurrent address check', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final acceptedSockets = <Socket>[];
      var connectionCount = 0;
      final subscription = server.listen((socket) {
        acceptedSockets.add(socket);
        connectionCount++;
      });
      connectivity.setAddressCheckOption('http://127.0.0.1:${server.port}');

      try {
        final results = await Future.wait([
          connectivity.checkConnectivity(),
          connectivity.checkConnectivity(),
          connectivity.checkConnectivity(),
        ]);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(results, everyElement(ConnectivityState.wifi));
        expect(connectionCount, 1);
      } finally {
        for (final socket in acceptedSockets) {
          socket.destroy();
        }
        await subscription.cancel();
        await server.close();
        connectivity.setAddressCheckOption('');
      }
    });

    test('setAddressCheckOption invalidates cached address check', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      connectivity.setAddressCheckOption('http://127.0.0.1:${server.port}');

      try {
        final firstResult = await connectivity.checkConnectivity();
        connectivity.setAddressCheckOption('not-a-url');
        final secondResult = await connectivity.checkConnectivity();

        expect(firstResult, ConnectivityState.wifi);
        expect(secondResult, ConnectivityState.restricted);
      } finally {
        await server.close();
        connectivity.setAddressCheckOption('');
      }
    });

    test(
        'checkAddressConnectivity performs an uncached one-time check '
        'without changing the configured address', () async {
      final configuredServer =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final oneTimeServer =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      connectivity
          .setAddressCheckOption('http://127.0.0.1:${configuredServer.port}');

      try {
        final address = 'http://127.0.0.1:${oneTimeServer.port}';
        final firstResult =
            await connectivity.checkAddressConnectivity(address);
        await oneTimeServer.close();
        final secondResult =
            await connectivity.checkAddressConnectivity(address);
        final configuredResult = await connectivity.checkConnectivity();

        expect(firstResult, isTrue);
        expect(secondResult, isFalse);
        expect(configuredResult, ConnectivityState.wifi);
      } finally {
        await oneTimeServer.close();
        await configuredServer.close();
        connectivity.setAddressCheckOption('');
      }
    });
  });
}

class MockConnectivityPlatform extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return kCheckConnectivityResult;
  }
}
