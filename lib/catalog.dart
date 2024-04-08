

// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors, sort_child_properties_last


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'categoryitem.dart';
import 'details.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Scpical Offers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              _buildTopSection1(),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              _buildTopSection2(context),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Bottom Section',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection1() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('catagory')
          .doc('wK96Vtw3WvkFyjOID4Y9')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text('No categories found'),
          );
        }

        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        List<String> categories = List<String>.from(data['catagory'] ?? []);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection(category).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No items found'),
                    );
                  }

                  // Assuming each document has an image_url and name field
                  return GestureDetector(
                    onTap: () {
                      // Navigate to detail page with category name
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            category: category,
                            documentId: snapshot.data!.docs[0].id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 130,
                      height: 170,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(
                            snapshot.data!.docs[0]['image_url'],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          snapshot.data!.docs[0]['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTopSection2(BuildContext context) {
    return Container(
      height: 100,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('catagory')
            .doc('wK96Vtw3WvkFyjOID4Y9')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(
              child: Text('No categories found'),
            );
          }

          dynamic data = snapshot.data!.data();
          List<String> categories = List<String>.from(data['catagory'] ?? []);
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryItemsPage(categoryName: categories[index]),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink,
                        const Color.fromARGB(255, 215, 146, 43)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Widget _buildBottomSection(BuildContext context) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('catagory')
        .doc('wK96Vtw3WvkFyjOID4Y9')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        return Center(
          child: Text('No categories found'),
        );
      }

      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
      List<String> categories = List<String>.from(data['catagory'] ?? []);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          FutureBuilder<List<QuerySnapshot>>(
            future: Future.wait(
              categories.map((category) {
                return FirebaseFirestore.instance.collection(category).get();
              }),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Combine all documents from different categories into a single list
              List<QueryDocumentSnapshot> allDocuments = [];
              snapshot.data!.forEach((categorySnapshot) {
                allDocuments.addAll(categorySnapshot.docs);
              });

              if (allDocuments.isEmpty) {
                return Center(
                  child: Text('No items found'),
                );
              }

              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                padding: EdgeInsets.all(16),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: allDocuments.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String imageUrl = data['image_url'];
                  String productName = data['name'];
                  double productPrice = double.parse(data['price']);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            category: categories.firstWhere((category) =>
                                document.reference.path.contains(category)),
                            documentId: document.id,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.blue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: EdgeInsets.all(7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$$productPrice',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 20),
        ],
      );
    },
  );
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CatalogScreen(),
  ));
}
