import 'package:flutter/material.dart';
import 'package:passwords/PwdIcons.dart';
import 'package:provider/provider.dart';
import 'package:passwords/model/AppStateModel.dart';

class DocumentsPage extends StatefulWidget {
    @override
    DocumentsPageState createState() => DocumentsPageState();
}

class DocumentsPageState extends State<DocumentsPage> {
    @override
    void initState() {
        super.initState();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        model.initDocuments();
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
    );

    Widget buildAppBar() => AppBar(
        title: const Text('Documents'),
    );

    Widget buildBody() => Consumer<AppStateModel>(
        builder: (context, model, consumer) {
            // if (!model.documentsInited) {
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
                const Icon(PwdIcons.document, color: Colors.grey, size: 60),
                Container(height: 10),
                const Text('Documents',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Container(height: 10),
                const Text('Not implemented yet'),
                const Text('Wait for updates'),
            ],
        ),
    );
}
