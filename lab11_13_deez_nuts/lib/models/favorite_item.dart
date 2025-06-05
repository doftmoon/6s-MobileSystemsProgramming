import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteItem {
  final String userId;
  final String itemId;
  final DateTime favoritedAt;
  final String? itemName;

  FavoriteItem({
    required this.userId,
    required this.itemId,
    required this.favoritedAt,
    this.itemName,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      userId: json['userId'] as String,
      itemId: json['itemId'] as String,
      favoritedAt: (json['favoritedAt'] as Timestamp).toDate(),
      itemName: json['itemName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'itemId': itemId,
      'favoritedAt': favoritedAt,
      'itemName': itemName,
    };
  }
}
