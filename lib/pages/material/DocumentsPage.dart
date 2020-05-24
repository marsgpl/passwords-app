import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:passwords/widgets/PageMessage.dart';
import 'package:passwords/PwdIcons.dart';
import 'package:passwords/widgets/NewItemArrowPainter.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/helpers/Debouncer.dart';
import 'package:passwords/pages/material/BasePage.dart';
import 'package:passwords/pages/material/DocumentFormPage.dart';
import 'package:passwords/model/Document.dart';

class DocumentsPage extends StatefulWidget {
    @override
    DocumentsPageState createState() => DocumentsPageState();
}

class DocumentsPageState extends BasePageState<DocumentsPage> {
    final searchDebouncer = Debouncer(milliseconds: 200);
    Function onSearch;
    Function onSearchInstant;
    bool isSearching = false;
    TextEditingController searchController = TextEditingController();
    FocusNode searchFocus = FocusNode();

    @override
    void initState() {
        super.initState();

        final model = Provider.of<AppStateModel>(context, listen: false);

        model.initDocuments();

        onSearchInstant = model.onDocumentSearch;

        onSearch = (String searchText) =>
            searchDebouncer.run(() => onSearchInstant(searchText));

        if (model.documentsFilter.length > 0) {
            onSearchInstant('', silent: true);
        }
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
                onPressed: openSearch,
                tooltip: 'Search',
                icon: const Icon(Icons.search, size: 26),
            );
        } else {
            return BackButton(
                onPressed: closeSearch,
            );
        }
    }

    Widget buildAppBarTitle() {
        if (!isSearching) {
            return GestureDetector(
                onTap: openSearch,
                child: const Text('Documents'),
            );
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
                    isDense: false,
                    border: InputBorder.none,
                ),
                keyboardType: TextInputType.text,
                keyboardAppearance: Brightness.light,
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

    void closeSearch() {
        setState(() {
            searchController.text = '';
            isSearching = false;
        });

        onSearchInstant('');
    }

    void openSearch() {
        setState(() {
            isSearching = true;
        });
    }

    List<Widget> buildAppBarActions() {
        if (isSearching) {
            return [
                IconButton(
                    color: Colors.white,
                    onPressed: closeSearch,
                    tooltip: 'Close',
                    icon: const Icon(Icons.close, size: 26),
                ),
            ];
        } else {
            return [
                IconButton(
                    color: Colors.white,
                    onPressed: () => gotoAddDocumentPage(context),
                    tooltip: 'Create',
                    icon: const Icon(Icons.add, size: 26),
                ),
            ];
        }
    }

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            if (!model.documents.isInited) {
                return buildBodyLoading();
            } else if (model.documentsNotFoundBySearch()) {
                return buildBodyNotFoundBySearch(model);
            } else if (model.documentsNoItems()) {
                if (isSearching) {
                    return buildBodyNotFoundBySearch(model);
                } else {
                    return buildBodyNoItems();
                }
            } else {
                return buildBodyItems(model.documentsVisibleIds, model.documents.items);
            }
        }
    );

    Widget buildBodyLoading() => const Center(
        child: const CircularProgressIndicator(),
    );

    Widget buildBodyNotFoundBySearch(AppStateModel model) {
        String filter = model.documentsFilter;

        if (filter.length == 0) {
            return const Center(
                child: const Text('No results')
            );
        } else {
            if (filter.length > 10) {
                filter = filter.substring(0, 10) + '...';
            }

            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text('No results'),
                        Text('for \"$filter\"'),
                    ],
                ),
            );
        }
    }

    Widget buildBodyNoItems() => Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
            FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 0.5,
                child: Container(
                    child: CustomPaint(
                        painter: NewItemArrowPainter('Add document'),
                    ),
                ),
            ),
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(PwdIcons.document, color: Colors.black26, size: 60),
                        PageMessage.paragraph('IDs, passports\nand other documents'),
                    ],
                ),
            ),
        ],
    );

    Widget buildBodyItems(List<String> ids, Map<String, Document> items) {
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

    Widget buildBodyItemsRow(Document item) => ListTile(
        key: Key(item.id),
        title: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
            item.note != null ? item.note : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.fromLTRB(18, 0, 12, 0),
        onTap: () => gotoEditDocumentPage(item),
    );

    void gotoEditDocumentPage(Document item) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => DocumentFormPage(item: item),
            ),
        );
    }

    void gotoAddDocumentPage(BuildContext context) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => DocumentFormPage(item: null),
            ),
        );
    }
}
