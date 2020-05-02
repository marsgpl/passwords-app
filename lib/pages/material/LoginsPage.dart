import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/pages/material/BasePage.dart';
import 'package:passwords/pages/material/LoginFormPage.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';

class LoginsPage extends StatefulWidget {
    @override
    LoginsPageState createState() => LoginsPageState();
}

class LoginsPageState extends BasePageState<LoginsPage> {
    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initLogins();
    }

    @override
    Widget build(BuildContext context) => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            if (!model.loginsInited) {
                return buildBodyLoading();
            } else if (model.loginsNotFoundBySearch()) {
                return buildBodyNotFoundBySearch();
            } else if (model.loginsNoItems()) {
                return buildBodyNoItems();
            } else {
                return buildBodyItems(model.loginsVisibleIds, model.logins.items);
            }
        }
    );

    Widget buildBodyLoading() => Center(
        child: const CircularProgressIndicator(),
    );

    Widget buildBodyNotFoundBySearch() => Center(
        child: const Text('Nothing found'),
    );

    Widget buildBodyNoItems() => Center(
        child: const Text('No logins yet'),
    );

    Widget buildBodyItems(List<String> ids, Map<String, Login> items) {
        final rowsCount = ids.length * 2 - 1;

        return CustomScrollView(
            semanticChildCount: rowsCount,
            slivers: [
                SliverSafeArea(
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                            if (index >= rowsCount) {
                                return null;
                            } else if (index.isOdd) {
                                return Divider(
                                    height: .5,
                                    thickness: .5,
                                    indent: 0,
                                );
                            } else {
                                int itemIndex = index ~/ 2;
                                return buildBodyItemsRow(items[ids[itemIndex]]);
                            }
                        }),
                    ),
                ),
            ],
        );
    }

    Widget buildBodyItemsRow(Login item) => Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: ListTile(
            key: Key(item.id),
            title: Text(item.title),
            subtitle: Text(item.login != null ? item.login : ''),
            trailing: const Icon(Icons.chevron_right),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            onTap: () => gotoEditLoginPage(item),
        ),
        actions: [
            IconSlideAction(
                caption: 'Copy login',
                color: const Color(0xFF636E72),
                foregroundColor: Colors.white,
                icon: Icons.alternate_email,
                onTap: () => copyLogin(item),
            ),
            IconSlideAction(
                caption: 'Copy password',
                color: const Color(0xFF2C3436),
                foregroundColor: Colors.white,
                icon: Icons.more_horiz,
                onTap: () => copyPassword(item),
            ),
        ],
    );

    void copyLogin(Login item) {
        Clipboard.setData(ClipboardData(text: item.login));
        snack(message: 'Login copied');
    }

    void copyPassword(Login item) {
        Clipboard.setData(ClipboardData(text: item.password));
        snack(message: 'Password copied');
    }

    void gotoEditLoginPage(Login item) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => LoginFormPage(item: item),
            ),
        );
    }
}
