## 0.1.10

* Add probe-free system network queries and events; preserve existing reachability APIs.
* Clarify that restricted indicates a failed address probe, not global offline status.

## 0.1.9
- Add `checkAddressConnectivity` for uncached one-time TCP reachability checks without changing the configured address.

## 0.1.8
- Add real TCP reachability checks for addresses with explicit ports.
- Use HTTP port 80 and HTTPS port 443 when no port is specified.
- Cache probe results for 5 seconds and share concurrent probes to reduce socket overhead.
- Invalidate cached probes when the configured address changes and release sockets after successful checks.

## 0.1.7
- Add vibe coding agent context for Codex, Claude, Cursor, and Copilot.

## 0.1.6
- preciser connection check

## 0.1.5
- ios & macos plugin name changed

## 0.1.4
- bug fixed: macos plugin build

## 0.1.3
- bug fixed: ios plugin build

## 0.1.2
- pubspec.yaml tiny tuned

## 0.1.1
- tiny tuned

## 0.1.0
- Initial release
