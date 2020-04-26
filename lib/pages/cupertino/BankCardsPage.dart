import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/Styles@cupertino.dart';

class BankCardsPage extends StatefulWidget {
    @override
    BankCardsPageState createState() => BankCardsPageState();
}

class BankCardsPageState extends State<BankCardsPage> {
    bool inited = false;
    bool locked = true;

    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initBankCards();
    }

    @override
    didChangeDependencies() {
        super.didChangeDependencies();

        AppStateModel model = Provider.of<AppStateModel>(context);

        bool unlocked = model.bankCards.settings['unlocked'];

        if (!inited && model.bankCardsInited) {
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
                    if (!model.bankCardsInited) {
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
                    onPressed: model.unlockBankCardsPage,
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
