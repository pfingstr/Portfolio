import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_waste_post.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewPostScreen extends StatefulWidget {
  final File image;
  NewPostScreen({Key key, this.image}) : super(key: key);
  static const routeName = 'newPost';
  @override
  _NewPostScreenScreenState createState() => _NewPostScreenScreenState();
}

class _NewPostScreenScreenState extends State<NewPostScreen> {
  final formKey = GlobalKey<FormState>();

  final foodWastePost = FoodWastePost();
  bool loading = false;

  LocationData locationData;
  @override
  void initState() {
    super.initState();
    retrieveLocation();
  }

  void retrieveLocation() async {
    var locationService = new Location();
    locationData = await locationService.getLocation();
    setState(() {});
  }

  void uploadData() async {
    loading = !loading;
    setState(() {});
    if (formKey.currentState.validate()) {
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child('image-${DateTime.now()}');
      StorageUploadTask uploadTask = storageReference.putFile(widget.image);
      await uploadTask.onComplete;
      foodWastePost.url = await storageReference.getDownloadURL();
      foodWastePost.latitude = locationData.latitude;
      foodWastePost.longitude = locationData.longitude;
      foodWastePost.time = Timestamp.now();
      formKey.currentState.save();
      Firestore.instance.collection('foodWastePosts').add({
        'url': foodWastePost.url,
        'latitude': foodWastePost.latitude,
        'longitude': foodWastePost.longitude,
        'quantity': foodWastePost.quantity,
        'time': foodWastePost.time
      });
      loading = !loading;
      Navigator.of(context).pop();
    }
  }

  Widget loadingOrNot() {
    if (loading == true) {
      return Container(
          height: 100,
          width: 100,
          color: Colors.blue[50],
          child: CircularProgressIndicator());
    } else {
      return Container(
          height: 100,
          color: Colors.blue[50],
          child: InkWell(
              onTap: () {
                uploadData();
              },
              child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.cloud_upload,
                    size: 95,
                    color: Theme.of(context).accentColor,
                  ))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('New Post')),
        bottomNavigationBar: Semantics(
            label: 'Add new post',
            button: true,
            hint: 'Tap to add this post',
            child: loadingOrNot()),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
                key: formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          flex: 4,
                          child: Container(
                              child: Image(
                            image: FileImage(widget.image),
                          ))),
                      TextFormField(
                        onSaved: (value) {
                          foodWastePost.quantity = int.parse(value);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a number';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            labelText: "Number of wasted items"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                      ),
                    ]))));
  }
}
