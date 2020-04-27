import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:passwords/pages/cupertino/BasePage.dart';
import 'package:url_launcher/url_launcher.dart';
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

class LoginsPageState extends BasePageState<LoginsPage> with SingleTickerProviderStateMixin {
    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initLogins();
    }

    Future<void> openItemWebsite(Login item) async {
        if (item.website == null || item.website.trim().length == 0) {
            return showFeedback('${item.title}: website is empty');
        }

        String url = Uri.encodeFull(item.website);

        if (!url.contains('://')) {
            url = 'https://$url';
        }

        if (!await canLaunch(url)) {
            return showFeedback('Website open error\n$url');
        }

        await launch(url, forceSafariVC: false);
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
        trailing: Container(
            transform: Matrix4.translationValues(6, 0, 0),
            child: CupertinoButton(
                borderRadius: const BorderRadius.all(Radius.zero),
                padding: const EdgeInsets.all(0),
                onPressed: gotoAddLoginPage,
                child: const Icon(CupertinoIcons.add, semanticLabel: 'Add', size: 30),
            ),
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

    Widget buildBodyItemsRow({
        int index,
        Login item,
        bool isLastItem = false,
    }) {
        Widget icon = CupertinoButton(
            borderRadius: const BorderRadius.all(Radius.zero),
            padding: const EdgeInsets.all(0),
            onPressed: () => openItemWebsite(item),
            child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 12),
                alignment: const Alignment(0.0, 0.0),
                decoration: new BoxDecoration(
                    color: Styles.circleColor,
                    shape: BoxShape.circle,
                ),
                child: Text(
                    (item.title ?? '').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: Styles.whiteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                    ),
                ),
            ),
        );

        Widget info = Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Container(
                        margin: EdgeInsets.only(bottom: 3),
                        child: Text(
                            item.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                            ),
                        ),
                    ),
                    Text(item.login),
                    Row(
                        children: [
                            item.login.length == 0 ? Container() : CupertinoButton(
                                child: const Text('Copy login'),
                                padding: const EdgeInsets.only(right: 16),
                                onPressed: () {
                                    Clipboard.setData(ClipboardData(text: item.login));
                                    showFeedback('Login copied');
                                },
                            ),
                            item.password.length == 0 ? Container() : CupertinoButton(
                                child: const Text('Copy password'),
                                padding: const EdgeInsets.only(left: 16),
                                onPressed: () {
                                    Clipboard.setData(ClipboardData(text: item.password));
                                    showFeedback('Password copied');
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
            minimum: const EdgeInsets.fromLTRB(14, 14, 8, 4),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    icon,
                    info,
                    open,
                ],
            ),
        );

        Widget divider = Padding(
            // rowMarginLeft + circleWidth + circleMarginRight
            padding: const EdgeInsets.only(left: (14 + 42 + 12) + 0.0),
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
