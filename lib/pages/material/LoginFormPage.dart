import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/helpers/capitalize.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/pages/material/BasePage.dart';
import 'package:provider/provider.dart';

const SECRET_QUESTIONS_EXAMPLES = [
    'Mother\'s maiden name?',
    'Favorite food?',
    'First pet\'s name?',
];

const SECRET_QUESTIONS_ANSWERS_EXAMPLES = [
    'Mozzarella',
    'Nori',
    'iPug',
];

class LoginFormPage extends StatefulWidget {
    final Login item;
    final regexp2FaSplit = new RegExp('[^a-zA-Z0-9\-\_]+');

    LoginFormPage({
        Key key,
        this.item,
    }) : super(key: key);

    @override
    LoginFormPageState createState() => LoginFormPageState();
}

class LoginFormPageState extends BasePageState<LoginFormPage> {
    TextEditingController titleController;
    TextEditingController loginController;
    TextEditingController passwordController;
    TextEditingController websiteController;
    TextEditingController backup2faCodesController;
    List<TextEditingController> secretQuestionsControllers = [];
    List<TextEditingController> secretQuestionsAnswersControllers = [];

    FocusNode titleFocus = FocusNode();
    FocusNode loginFocus = FocusNode();
    FocusNode passwordFocus = FocusNode();
    FocusNode websiteFocus = FocusNode();
    FocusNode backup2faCodesFocus = FocusNode();
    List<FocusNode> secretQuestionsFocuses = [];
    List<FocusNode> secretQuestionsAnswersFocuses = [];

    @override
    void initState() {
        super.initState();

        Login item = widget.item;

        if (item == null) {
            titleController = TextEditingController();
            loginController = TextEditingController();
            passwordController = TextEditingController();
            websiteController = TextEditingController();
            backup2faCodesController = TextEditingController();
        } else {
            titleController = TextEditingController(text: item.title);
            loginController = TextEditingController(text: item.login);
            passwordController = TextEditingController(text: item.password);
            websiteController = TextEditingController(text: item.website);
            backup2faCodesController = TextEditingController(text: item.backup2faCodes.join(', '));

            final questions = widget.item.secretQuestions ?? [];
            final answers = widget.item.secretQuestionsAnswers ?? [];

            for (int index = 0; index < questions.length; ++index) {
                secretQuestionsControllers.add(TextEditingController(text: questions[index]));
                secretQuestionsAnswersControllers.add(TextEditingController(text: answers[index]));

                secretQuestionsFocuses.add(FocusNode());
                secretQuestionsAnswersFocuses.add(FocusNode());
            }
        }
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
    );

    Widget buildAppBar() => AppBar(
        title: widget.item == null ?
            const Text('New login') :
            const Text('Edit login'),
    );

    Widget buildBody() {
        List<Widget> children = [];

        children.add(titleField());
        children.add(loginField());
        children.add(passwordField());
        children.add(websiteField());
        children.add(backup2faCodesField());

        for (int index = 0; index < secretQuestionsControllers.length; ++index) {
            final isLast = index == secretQuestionsControllers.length - 1;
            children.add(secretQuestionField(index, isLast));
            children.add(secretQuestionAnswerField(index, isLast));
        }

        if (widget.item == null) {
            children.add(createButton());
        } else {
            children.add(saveButton());
        }

        children.add(moreActionsButton());

        children.add(Padding(
            key: Key('ListBottomPad'),
            padding: const EdgeInsets.only(top: 30),
        ));

        return ListView(
            padding: const EdgeInsets.all(14),
            children: children,
        );
    }

    void addNewQaRow() {
        setState(() {
            secretQuestionsControllers.add(TextEditingController());
            secretQuestionsAnswersControllers.add(TextEditingController());

            secretQuestionsFocuses.add(FocusNode());
            secretQuestionsAnswersFocuses.add(FocusNode());
        });
    }

    void removeLastQaRow() {
        setState(() {
            secretQuestionsControllers.removeLast();
            secretQuestionsAnswersControllers.removeLast();

            secretQuestionsFocuses.removeLast();
            secretQuestionsAnswersFocuses.removeLast();
        });
    }

