import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/PasswordsListPageModel.dart';
import '../widgets/passwordsList.dart';
import '../pages/BasePage.dart';
import '../pages/AddPasswordPage.dart';
import '../pages/EditPasswordPage.dart';
import '../PasswordsStorage.dart';

class PasswordsListPage extends StatefulWidget {
    final PasswordsStorage pwStorage;

    PasswordsListPage():
        pwStorage = PasswordsStorage();

    @override
    PasswordsListPageState createState() => PasswordsListPageState();
}

class PasswordsListPageState extends BasePageState<PasswordsListPage> {
    PasswordsListPageModel model;

    @override
    void initState() {
        model = PasswordsListPageModel(widget.pwStorage);
        model.loadPasswords();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return ScopedModel<PasswordsListPageModel>(
            model: model,
            child: Scaffold(
                appBar: AppBar(
                    title: Text('Passwords'),
                    actions: [
                        IconButton(
                            icon: Icon(Icons.search),
                            onPressed: showSearch,
                        ),
                    ],
                ),
                body: buildBody(),
                floatingActionButton: FloatingActionButton(
                    onPressed: gotoAddPasswordPage,
                    child: Icon(Icons.add),
                ),
            ),
        );
    }

    Widget buildBody() {
        return SafeArea(
            child: ScopedModelDescendant<PasswordsListPageModel>(
                builder: (context, child, model) {
                    if (model.state == PasswordsListPageModelState.LOADING) {
                        return Center(
                            child: CircularProgressIndicator(),
                        );
                    } else if (model.state == PasswordsListPageModelState.HAS_PASSWORDS) {
                        return passwordsList(
                            model.pwStorage,
                            model.shownPasswordsIds,
                            gotoEditPasswordPage,
                        );
                    } else if (model.state == PasswordsListPageModelState.NO_PASSWORDS) {
                        return Center(
                            child: Text('No passwords yet'),
                        );
                    }

                    return Container(); // empty body
                },
            ),
        );
    }

    void showSearch() {
        alert(title: 'TODO', message: 'Search');
    }

    void gotoAddPasswordPage() {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    AddPasswordPage(
                        onPasswordAdd: model.addPassword,
                    ),
            ),
        );
    }

    void gotoEditPasswordPage(String passwordId) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    EditPasswordPage(
                        password: model.pwStorage.getById(passwordId),
                        onPasswordSave: model.savePassword,
                        onPasswordDelete: model.deletePassword,
                    ),
            ),
        );
    }
}
