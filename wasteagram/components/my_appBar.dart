import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String name;
  CustomAppBar({Key key, @required this.name})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);
  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: StreamBuilder(
            stream: Firestore.instance.collection('foodWastePosts').snapshots(),
            builder: (content, snapshot) {
              int itemCount = 0;
              if (snapshot.hasData) {
                snapshot.data.documents.forEach((item) {
                  itemCount += item['quantity'];
                });
                return Semantics(
                    label: 'Sum total of wasted items',
                    value: '$itemCount',
                    hint: 'Sum',
                    button: false,
                    child: Text('${widget.name} $itemCount'));
              }
              return Semantics(
                  label: 'Sum total of wasted items',
                  value: '$itemCount',
                  hint: 'Sum',
                  button: false,
                  child: Text('${widget.name} $itemCount'));
            }));
  }
}
