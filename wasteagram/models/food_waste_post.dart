import 'package:cloud_firestore/cloud_firestore.dart';

class FoodWastePost {
  String url;
  double latitude;
  double longitude;
  Timestamp time;
  int quantity;

  FoodWastePost(
      {this.url, this.latitude, this.longitude, this.time, this.quantity});

  factory FoodWastePost.fromJSON(Map<String, dynamic> json) {
    return FoodWastePost(
        url: json['url'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        time: json['time'],
        quantity: json['quantity']);
  }
  factory FoodWastePost.fromMap(Map post) => FoodWastePost(
        url: post['url'],
        latitude: post['latitude'],
        longitude: post['longitude'],
        time: post['time'],
        quantity: post['quantity'],
      );
}
