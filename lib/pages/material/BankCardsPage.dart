import 'package:flutter/material.dart';
import 'package:passwords/PwdIcons.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';

class BankCardsPage extends StatefulWidget {
    @override
    BankCardsPageState createState() => BankCardsPageState();
}

class BankCardsPageState extends State<BankCardsPage> {
    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initBankCards();
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
    );

    Widget buildAppBar() => AppBar(
        title: const Text('Bank cards'),
    );

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            // if (!model.bankCardsInited) {
            //     return buildBodyLoading();
            // } else {
                return buildBodyNotImplemented();
            // }
        }
    );

    Widget buildBodyLoading() => const Center(
        child: const CircularProgressIndicator(),
    );

    Widget buildBodyNotImplemented() => Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const Icon(PwdIcons.bank_card, color: Colors.grey, size: 60),
                const Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text('Bank cards',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                ),
                const Text('Not implemented yet'),
                const Text('Wait for updates'),
            ],
        ),
    );
}
