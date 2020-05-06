import 'package:uuid/uuid.dart';

class Login implements Comparable<Login> {
    Login({
        id,
        createdAt,
        this.title,
        this.login,
        this.password,
        this.website,
        this.backup2faCodes,
        this.secretQuestions,
        this.secretQuestionsAnswers,
    }) :
        id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

    final String id;
    final DateTime createdAt;
    String title = '';
    String login;
    String password;
    String website;
    List<String> backup2faCodes = [];
    List<String> secretQuestions = [];
    List<String> secretQuestionsAnswers = [];

    @override
    String toString() => '*Login(id: $id)';

    @override
    int compareTo(Login other) {
        int diff;

        diff = title.compareTo(other.title);
        if (diff != 0) return diff;

        diff = login.compareTo(other.login);
        if (diff != 0) return diff;

        return createdAt.compareTo(other.createdAt);
    }

    Login.fromJson(Map<String, dynamic> jsonData) :
        id = jsonData['id'] ?? Uuid().v4(),
        createdAt = DateTime.parse(jsonData['createdAt'] ?? DateTime.now().toString()),
        title = jsonData['title'] ?? '',
        login = jsonData['login'],
        password = jsonData['password'],
        website = jsonData['website'],
        backup2faCodes = (jsonData['backup2faCodes'] ?? []).cast<String>(),
        secretQuestions = (jsonData['secretQuestions'] ?? []).cast<String>(),
        secretQuestionsAnswers = (jsonData['secretQuestionsAnswers'] ?? []).cast<String>();

    Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toString(),
        'title': title,
        'login': login,
        'password': password,
        'website': website,
        'backup2faCodes': backup2faCodes,
        'secretQuestions': secretQuestions,
        'secretQuestionsAnswers': secretQuestionsAnswers,
    };
}
