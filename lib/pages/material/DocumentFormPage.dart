import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/helpers/capitalize.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/model/Document.dart';
import 'package:passwords/pages/material/BasePage.dart';

const LIST_PADDING = 14.0;
const LIST_ITEM_TEXT_STYLE = const TextStyle(fontSize: 18);

class DocumentFormPage extends StatefulWidget {
    final Document item;

    DocumentFormPage({
        Key key,
        this.item,
    }) : super(key: key);

    @override
    DocumentFormPageState createState() => DocumentFormPageState();
}

class DocumentFormPageState extends BasePageState<DocumentFormPage> {
    TextEditingController titleController;
    TextEditingController noteController;

    FocusNode titleFocus;
    FocusNode noteFocus;

    @override
    void initState() {
        super.initState();

        titleFocus = FocusNode();
        noteFocus = FocusNode();

        Document item = widget.item;

        if (item == null) {
            titleController = TextEditingController();
            noteController = TextEditingController();
        } else {
            titleController = TextEditingController(text: item.title);
            noteController = TextEditingController(text: item.note);
        }
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: Builder(
            builder: buildBody,
        ),
    );

    Widget buildAppBar() => AppBar(
        title: widget.item == null ?
            const Text('New document') :
            const Text('Edit document'),
    );

    Widget buildBody(BuildContext context) {
        List<Widget> children = [];

        children.add(titleField());
        children.add(noteField());

        if (widget.item == null) {
            children.add(createButton());
        } else {
            children.add(saveButton());
        }

        children.add(moreActionsButton());

        children.add(Container(
            key: Key('ListBottomPad'),
            height: 30,
        ));

        return ListView(
            semanticChildCount: children.length,
            padding: const EdgeInsets.all(LIST_PADDING),
            children: children,
        );
    }

    void showMoreActions() {
        List<Widget> children = [];

        // children.add(addCustomFieldButton());

        if (widget.item != null) {
            children.add(deleteButton());
        }

        showModalBottomSheet(
            context: context,
            builder: (context) => Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                color: Colors.white,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                ),
            ),
        );
    }

    Future<void> saveChanges() async {
        String titleText = titleController.text.trim();

        if (titleText.length == 0) {
            return alert(
                title: 'Not saved',
                message: 'Title is empty',
            );
        }

        widget.item.title = titleText;
        widget.item.note = noteController.text.trim();

        final model = Provider.of<AppStateModel>(context, listen: false);

        await model.saveDocument(widget.item);

        Navigator.of(context).pop();
    }

    Future<void> deleteItemConfirmed() async {
        final model = Provider.of<AppStateModel>(context, listen: false);

        await model.deleteDocument(widget.item);

        Navigator.of(context).pop();
    }

    void deleteItem() {
        final title = titleController.text.trim() ?? widget.item.title;
        final note = noteController.text.trim() ?? widget.item.note;

        final message = (title.length > 0 && note.length > 0) ?
            '$title\n$note' :
            (title.length > 0) ? title :
            (note.length > 0) ? note : 'Empty item';

        confirm(
            title: 'Delete?',
            message: message,
            isAcceptCritical: true,
            onAccept: deleteItemConfirmed,
            messageMaxLines: 4,
        );
    }

    Future<void> createItem() async {
        String titleText = titleController.text.trim();

        if (titleText.length == 0) {
            return alert(
                title: 'Not created',
                message: 'Title is empty',
            );
        }

        final item = Document(
            title: capitalize(titleText),
            note: noteController.text.trim(),
        );

        final model = Provider.of<AppStateModel>(context, listen: false);

        await model.addDocument(item);

        Navigator.of(context).pop();
    }

    Widget titleField() => TextFormField(
        key: Key('titleField'),
        controller: titleController,
        focusNode: titleFocus,
        decoration: InputDecoration(
            labelText: 'Title',
            counter: fieldCounter('Document name', false),
            contentPadding: fieldPadding(false),
        ),
        style: LIST_ITEM_TEXT_STYLE,
        keyboardType: TextInputType.text,
        keyboardAppearance: Brightness.light,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 1,
        maxLines: 3,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String value) => FocusScope.of(context).unfocus(),
    );

    Widget noteField() => TextFormField(
        key: Key('noteField'),
        controller: noteController,
        focusNode: noteFocus,
        decoration: InputDecoration(
            labelText: 'Note',
            counter: fieldCounter('Description', false),
            contentPadding: fieldPadding(false),
        ),
        style: LIST_ITEM_TEXT_STYLE,
        keyboardType: TextInputType.emailAddress,
        keyboardAppearance: Brightness.light,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 1,
        maxLines: 3,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String value) => FocusScope.of(context).unfocus(),
    );

    Widget fieldCounter(String text, bool withSuffixButton) => Container(
        transform: Matrix4.translationValues(withSuffixButton ? 42 : 2, -4, 0),
        child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    );

    EdgeInsets fieldPadding(bool withSuffixButton) => withSuffixButton ?
        const EdgeInsets.fromLTRB(2, 8, 42, 8) :
        const EdgeInsets.fromLTRB(2, 8, 2, 8);

    Widget createButton() => Padding(
        key: Key('CreateButton'),
        padding: const EdgeInsets.only(top: 20),
        child: FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 28),
            onPressed: createItem,
            child: const Text('Create'),
            color: PRIMARY_COLOR,
            textColor: Colors.white,
        ),
    );

    Widget saveButton() => Padding(
        key: Key('SaveButton'),
        padding: const EdgeInsets.only(top: 20),
        child: FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 28),
            onPressed: saveChanges,
            child: const Text('Save'),
            color: PRIMARY_COLOR,
            textColor: Colors.white,
        ),
    );

    Widget moreActionsButton() => Padding(
        key: Key('MoreActionsButton'),
        padding: const EdgeInsets.only(top: 8),
        child: FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 28),
            onPressed: showMoreActions,
            child: const Text('More'),
        ),
    );

    Widget deleteButton() => Padding(
        key: Key('DeleteButton'),
        padding: const EdgeInsets.only(top: 5),
        child: FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 28),
            onPressed: () {
                Navigator.of(context).pop();
                deleteItem();
            },
            child: const Text('Delete'),
            textColor: Colors.red,
        ),
    );
}
