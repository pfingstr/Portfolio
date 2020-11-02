import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wasteagram/screens/detail_screen.dart';
import 'package:wasteagram/screens/new_post_screen.dart';
import '../components/my_appBar.dart';
import '../models/food_waste_post.dart';

class HomeScreen extends StatefulWidget {
  @override
  static const routeName = '/';
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File _image;
  final picker = ImagePicker();
  //source https://stackoverflow.com/questions/16126579/how-do-i-format-a-date-with-dart
  final DateFormat formatter = DateFormat('EEEE - MMM d');

  @override
  void initState() {
    super.initState();
  }

  void viewTile(BuildContext content, dynamic post) {
    final fwp = FoodWastePost.fromMap({
      'time': post['time'],
      'url': post['url'],
      'quantity': post['quantity'],
      'latitude': post['latitude'],
      'longitude': post['longitude']
    });

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailScreen(fwp: fwp)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(name: 'Wasteagram'),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Semantics(
            label: 'Add new post',
            hint: 'New post',
            button: true,
            child: FloatingActionButton(
                child: Icon(Icons.camera_alt),
                onPressed: () {
                  _showSelectionDialog(context);
                })),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('foodWastePosts')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (content, snapshot) {
              if (snapshot.hasData && snapshot.data.documents.length > 0) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            var post = snapshot.data.documents[index];
                            return ListTile(
                                onTap: () {
                                  viewTile(content, post);
                                },
                                trailing: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      color: Colors.lightBlue[100],
                                      shape: BoxShape.circle),
                                  child: Center(
                                      child: Text(
                                    post['quantity'].toString(),
                                  )),
                                ),
                                title: Text(
                                    formatter.format(post['time'].toDate())));
                          }),
                    ),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  Future getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    this.setState(() {
      _image = File(pickedFile.path);
    });
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewPostScreen(image: _image)),
    );
  }

  Future getImageFromCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedFile.path);
    });
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewPostScreen(image: _image)),
    );
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Semantics(
                  label: 'Upload image from gallery or camera',
                  hint: 'Choice alert',
                  button: false,
                  child: Text("Please select from the following")),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () {
                        getImageFromGallery();
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    Semantics(
                        label: 'Tap to take an image',
                        hint: 'Camera',
                        button: true,
                        child: GestureDetector(
                          child: Text("Camera"),
                          onTap: () {
                            getImageFromCamera();
                          },
                        ))
                  ],
                ),
              ));
        });
  }
}
