# Passwords

## Init

    flutter create --pub --template=app --description 'Keychain app' --org one.eki --project-name passwords passwords

## Deps

    pub global active encrypt
    pod setup
    flutter pub get

## Start

    open -a Simulator
    flutter run
    flutter run -d 1DDA5EB5-1A2B-4DDC-81C2-FC22231D1172
    flutter run -d marsgpl --release

## Icons

    https://fluttericon.com/

    cp ~/Downloads/flutter-icons-*/fonts/PwdIcons.ttf ~/projects/passwords-app/fonts; cp ~/Downloads/flutter-icons-*/pwd_icons_icons.dart ~/projects/passwords-app/lib/PwdIcons.dart; rm -rf ~/Downloads/flutter-icons-*

## Etc

<https://flutter.dev/docs/development/ios-project-migration>
<https://pub.dev/packages/flutter_secure_storage>
<https://dart.dev/guides/language/effective-dart/design>
<https://flutter.dev/docs/deployment/ios>
<https://flutter.dev/docs/deployment/android>
<https://flutter.dev/docs/development/ui/widgets/cupertino>
<https://flutter.dev/docs/development/ui/widgets>
<https://bloclibrary.dev/#/coreconcepts>
<https://codelabs.developers.google.com/codelabs/flutter-cupertino/>
