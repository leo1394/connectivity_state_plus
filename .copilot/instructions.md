# connectivity_state_plus Copilot Context

Use singleton `Connectivity()`. Prefer `ConnectivityState.restricted` handling for networks that exist but cannot reach the configured address. Do not use connectivity state as the only guarantee that HTTP requests will succeed.
