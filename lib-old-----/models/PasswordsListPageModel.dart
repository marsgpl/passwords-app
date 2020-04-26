import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../entities/Password.dart';
import '../PasswordsStorage.dart';

enum PasswordsListPageModelState {
    INITIAL,
    LOADING,
    HAS_PASSWORDS,
    NO_PASSWORDS,
}

class PasswordsListPageModel extends Model {
    PasswordsStorage pwStorage;
    PasswordsListPageModelState state = PasswordsListPageModelState.INITIAL;
    List<String> shownPasswordsIds;

    PasswordsListPageModel(this.pwStorage);

    void loadPasswords() async {
        state = PasswordsListPageModelState.LOADING;

        notifyListeners();

        await pwStorage.loadAll();
        shownPasswordsIds = pwStorage.ids();

        detectState();
        notifyListeners();
    }

    void detectState() {
        state = shownPasswordsIds.length > 0 ?
            PasswordsListPageModelState.HAS_PASSWORDS :
            PasswordsListPageModelState.NO_PASSWORDS;
    }

    Future<void> addPassword(Password newPassword) async {
        await pwStorage.add(newPassword);
        shownPasswordsIds.insert(0, newPassword.id);

        detectState();
        notifyListeners();
    }

    Future<void> savePassword(Password password) async {
        await pwStorage.save(password);

        notifyListeners();
    }

    Future<void> deletePassword(Password password) async {
        await pwStorage.delete(password);
        shownPasswordsIds = pwStorage.ids();

        detectState();
        notifyListeners();
    }
}
