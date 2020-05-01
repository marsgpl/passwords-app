import 'package:flutter/material.dart';
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
    Widget build(BuildContext context) => Center(
        child: const Text('bank cards here'),
    );
}
