import 'package:flutter/cupertino.dart';
import 'package:passwords/Styles@cupertino.dart';

const double PAD = 10;

Widget loginFormRow({
    TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String title,
    String description,
    bool isFirst = false,
}) {
    FocusNode focusNode = FocusNode();

    Widget label = GestureDetector(
        onTap: focusNode.requestFocus,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, PAD, 0, 0),
            child: Text(title, style: Styles.inputLabel),
        ),
    );

    CupertinoTextField textField = CupertinoTextField(
        focusNode: focusNode,
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        placeholder: description,
        keyboardType: keyboardType,
        padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
        ),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0,
                    color: CupertinoColors.inactiveGray,
                ),
            ),
        ),
    );

    return Container(
        padding: isFirst ?
            const EdgeInsets.fromLTRB(PAD, PAD, PAD, PAD / 2) :
            const EdgeInsets.fromLTRB(PAD, 0,   PAD, PAD / 2),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                label,
                textField,
            ],
        ),
    );
}

Widget loginFormAdd(Function callback) => Padding(
    padding: const EdgeInsets.all(PAD),
    child: CupertinoButton(
        child: const Text('Create'),
        color: Styles.primaryColor,
        onPressed: callback,
    ),
);

Widget loginFormSave(Function callback) => Padding(
    padding: const EdgeInsets.fromLTRB(PAD, PAD, PAD, 0),
    child: CupertinoButton(
        child: const Text('Save'),
        color: Styles.primaryColor,
        onPressed: callback,
    ),
);

Widget loginFormMoar(Function callback) => Padding(
    padding: const EdgeInsets.only(bottom: PAD),
    child: CupertinoButton(
        child: const Text('more', style: Styles.notImportantChoice),
        onPressed: callback,
    ),
);

Widget loginForm({
    String pageTitle,
    TextEditingController title,
    TextEditingController login,
    TextEditingController password,
    TextEditingController website,
    Function onAdd,
    Function onSave,
    Function onMoar,
}) {
    int childCount = onAdd != null ? 5 : 6;

    return CustomScrollView(
        semanticChildCount: childCount,
        slivers: [
            SliverSafeArea(
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                        switch (index) {
                            case 0: return loginFormRow(
                                controller: title,
                                title: 'Title',
                                description: 'Service name',
                                isFirst: true,
                            );
                            case 1: return loginFormRow(
                                controller: login,
                                keyboardType: TextInputType.emailAddress,
                                title: 'Login',
                                description: 'Username or email',
                            );
                            case 2: return loginFormRow(
                                controller: password,
                                keyboardType: TextInputType.visiblePassword,
                                title: 'Password',
                                description: '··········',
                            );
                            case 3: return loginFormRow(
                                controller: website,
                                keyboardType: TextInputType.url,
                                title: 'Website',
                                description: 'Service url',
                            );
                            case 4: return onAdd != null ?
                                loginFormAdd(onAdd) :
                                loginFormSave(onSave);
                            case 5: return onAdd != null ?
                                null :
                                loginFormMoar(onMoar);
                            default: return null;
                        }
                    }, childCount: childCount),
                ),
            ),
        ],
    );
}
