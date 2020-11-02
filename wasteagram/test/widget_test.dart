import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_waste_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Post created from Map should have the appropriate values', () {
    final time = Timestamp.now();
    const url = 'FAKE';
    const quantity = 1;
    const latitude = 1.0;
    const longitude = 1.0;

    // Subject of test
    final fwp = FoodWastePost.fromMap({
      'time': time,
      'url': url,
      'quantity': quantity,
      'latitude': latitude,
      'longitude': longitude
    });

    // Verify
    expect(fwp.time, time);
    expect(fwp.url, url);
    expect(fwp.quantity, quantity);
    expect(fwp.latitude, latitude);
    expect(fwp.longitude, longitude);
  });
}
