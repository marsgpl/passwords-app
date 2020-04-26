import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:passwords/Styles@cupertino.dart';
import 'package:passwords/pages/cupertino/AddLoginPage.dart';
import 'package:passwords/pages/cupertino/EditLoginPage.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/model/Login.dart';

class LoginsPage extends StatefulWidget {
    @override
    LoginsPageState createState() => LoginsPageState();
}

class LoginsPageState extends State<LoginsPage> with SingleTickerProviderStateMixin {
    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initLogins();
    }

    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: buildNavigationBar(),
            child: Consumer<AppStateModel>(
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
                },
            ),
        );
    }

    void gotoAddLoginPage() {
        Navigator.of(context).push(
            CupertinoPageRoute(
                builder: (context) => AddLoginPage(),
                maintainState: false,
                fullscreenDialog: true,
                title: 'New login',
            ),
        );
    }

    void gotoEditLoginPage(Login item) {
        Navigator.of(context).push(
            CupertinoPageRoute(
                builder: (context) => EditLoginPage(item: item),
                maintainState: false,
                title: 'Edit login',
            ),
        );
    }

    Widget buildNavigationBar() => CupertinoNavigationBar(
        trailing: GestureDetector(
            onTap: gotoAddLoginPage,
            child: const Icon(CupertinoIcons.add, semanticLabel: 'Add'),
        ),
    );

    Widget buildBodyLoading() => Center(
        child: CupertinoActivityIndicator(),
    );

    Widget buildBodyNotFoundBySearch() => Center(
        child: Text('No matched'),
    );

    Widget buildBodyNoItems() => Center(
        child: Text('No logins yet'),
    );

    Future<void> showCopiedFeedback(String message) async {
        showCupertinoDialog<void>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                content: Text(message,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Styles.notImportantColor,
                    ),
                ),
            ),
        );

        await Future.delayed(const Duration(milliseconds: 1000));

        Navigator.of(context, rootNavigator: true).pop('Discard');
    }

    Widget buildBodyItemsRow({
        int index,
        Login item,
        bool isLastItem = false,
    }) {
        Widget info = Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(item.login),
                    Row(
                        children: [
                            const Text('copy:', style: Styles.hint),
                            CupertinoButton(
                                child: const Text('login'),
                                padding: const EdgeInsets.fromLTRB(32, 0, 16, 0),
                                onPressed: () {
                                    Clipboard.setData(ClipboardData(text: item.login));
                                    showCopiedFeedback('Login copied');
                                },
                            ),
                            CupertinoButton(
                                child: const Text('password'),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                onPressed: () {
                                    Clipboard.setData(ClipboardData(text: item.password));
                                    showCopiedFeedback('Password copied');
                                },
                            ),
                        ],
                    ),
                ],
            ),
        );

        Widget open = CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.right_chevron, semanticLabel: 'Edit'),
            onPressed: () => gotoEditLoginPage(item),
        );

        Widget row = SafeArea(
            minimum: const EdgeInsets.fromLTRB(18, 14, 8, 4),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    info,
                    open,
                ],
            ),
        );

        Widget divider = Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Container(
                height: .5,
                color: Styles.dividerColor,
            ),
        );

        return Column(
            children: [
                row,
                divider,
            ],
        );
    }

    Widget buildBodyItems(List<String> ids, Map<String, Login> items) => CustomScrollView(
        semanticChildCount: ids.length,
        slivers: [
            SliverSafeArea(
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                        if (index >= ids.length) return null;

                        return buildBodyItemsRow(
                            index: index,
                            item: items[ids[index]],
                            isLastItem: index == ids.length - 1,
                        );
                    }),
                ),
            ),
        ],
    );
}
