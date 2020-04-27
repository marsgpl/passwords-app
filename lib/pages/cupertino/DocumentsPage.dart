import 'package:flutter/cupertino.dart';
import 'package:passwords/pages/cupertino/BasePage.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/Styles@cupertino.dart';

class DocumentsPage extends StatefulWidget {
    @override
    DocumentsPageState createState() => DocumentsPageState();
}

class DocumentsPageState extends BasePageState<DocumentsPage> {
    bool inited = false;
    bool locked = true;

    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initDocuments();
    }

    @override
    didChangeDependencies() {
        super.didChangeDependencies();

        AppStateModel model = Provider.of<AppStateModel>(context);

        bool unlocked = model.documents.settings['unlocked'];

        if (!inited && model.documentsInited) {
            inited = true;
            locked = unlocked == null;
        } else if (locked && unlocked != null) {
            locked = false;
        } else if (!locked && unlocked == null) {
            locked = true;
        }
    }

    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: buildNavigationBar(),
            child: Consumer<AppStateModel>(
                builder: (context, model, consumer) {
                    if (!model.documentsInited) {
                        return buildBodyLoading();
                    } else if (locked) {
                        return buildBodyLocked(model);
                    } else {
                        return Center();
                    }
                },
            ),
        );
    }

    Widget buildNavigationBar() {
        if (!inited || locked) {
            return CupertinoNavigationBar();
        } else {
            return CupertinoNavigationBar(
                trailing: GestureDetector(
                    onTap: () => {},
                    child: const Icon(CupertinoIcons.add, semanticLabel: 'Add'),
                ),
            );
        }
    }

    Widget buildBodyLoading() => Center(
        child: CupertinoActivityIndicator(),
    );

    Widget buildBodyLocked(AppStateModel model) => Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                CupertinoButton(
                    child: const Text('Unlock forever for 1 USD'),
                    color: Styles.primaryColor,
                    onPressed: () => showFeedback('Not available yet'),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: const Text(
                        'one-time payment',
                        style: Styles.hint,
                    ),
                ),
            ],
        ),
    );
}
