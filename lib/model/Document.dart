import 'package:uuid/uuid.dart';

class Document implements Comparable<Document> {
    Document({
        id,
        createdAt,
        this.title = '',
        this.note = '',
    }) :
        id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

    final String id;
    final DateTime createdAt;
    String title;
    String note;

    @override
    String toString() => '*Document(id: $id)';

    @override
    int compareTo(Document other) {
        int diff;

        diff = title.compareTo(other.title);
        if (diff != 0) return diff;

        diff = note.compareTo(other.note);
        if (diff != 0) return diff;

        return createdAt.compareTo(other.createdAt);
    }

    Document.fromJson(Map<String, dynamic> jsonData) :
        id = jsonData['id'] ?? Uuid().v4(),
        createdAt = DateTime.parse(jsonData['createdAt'] ?? DateTime.now().toString()),
        title = jsonData['title'] ?? '',
        note = jsonData['note'] ?? '';

    Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toString(),
        'title': title,
        'note': note,
    };
}
