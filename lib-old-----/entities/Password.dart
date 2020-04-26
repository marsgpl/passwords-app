import 'dart:convert';

class Password implements Comparable<Password> {
    String id;
    DateTime createdAt;
    String title;
    String login;
    String email;
    String phone;
    String password;

    Password({
        this.id,
        this.createdAt,
        this.title,
        this.login,
        this.email,
        this.phone,
        this.password,
    });

    String subtitle() {
        return
            login != null && login.length > 0 ? login :
            email != null && email.length > 0 ? email :
            phone != null && phone.length > 0 ? phone : '';
    }

    String toJson() => json.encode({
        'createdAt': createdAt.toString(),
        'title': title,
        'login': login,
        'email': email,
        'phone': phone,
        'password': password,
    });

    @override
    int compareTo(Password other) {
        int diff;

        diff = title.compareTo(other.title);
        if (diff != 0) return diff;

        diff = login.compareTo(other.login);
        if (diff != 0) return diff;

        diff = email.compareTo(other.email);
        if (diff != 0) return diff;

        diff = phone.compareTo(other.phone);
        if (diff != 0) return diff;

        return createdAt.compareTo(other.createdAt);
    }
}
