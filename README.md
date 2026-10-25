# flutter_biometric

Typed biometric authentication for Android and macOS.

- Platform interface with token verification; adapters register themselves,
  the host app keeps only app-shell native code (the Android activity must be
  a `FlutterFragmentActivity` for `androidx.biometric` prompts).
- `queryCapabilities()` never throws: a platform without an adapter reports
  `BiometricCapabilities.none()`.
- Typed `BiometricAuthOutcome` results with stable reason codes; cancel,
  lockout and missing hardware are results, never channel exceptions.
- Android: androidx.biometric (`BiometricPrompt`, `BiometricManager`),
  fingerprint via `BIOMETRIC_STRONG`, face via `BIOMETRIC_WEAK` combined with
  the `FEATURE_FACE` hardware feature.
- macOS: LocalAuthentication (Touch ID; `.deviceOwnerAuthentication` policy
  for credential fallback).

## Usage

```dart
final biometric = FlutterBiometric();
final caps = await biometric.queryCapabilities();
if (caps.fingerprintAvailable) {
  final outcome = await biometric.authenticate(
    const BiometricAuthRequest(reason: '验证身份'),
  );
  print(outcome.isAuthenticated ? 'ok' : outcome.reason?.code);
}
```