    void showMoreActions() {
        List<Widget> children = [];

        children.add(addQaButton());

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

        List<String> backup2faCodes = [];
        List<String> secretQuestions = [];
        List<String> secretQuestionsAnswers = [];

        String raw2FA = backup2faCodesController.text.trim();
        if (raw2FA.length > 0) {
            backup2faCodes = raw2FA.split(widget.regexp2FaSplit);
        }

        for (int index = 0; index < secretQuestionsControllers.length; ++index) {
            final question = secretQuestionsControllers[index].text.trim();
            final answer = secretQuestionsAnswersControllers[index].text.trim();

            if (question.length > 0 || answer.length > 0) {
                secretQuestions.add(question);
                secretQuestionsAnswers.add(answer);
            }
        }

        widget.item.title = titleText;
        widget.item.login = loginController.text.trim();
        widget.item.password = passwordController.text;
        widget.item.website = websiteController.text.trim();
        widget.item.backup2faCodes = backup2faCodes;
        widget.item.secretQuestions = secretQuestions;
        widget.item.secretQuestionsAnswers = secretQuestionsAnswers;

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        await model.saveLogin(widget.item);

        Navigator.of(context).pop();
    }

    Future<void> deleteItemConfirmed() async {
        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        await model.deleteLogin(widget.item);

        Navigator.of(context).pop();
    }

    void deleteItem() {
        final title = titleController.text.trim() ?? widget.item.title;
        final login = loginController.text.trim() ?? widget.item.login;

        final message = (title.length > 0 && login.length > 0) ?
            '$title: $login' :
            (title.length > 0) ? title :
            (login.length > 0) ? login : 'Empty item';

        confirm(
            title: 'Delete?',
            message: message,
            isAcceptCritical: true,
            onAccept: deleteItemConfirmed,
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

        List<String> backup2faCodes = [];
        List<String> secretQuestions = [];
        List<String> secretQuestionsAnswers = [];

        String raw2FA = backup2faCodesController.text.trim();
        if (raw2FA.length > 0) {
            backup2faCodes = raw2FA.split(widget.regexp2FaSplit);
        }

        for (int index = 0; index < secretQuestionsControllers.length; ++index) {
            final question = secretQuestionsControllers[index].text.trim();
            final answer = secretQuestionsAnswersControllers[index].text.trim();

            if (question.length > 0 || answer.length > 0) {
                secretQuestions.add(question);
                secretQuestionsAnswers.add(answer);
            }
        }

        Login item = Login(
            title: capitalize(titleText),
            login: loginController.text.trim(),
            password: passwordController.text,
            website: websiteController.text.trim(),
            backup2faCodes: backup2faCodes,
            secretQuestions: secretQuestions,
            secretQuestionsAnswers: secretQuestionsAnswers,
        );

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);

        await model.addLogin(item);

        Navigator.of(context).pop();
    }

    Widget titleField() => TextFormField(
        key: Key('TitleField'),
        controller: titleController,
        focusNode: titleFocus,
        decoration: InputDecoration(
            labelText: 'Title',
            hasFloatingPlaceholder: true,
            counter: fieldCounter('Service name', false),
            contentPadding: fieldPadding(false),
        ),
        style: const TextStyle(fontSize: 18),
        keyboardType: TextInputType.text,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 1,
        maxLines: 3,
    );

    Widget loginField() => TextFormField(
        key: Key('LoginField'),
        controller: loginController,
        focusNode: loginFocus,
        decoration: InputDecoration(
            labelText: 'Login',
            hasFloatingPlaceholder: true,
            counter: fieldCounter('Username or email', false),
            contentPadding: fieldPadding(false),
        ),
        style: const TextStyle(fontSize: 18),
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 1,
        maxLines: 3,
    );

    Widget passwordField() => TextFormField(
        key: Key('PasswordField'),
        controller: passwordController,
        focusNode: passwordFocus,
        decoration: InputDecoration(
            labelText: 'Password',
            hasFloatingPlaceholder: true,
            counter: fieldCounter('Generate', false),
            contentPadding: fieldPadding(false),
        ),
        style: const TextStyle(fontSize: 18),
        keyboardType: TextInputType.visiblePassword,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 1,
        maxLines: 3,
        // replace letters with dots:
        // obscureText: true,
    );

