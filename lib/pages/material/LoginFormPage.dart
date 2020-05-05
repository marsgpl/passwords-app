import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwords/helpers/generateRandomPassword.dart';
import 'package:provider/provider.dart';
import 'package:passwords/constants.dart';
import 'package:passwords/helpers/capitalize.dart';
import 'package:passwords/model/AppStateModel.dart';
import 'package:passwords/model/Login.dart';
import 'package:passwords/pages/material/BasePage.dart';

const INPUT_ROW_HEIGHT = 76.5;
const LIST_PADDING = 14.0;
const LIST_ITEM_TEXT_STYLE = const TextStyle(fontSize: 18);

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

    FocusNode titleFocus;
    FocusNode loginFocus;
    FocusNode passwordFocus;
    FocusNode websiteFocus;
    FocusNode backup2faCodesFocus;
    List<FocusNode> secretQuestionsFocuses = [];
    List<FocusNode> secretQuestionsAnswersFocuses = [];

    bool isPasswordFocused = false;
    bool isWebsiteEnabled = false;
    double viewportWidth;
    bool useSpecialSymbolsInGeneratedPasswords;

    double getViewportWidth() {
        if (viewportWidth == null) {
            viewportWidth = MediaQuery.of(context).size.width;
        }

        return viewportWidth;
    }

    @override
    void initState() {
        super.initState();

        titleFocus = FocusNode();
        loginFocus = FocusNode();
        passwordFocus = FocusNode();
        websiteFocus = FocusNode();
        backup2faCodesFocus = FocusNode();

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

        passwordFocus.addListener(onPasswordFocusChange);
        websiteController.addListener(onWebsiteChange);

        isWebsiteEnabled = websiteHasText();

        AppStateModel model = Provider.of<AppStateModel>(context, listen: false);
        useSpecialSymbolsInGeneratedPasswords =
            model.settings.settings.useSpecialSymbolsInGeneratedPasswords;
    }

    void onPasswordFocusChange() {
        if (isPasswordFocused != passwordFocus.hasFocus) {
            setState(() {
                isPasswordFocused = passwordFocus.hasFocus;
            });
        }
    }

    bool websiteHasText() => websiteController.text.trim().length > 0;

    void onWebsiteChange() {
        final isWebsiteEnabledCurrent = websiteHasText();

        if (isWebsiteEnabled != isWebsiteEnabledCurrent) {
            setState(() {
                isWebsiteEnabled = isWebsiteEnabledCurrent;
            });
        }
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(),
        body: Builder(
            builder: (context) => buildBody(context),
        ),
    );

    Widget buildAppBar() => AppBar(
        title: widget.item == null ?
            const Text('New login') :
            const Text('Edit login'),
    );

    Widget buildBody(BuildContext context) {
        List<Widget> children = [];

        children.add(titleField());
        children.add(loginField());

        children.add(Container(
            key: Key('PasswordWebsiteRowHack'),
            height: INPUT_ROW_HEIGHT * 2,
            child: Stack(
                children: [
                    websiteField(),
                    passwordField(context),
                ],
            ),
        ));

        children.add(backup2faCodesField());

        for (int index = 0; index < secretQuestionsControllers.length; ++index) {
            final isLast = index == secretQuestionsControllers.length - 1;

            children.add(secretQuestionField(index, isLast));
            children.add(secretQuestionAnswerField(index));
        }

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

    Widget passwordField(BuildContext context) {
        final input = TextFormField(
            key: Key('PasswordField'),
            controller: passwordController,
            focusNode: passwordFocus,
            decoration: InputDecoration(
                labelText: 'Password',
                hasFloatingPlaceholder: true,
                counter: fieldCounter('Configure generator in settings', false),
                contentPadding: fieldPadding(false),
            ),
            style: LIST_ITEM_TEXT_STYLE,
            keyboardType: TextInputType.visiblePassword,
            keyboardAppearance: Brightness.light,
            autocorrect: false,
            enableSuggestions: false,
            minLines: 1,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (String value) => FocusScope.of(context).unfocus(),
            // replace letters with dots:
            // obscureText: true,
        );

        final passwordGeneratorPanel = isPasswordFocused ? Container(
            key: Key('PasswordGeneratorField'),
            transform: Matrix4.translationValues(0, 57, 0),
            decoration: BoxDecoration(
                color: const Color(0xEE282828),
                // border: Border.all(width: .5, color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
            ),
            child: ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                buttonPadding: EdgeInsets.zero,
                children: [
                    FlatButton.icon(
                        key: Key('GeneratePassword'),
                        padding: const EdgeInsets.all(13),
                        label: const Text('Generate'),
                        icon: const Icon(Icons.refresh),
                        onPressed: () => setState(() {
                            passwordController.text = generateRandomPassword(
                                length: 20,
                                useSpecialSymbols: useSpecialSymbolsInGeneratedPasswords,
                            );
                        }),
                        textColor: Colors.white,
                    ),
                    FlatButton.icon(
                        key: Key('CopyPassword'),
                        padding: const EdgeInsets.all(13),
                        label: const Text('Copy'),
                        icon: const Icon(Icons.content_copy),
                        onPressed: () {
                            Clipboard.setData(ClipboardData(text: passwordController.text));
                            snack(message: 'Password copied', context: context);
                            FocusScope.of(context).unfocus();
                        },
                        textColor: Colors.white,
                    ),
                ],
            ),
        ) : Container();

        return Positioned(
            key: Key('PasswordFieldRow'),
            width: getViewportWidth() - LIST_PADDING * 2,
            top: 0,
            left: 0,
            height: INPUT_ROW_HEIGHT * 2,
            child: Stack(
                children: [
                    input,
                    passwordGeneratorPanel,
                ],
            ),
        );
    }

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
            style: LIST_ITEM_TEXT_STYLE,
            keyboardType: TextInputType.url,
            keyboardAppearance: Brightness.light,
            autocorrect: false,
            enableSuggestions: false,
            minLines: 1,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (String value) => FocusScope.of(context).unfocus(),
        );

        return Positioned(
            key: Key('WebsiteFieldRow'),
            width: getViewportWidth() - LIST_PADDING * 2,
            top: INPUT_ROW_HEIGHT,
            left: 0,
            height: INPUT_ROW_HEIGHT,
            child: Stack(
                alignment: Alignment.topRight,
                children: [
                    input,
                    openWebsiteButton(),
                ],
            ),
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
        style: LIST_ITEM_TEXT_STYLE,
        keyboardType: TextInputType.text,
        keyboardAppearance: Brightness.light,
        autocorrect: false,
        enableSuggestions: false,
        minLines: 1,
        maxLines: 3,
        // textInputAction: TextInputAction.newline,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String value) => FocusScope.of(context).unfocus(),
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

    Widget secretQuestionAnswerField(int index) => TextFormField(
        key: Key('SecretQuestionAnswerField $index'),
        controller: secretQuestionsAnswersControllers[index],
        focusNode: secretQuestionsAnswersFocuses[index],
        decoration: InputDecoration(
            labelText: 'Secret question\'s answer ${index + 1}',
            hasFloatingPlaceholder: true,
            counter: fieldCounter(SECRET_QUESTIONS_ANSWERS_EXAMPLES[index % 3], false),
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

    Widget fieldCounter(String text, bool withSuffixButton) => Container(
        transform: Matrix4.translationValues(withSuffixButton ? 42 : 2, -4, 0),
        child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    );

    EdgeInsets fieldPadding(bool withSuffixButton) => withSuffixButton ?
        const EdgeInsets.fromLTRB(2, 8, 42, 8) :
        const EdgeInsets.fromLTRB(2, 8, 2, 8);

    Widget removeQaButton() => Padding(
        key: Key('RemoveQaButton'),
        padding: const EdgeInsets.only(top: 5),
        child: IconButton(
            color: PRIMARY_COLOR,
            onPressed: removeLastQaRow,
            tooltip: 'Remove',
            icon: const Icon(Icons.close),
        ),
    );

    Widget openWebsiteButton() => Padding(
        key: Key('OpenWebsiteButton'),
        padding: const EdgeInsets.only(top: 5),
        child: IconButton(
            color: isWebsiteEnabled ?
                PRIMARY_COLOR :
                Colors.black38,
            onPressed: isWebsiteEnabled ?
                () => openUrl(websiteController.text.trim()) :
                null,
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
