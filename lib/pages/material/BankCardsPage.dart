import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:passwords/widgets/PageMessage.dart';
import 'package:passwords/PwdIcons.dart';
import 'package:passwords/widgets/NewItemArrowPainter.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/helpers/Debouncer.dart';
import 'package:passwords/pages/material/BasePage.dart';
// import 'package:passwords/pages/material/BankCardFormPage.dart';
import 'package:passwords/model/BankCard.dart';

class BankCardsPage extends StatefulWidget {
    @override
    BankCardsPageState createState() => BankCardsPageState();
}

class BankCardsPageState extends BasePageState<BankCardsPage> {
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
                return buildBodyNoItems();
            // }
        }
    );

    Widget buildBodyLoading() => const Center(
        child: const CircularProgressIndicator(),
    );

    Widget buildBodyNoItems() => Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
            FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 0.5,
                child: Container(
                    child: CustomPaint(
                        painter: NewItemArrowPainter('Add new card'),
                    ),
                ),
            ),
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(PwdIcons.bank_card, color: Colors.black26, size: 60),
                        PageMessage.paragraph('Debit or credit cards\nCustomer cards'),
                    ],
                ),
            ),
        ],
    );
}
