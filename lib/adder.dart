import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';

class Adder extends StatefulWidget {
  const Adder({Key? key}) : super(key: key);

  @override
  State<Adder> createState() => _AdderState();
}

class _AdderState extends State<Adder> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController collectionController =
      TextEditingController(); // New field for collection name

  late ImagePicker _picker;
  XFile? _image;
  UploadTask? taskcomplete;
  var url = '';

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
  }

  Widget taskprogress() {
    if (taskcomplete != null) {
      return StreamBuilder(
        stream: taskcomplete?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            double progress = data!.bytesTransferred / data.totalBytes;

            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                  Center(
                    child: Text(
                      "${(100 * progress).roundToDouble()}%",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox(
              height: 50,
            );
          }
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Future upload() async {
    final ref =
        FirebaseStorage.instance.ref().child("/items/${DateTime.now()}.jpg");

    if (_image != null) {
      setState(() {
        taskcomplete = ref.putFile(File(_image!.path));
      });

      final snapshot = await taskcomplete!.whenComplete(() {});

      url = await snapshot.ref.getDownloadURL();
      taskprogress();
      setState(() {
        taskcomplete = null;
      });
    } else {
      url = '';
    }

    try {
      await FirebaseFirestore.instance
          .collection(
              collectionController.text) // Use user-provided collection name
          .add({
        'name': nameController.text,
        'description': descriptionController.text,
        'price': priceController.text,
        'image_url': url,
      });
    } catch (e) {
      print('Error saving item: $e');
    }

    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    url = '';

    // Refresh the widget
    setState(() {});
  }

  Future<void> _takePicture() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 600,
    );

    setState(() {
      _image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller:
                    collectionController, // Text field for collection name
                decoration: InputDecoration(labelText: 'Collection Name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _takePicture();
                },
                child: Text('Take Image'),
              ),
              SizedBox(height: 50),
              OutlinedButton(
                onPressed: (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        collectionController
                            .text.isNotEmpty) // Check if all fields are filled
                    ? upload
                    : null,
                child: Text('Submit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(
                    color: Colors.red,
                  ),
                ),
              ),
              taskprogress(),
            ],
          ),
        ),
      ),
    );
  }
}
