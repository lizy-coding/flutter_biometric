import 'src/biometric_channel_contract.dart';

/// Terminal state of one authentication attempt. Only
/// [BiometricAuthStatus.authenticated] carries a value.
enum BiometricAuthStatus {
  authenticated,
  userCancel,
  systemCancel,
  timeout,
  lockout,
  permanentlyLockedOut,
  notEnrolled,
  noHardware,
  hardwareUnavailable,
  credentialNotSet,
  unsupported,
  unavailable,
  invalidData,
  failed,
}

/// A stable, machine-readable reason with a human-readable explanation.
class BiometricReason {
  const BiometricReason(this.code, this.message);
  final String code;
  final String message;
}

/// Distinguishes a successful authentication from absent support and runtime
/// failures; only [BiometricAuthStatus.authenticated] carries a value.
class BiometricAuthOutcome {
  const BiometricAuthOutcome._(this.status, this.value, this.reason);

  factory BiometricAuthOutcome.authenticated({
    bool usedDeviceCredential = false,
  }) => BiometricAuthOutcome._(
    BiometricAuthStatus.authenticated,
    BiometricAuthResult(usedDeviceCredential: usedDeviceCredential),
    null,
  );

  factory BiometricAuthOutcome.state(
    BiometricAuthStatus status,
    String code,
    String message,
  ) {
    if (status == BiometricAuthStatus.authenticated) {
      throw ArgumentError.value(status);
    }
    return BiometricAuthOutcome._(
      status,
      null,
      BiometricReason(
        code.trim().isEmpty ? 'unspecified_reason' : code,
        message.trim().isEmpty ? 'No additional detail' : message,
      ),
    );
  }

  final BiometricAuthStatus status;
  final BiometricAuthResult? value;
  final BiometricReason? reason;

  bool get isAuthenticated => status == BiometricAuthStatus.authenticated;

  factory BiometricAuthOutcome.fromMap(Map<Object?, Object?>? map) {
    if (map == null) {
      return BiometricAuthOutcome.state(
        BiometricAuthStatus.invalidData,
        'null_response',
        'Native adapter returned no result',
      );
    }
    final rawStatus = map[BiometricChannelContract.keyStatus];
    if (rawStatus is! String || rawStatus.isEmpty) {
      return BiometricAuthOutcome.state(
        BiometricAuthStatus.invalidData,
        'missing_status',
        'Native adapter result has no status',
      );
    }
    final reason = BiometricReason(
      (map[BiometricChannelContract.keyReason] as String?) ??
          'unspecified_reason',
      (map[BiometricChannelContract.keyMessage] as String?) ??
          'No additional detail',
    );
    if (rawStatus == 'authenticated') {
      return BiometricAuthOutcome.authenticated(
        usedDeviceCredential:
            map[BiometricChannelContract.keyUsedDeviceCredential] == true,
      );
    }
    for (final status in BiometricAuthStatus.values) {
      if (status.name == rawStatus) {
        return BiometricAuthOutcome._(status, null, reason);
      }
    }
    return BiometricAuthOutcome.state(
      BiometricAuthStatus.invalidData,
      'unknown_status',
      'Unknown authentication status: $rawStatus',
    );
  }
}

/// Result of a successful authentication. `usedDeviceCredential` reports
/// whether a PIN/pattern/password (Android) or the account password (macOS)
/// completed the flow instead of a biometric sensor.
class BiometricAuthResult {
  const BiometricAuthResult({required this.usedDeviceCredential});
  final bool usedDeviceCredential;
}

/// Which sensor classes a flow accepts.
enum BiometricStrength {
  /// Class 3 (strong) biometrics only, e.g. fingerprint on enrolled devices.
  strong,

  /// Class 2 (weak) or stronger biometrics; on Android this includes face.
  weak,

  /// Strong biometrics with PIN/pattern/password fallback enabled.
  strongWithCredential,
}

/// Parameters of one authentication prompt; `reason` is shown to the user.
class BiometricAuthRequest {
  const BiometricAuthRequest({
    required this.reason,
    this.strength = BiometricStrength.strong,
    this.title = '身份验证',
    this.subtitle,
    this.negativeLabel = '取消',
  });

  final String reason;
  final BiometricStrength strength;
  final String title;
  final String? subtitle;
  final String negativeLabel;

  Map<Object?, Object?> toMap() => {
    BiometricChannelContract.argReason: reason,
    BiometricChannelContract.argStrength: strength.name,
    BiometricChannelContract.argTitle: title,
    if (subtitle != null) BiometricChannelContract.argSubtitle: subtitle,
    BiometricChannelContract.argNegativeLabel: negativeLabel,
  };
}

/// Adapter support surface, separate from device enrollment state. Every flag
/// means "usable right now": hardware present, secure screen set up and the
/// biometric enrolled. Runtime queries complement the static platform matrix.
class BiometricCapabilities {
  const BiometricCapabilities({
    required this.deviceSupported,
    required this.fingerprintAvailable,
    required this.faceAvailable,
    required this.deviceCredentialAvailable,
    required this.enrolledTypes,
  });

  const BiometricCapabilities.none()
    : deviceSupported = false,
      fingerprintAvailable = false,
      faceAvailable = false,
      deviceCredentialAvailable = false,
      enrolledTypes = const [];

  factory BiometricCapabilities.fromMap(Map<Object?, Object?> map) {
    final types = map[BiometricChannelContract.keyEnrolledTypes];
    return BiometricCapabilities(
      deviceSupported: map[BiometricChannelContract.keyDeviceSupported] == true,
      fingerprintAvailable:
          map[BiometricChannelContract.keyFingerprintAvailable] == true,
      faceAvailable: map[BiometricChannelContract.keyFaceAvailable] == true,
      deviceCredentialAvailable:
          map[BiometricChannelContract.keyDeviceCredentialAvailable] == true,
      enrolledTypes: [
        if (types is List<Object?>)
          for (final type in types)
            if (type is String &&
                (type == BiometricType.fingerprint.name ||
                    type == BiometricType.face.name))
              BiometricType.values.byName(type),
      ],
    );
  }

  final bool deviceSupported;
  final bool fingerprintAvailable;
  final bool faceAvailable;
  final bool deviceCredentialAvailable;
  final List<BiometricType> enrolledTypes;
}

/// Sensor classes reported by [BiometricCapabilities.enrolledTypes].
enum BiometricType { fingerprint, face }
