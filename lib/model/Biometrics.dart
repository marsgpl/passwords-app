import 'package:local_auth/local_auth.dart';

class Biometrics {
    LocalAuthentication localAuth;
    bool isFaceIdSupported;
    bool isTouchIdSupported;
    bool isAuthed;

    bool get isInited => localAuth != null;

    Future<void> init() async {
        localAuth = LocalAuthentication();
        List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
        isFaceIdSupported = availableBiometrics.contains(BiometricType.face);
        isTouchIdSupported = availableBiometrics.contains(BiometricType.fingerprint);
    }

    Future<bool> challenge() async {
        if (!isFaceIdSupported && !isTouchIdSupported) return false; // don't keep result

        try {
            isAuthed = await localAuth.authenticateWithBiometrics(
                localizedReason: isFaceIdSupported ?
                    'Pass Face ID challenge to proceed' :
                    'Scan your finger to proceed',
                stickyAuth: true,
                sensitiveTransaction: false,
            );
        } catch (error) {
            isAuthed = false;
        }

        return isAuthed;
    }
}
