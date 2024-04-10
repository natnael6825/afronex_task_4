import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyItems extends StatefulWidget {
  const MyItems({Key? key});

  @override
  State<MyItems> createState() => _MyItemsState();
}

class _MyItemsState extends State<MyItems> {
  late final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> _refreshItems() async {
    setState(() {}); // Refresh the state
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "My Items",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshItems,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('sold')
                      .where('userId', isEqualTo: _user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return Text('Error fetching data');
                    }
                    final soldDocs = snapshot.data!.docs;
                    if (soldDocs.isEmpty) {
                      return Center(child: Text('No items bought yet.'));
                    }

                    return ListView.builder(
                      itemCount: soldDocs.length,
                      itemBuilder: (context, index) {
                        final item = soldDocs[index];
                        final items = item['items'] as List<dynamic>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items.map<Widget>((item) {
                            return Padding(
                              padding: EdgeInsets.all(8.0), // Add padding around the items
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection(item['category'])
                                    .doc(item['itemId'])
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return Text('Error fetching item');
                                  }

                                  final itemData = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  final name = itemData['name'] ?? '';
                                  final description =
                                      itemData['description'] ?? '';
                                  final imageURL = itemData['image_url'] ??
                                      ''; // Assuming there's an imageURL field

                                 return SizedBox(
  width: double.infinity, // Expand to fit width
  height: 200, // Fixed height for consistency
  child: Stack(
    fit: StackFit.expand,
    children: [
      if (snapshot.hasData)
        Image.network(
          imageURL,
          fit: BoxFit.cover,
        ),
      Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (snapshot.hasData)
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 10),
              if (snapshot.hasData)
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  ),
);

                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