    Widget websiteField() {
        final input = TextFormField(
            key: Key('WebsiteField'),
            controller: websiteController,
            focusNode: websiteFocus,
            decoration: InputDecoration(
                labelText: 'Website',
                hasFloatingPlaceholder: true,
                counter: fieldCounter('Service url, ex. google.com', true),
                contentPadding: fieldPadding(true),
            ),
            style: const TextStyle(fontSize: 18),
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            minLines: 1,
            maxLines: 3,
        );

        return Stack(
            key: Key('WebsiteRow'),
            alignment: Alignment.topRight,
            children: [
                input,
                openWebsiteButton(),
            ],
        );
    }

    Widget backup2faCodesField() => TextFormField(
        key: Key('Backup2faCodesField'),
        controller: backup2faCodesController,
        focusNode: backup2faCodesFocus,
        decoration: InputDecoration(
            labelText: '2FA backup codes',
            hasFloatingPlaceholder: true,
            counter: fieldCounter('If authenticator app is lost', false),
            contentPadding: fieldPadding(false),
        ),
        style: const TextStyle(fontSize: 18),
        keyboardType: TextInputType.text,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 1,
        maxLines: 3,
    );

    Widget secretQuestionField(int index, bool isLast) {
        final input = TextFormField(
            key: Key('SecretQuestionField $index'),
            controller: secretQuestionsControllers[index],
            focusNode: secretQuestionsFocuses[index],
            decoration: InputDecoration(
                labelText: 'Secret question ${index + 1}',
                hasFloatingPlaceholder: true,
                counter: fieldCounter(SECRET_QUESTIONS_EXAMPLES[index % 3], isLast),
                contentPadding: fieldPadding(isLast),
            ),
            style: const TextStyle(fontSize: 18),
            keyboardType: TextInputType.text,
            autocorrect: false,
            enableSuggestions: false,
            minLines: 1,
            maxLines: 3,
        );

        if (!isLast) {
            return input;
        } else {
            return Stack(
                key: Key('SecretQuestionRow $index'),
                alignment: Alignment.topRight,
                children: [
                    input,
                    removeQaButton(),
                ],
            );
        }
    }

    Widget secretQuestionAnswerField(int index, bool isLast) {
        final input = TextFormField(
            key: Key('SecretQuestionAnswerField $index'),
            controller: secretQuestionsAnswersControllers[index],
            focusNode: secretQuestionsAnswersFocuses[index],
            decoration: InputDecoration(
                labelText: 'Secret question\'s answer ${index + 1}',
                hasFloatingPlaceholder: true,
                counter: fieldCounter(SECRET_QUESTIONS_ANSWERS_EXAMPLES[index % 3], isLast),
                contentPadding: fieldPadding(isLast),
            ),
            style: const TextStyle(fontSize: 18),
            keyboardType: TextInputType.text,
            autocorrect: false,
            enableSuggestions: false,
            minLines: 1,
            maxLines: 3,
        );

        if (!isLast) {
            return input;
        } else {
            return Stack(
                key: Key('SecretQuestionAnswerRow $index'),
                alignment: Alignment.topRight,
                children: [
                    input,
                    removeQaButton(),
                ],
            );
        }
    }

    Widget fieldCounter(String text, bool withSuffixButton) => Container(
        transform: Matrix4.translationValues(withSuffixButton ? 42 : 2, -4, 0),
        child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    );

    EdgeInsets fieldPadding(bool withSuffixButton) => withSuffixButton ?
        const EdgeInsets.fromLTRB(2, 8, 42, 8) :
        const EdgeInsets.fromLTRB(2, 8, 2, 8);

    Widget removeQaButton() => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: IconButton(
            color: Colors.black87,
            onPressed: removeLastQaRow,
            tooltip: 'Remove',
            icon: const Icon(Icons.close),
        ),
    );

    Widget openWebsiteButton() => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: IconButton(
            color: Colors.black87,
            onPressed: () => openUrl(websiteController.text.trim()),
            tooltip: 'Open',
            icon: const Icon(Icons.open_in_new),
        ),
    );

    Widget addQaButton() => Padding(
        key: Key('AddQaButton'),
        padding: EdgeInsets.zero,
        child: FlatButton.icon(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 28),
            onPressed: () {
                Navigator.of(context).pop();
                addNewQaRow();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add secret question & answer'),
        ),
    );

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
        padding: const EdgeInsets.only(top: 5),
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
