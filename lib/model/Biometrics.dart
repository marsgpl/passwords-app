import 'package:local_auth/local_auth.dart';

class Biometrics {
    LocalAuthentication localAuth;
    bool isFaceIdSupported;
    bool isTouchIdSupported;

    bool get isInited => localAuth != null;
    bool get isSupported => isFaceIdSupported || isTouchIdSupported;

    void reset() {
        localAuth = null;
        isFaceIdSupported = null;
        isTouchIdSupported = null;
    }

    Future<void> init() async {
        localAuth = LocalAuthentication();
        List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
        isFaceIdSupported = availableBiometrics.contains(BiometricType.face);
        isTouchIdSupported = availableBiometrics.contains(BiometricType.fingerprint);
    }

    Future<bool> challenge() async {
        if (!isSupported) return false;

        try {
            return await localAuth.authenticateWithBiometrics(
                localizedReason: isFaceIdSupported ?
                    'Pass Face ID challenge to proceed' :
                    'Scan your finger to proceed',
                stickyAuth: true,
                sensitiveTransaction: false,
            );
        } catch (error) {
            print('Biometrics challenge error: $error');
            return false;
        }
    }
}
