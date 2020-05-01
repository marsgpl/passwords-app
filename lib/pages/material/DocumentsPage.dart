import 'package:flutter/material.dart';
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
    Widget build(BuildContext context) => Center(
        child: const Text('docs here'),
    );
}
