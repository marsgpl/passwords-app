import 'package:uuid/uuid.dart';

class BankCard implements Comparable<BankCard> {
    BankCard({
        id,
        createdAt,
        this.title,
        this.number,
        this.csv,
        this.expiresAt,
        this.owner,
    }) :
        id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

    final String id;
    final DateTime createdAt;
    String title;
    String number;
    int csv;
    DateTime expiresAt;
    String owner;

    @override
    String toString() => '*BankCard(id: $id)';

    @override
    int compareTo(BankCard other) {
        int diff;

        diff = title.compareTo(other.title);
        if (diff != 0) return diff;

        diff = number.compareTo(other.number);
        if (diff != 0) return diff;

        return createdAt.compareTo(other.createdAt);
    }

    BankCard.fromJson(Map<String, dynamic> jsonData) :
        id = jsonData['id'],
        createdAt = DateTime.parse(jsonData['createdAt']),
        title = jsonData['title'],
        number = jsonData['number'],
        csv = jsonData['csv'],
        expiresAt = DateTime.parse(jsonData['expiresAt']),
        owner = jsonData['owner'];

    Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toString(),
        'title': title,
        'number': number,
        'csv': csv,
        'expiresAt': expiresAt.toString(),
        'owner': owner,
    };
}
