import Cocoa
import LocalAuthentication
import FlutterMacOS

/// LocalAuthentication adapter over the flutter_biometric/auth channel.
/// Capability queries and prompt replies resolve to typed status maps;
/// nothing on this channel throws.
public class FlutterBiometricPlugin: NSObject, FlutterPlugin {
    private static let channelName = "flutter_biometric/auth"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: FlutterBiometricPlugin.channelName,
            binaryMessenger: registrar.messenger
        )
        registrar.addMethodCallDelegate(FlutterBiometricPlugin(), channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "queryCapabilities":
            result(queryCapabilities())
        case "authenticate":
            authenticate(arguments: call.arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func queryCapabilities() -> [String: Any] {
        let context = LAContext()
        var biometricError: NSError?
        let canBiometrics = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics, error: &biometricError)

        // biometryType is only meaningful after a canEvaluatePolicy call.
        var fingerprint = false
        var face = false
        var enrolled: [String] = []
        if canBiometrics {
            switch context.biometryType {
            case .touchID:
                fingerprint = true
                enrolled.append("fingerprint")
            case .faceID:
                face = true
                enrolled.append("face")
            default:
                break
            }
        }

        let credentialContext = LAContext()
        var credentialError: NSError?
        let canCredential = credentialContext.canEvaluatePolicy(
            .deviceOwnerAuthentication, error: &credentialError)

        return [
            "deviceSupported": fingerprint || face || canCredential,
            "fingerprintAvailable": fingerprint,
            "faceAvailable": face,
            "deviceCredentialAvailable": canCredential,
            "enrolledTypes": enrolled,
        ]
    }

    private func authenticate(arguments: Any?, result: @escaping FlutterResult) {
        let args = arguments as? [String: Any]
        guard let reason = args?["reason"] as? String, !reason.trimmingCharacters(in: .whitespaces).isEmpty else {
            result([
                "status": "invalidData",
                "reason": "missing_reason",
                "message": "认证原因不能为空",
            ])
            return
        }
        let strength = args?["strength"] as? String ?? "strong"
        let policy: LAPolicy = strength == "strongWithCredential"
            ? .deviceOwnerAuthentication
            : .deviceOwnerAuthenticationWithBiometrics

        let context = LAContext()
        var replied = false
        func complete(_ map: [String: Any]) {
            if !replied {
                replied = true
                result(map)
            }
        }

        // evaluatePolicy replies on a private queue; platform channel results
        // must be delivered on the main thread.
        context.evaluatePolicy(policy, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    // LocalAuthentication does not report which mechanism the
                    // user completed; report biometric semantics and leave
                    // credential detection to Android, which exposes it.
                    complete([
                        "status": "authenticated",
                        "usedDeviceCredential": false,
                    ])
                    return
                }
                complete(self.mapError(error as NSError?))
            }
        }
    }

    private func mapError(_ error: NSError?) -> [String: Any] {
        guard let error = error else {
            return [
                "status": "failed",
                "reason": "macos_error_unknown",
                "message": "LocalAuthentication 未返回错误详情",
            ]
        }
        let status: String
        switch error.code {
        case LAError.userCancel.rawValue, LAError.userFallback.rawValue, LAError.appCancel.rawValue:
            status = "userCancel"
        case LAError.systemCancel.rawValue:
            status = "systemCancel"
        case LAError.passcodeNotSet.rawValue:
            status = "credentialNotSet"
        case LAError.biometryNotAvailable.rawValue:
            status = "noHardware"
        case LAError.biometryNotEnrolled.rawValue:
            status = "notEnrolled"
        case LAError.biometryLockout.rawValue:
            status = "lockout"
        case LAError.invalidContext.rawValue:
            status = "unavailable"
        case LAError.authenticationFailed.rawValue:
            status = "failed"
        default:
            status = "failed"
        }
        return [
            "status": status,
            "reason": "macos_error_\(error.code)",
            "message": error.localizedDescription,
        ]
    }
}
