import 'package:flutter/material.dart';
import 'package:passwords/helpers/Debouncer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/pages/material/BasePage.dart';
import 'package:passwords/pages/material/LoginFormPage.dart';
import 'package:passwords/model/AppStateModel.dart';

class LoginsPage extends StatefulWidget {
    @override
    LoginsPageState createState() => LoginsPageState();
}

class LoginsPageState extends BasePageState<LoginsPage> {
    final searchDebouncer = Debouncer(milliseconds: 500);
    Function onSearch;
    Function onSearchInstant;
    bool isSearching = false;
    TextEditingController searchController = TextEditingController();
    FocusNode searchFocus = FocusNode();

    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initLogins();

        onSearchInstant = model.onLoginSearch;

        onSearch = (String searchText) =>
            searchDebouncer.run(() => onSearchInstant(searchText));
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
    );

    Widget buildAppBar() => AppBar(
        leading: buildAppBarLeading(),
        title: buildAppBarTitle(),
        actions: buildAppBarActions(),
    );

    Widget buildAppBarLeading() {
        if (!isSearching) {
            return IconButton(
                color: Colors.white,
                onPressed: () => setState(() {
                    isSearching = true;
                }),
                tooltip: 'Search',
                icon: const Icon(Icons.search, size: 26),
            );
        } else {
            return BackButton(
                onPressed: () {
                    setState(() {
                        searchController.text = '';
                        isSearching = false;
                    });

                    AppStateModel model = Provider.of<AppStateModel>(context, listen: false);
                    model.onLoginSearch('');
                },
            );
        }
    }

    Widget buildAppBarTitle() {
        if (!isSearching) {
            return const Text('Logins');
        } else {
            return TextFormField(
                controller: searchController,
                focusNode: searchFocus,
                decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                    ),
                    hasFloatingPlaceholder: false,
                    isDense: false,
                    border: InputBorder.none,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                ),
                autocorrect: false,
                enableSuggestions: false,
                onChanged: onSearch,
                onFieldSubmitted: onSearchInstant,
                cursorColor: Colors.white,
                enableInteractiveSelection: false,
                autofocus: true,
            );
        }
    }

    List<Widget> buildAppBarActions() {
        if (isSearching) {
            return null;
        } else {
            return [
                IconButton(
                    color: Colors.white,
                    onPressed: () => gotoAddLoginPage(context),
                    tooltip: 'Create',
                    icon: const Icon(Icons.add, size: 26),
                ),
            ];
        }
    }

    Widget buildBody() => Consumer<AppStateModel>(
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
                                return const Divider(
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
        actionPane: const SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: ListTile(
            key: Key(item.id),
            title: Text(item.title),
            subtitle: Text(item.login != null ? item.login : ''),
            trailing: const Icon(Icons.chevron_right),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            onTap: () => gotoEditLoginPage(item),
        ),
        actions: [
            IconSlideAction(
                key: Key('CopyLogin'),
                caption: 'Copy login',
                color: const Color(0xFF636E72),
                foregroundColor: Colors.white,
                icon: Icons.alternate_email,
                onTap: () => copyLogin(item),
            ),
            IconSlideAction(
                key: Key('CopyPassword'),
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

    void gotoAddLoginPage(BuildContext context) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => LoginFormPage(item: null),
            ),
        );
    }
}
