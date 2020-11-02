import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:wasteagram/models/food_waste_post.dart';
import '../components/size_helpers.dart';

class DetailScreen extends StatelessWidget {
  final FoodWastePost fwp;
  DetailScreen({Key key, this.fwp}) : super(key: key);

  static const routeName = 'detail';
  final DateFormat formatter = DateFormat('EEEE - MMM d');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Wasteagram')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
                flex: 1,
                child: Semantics(
                  label: 'Date that post was submitted',
                  value: '${formatter.format(fwp.time.toDate())}',
                  hint: 'Post date',
                  button: false,
                  child: Text(formatter.format(fwp.time.toDate()),
                      style: TextStyle(fontSize: 24)),
                )),
            Expanded(
              flex: 5,
              child: Semantics(
                  label: 'Image associated with post',
                  value: '${fwp.url}',
                  hint: 'Post image',
                  button: false,
                  child: Container(
                      height: displayHeight(context) * 0.3,
                      width: double.infinity,
                      child: Image.network(fwp.url, loadingBuilder:
                          (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                            child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ));
                      }))),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
                flex: 2,
                child: Semantics(
                  label: 'Quantity of waste items associated with post',
                  value: '${fwp.quantity.toString()}',
                  hint: 'Post quantity',
                  button: false,
                  child: Container(
                      child: Text('Quantity: ${fwp.quantity.toString()}',
                          style: TextStyle(fontSize: 24))),
                )),
            Expanded(
                flex: 1,
                child: Semantics(
                  label: 'Latitude and Longitude of user when post was made',
                  value:
                      'Latitude: ${fwp.latitude}, Longitude: ${fwp.longitude}',
                  hint: 'Post coordinates',
                  button: false,
                  child: Container(
                    child: Text('(${fwp.latitude},\t ${fwp.longitude})',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                  ),
                ))
          ]),
        ));
  }
}
