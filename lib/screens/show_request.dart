import 'package:chtapp/screens/auth.dart';
import 'package:chtapp/screens/request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowUserRequest extends StatefulWidget {
  const ShowUserRequest({super.key});

  @override
  State<ShowUserRequest> createState() => _ShowUserRequestState();
}

class _ShowUserRequestState extends State<ShowUserRequest> {
  // Logout Function
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacementNamed(
                  context, "/login"); // Navigate to Login Page
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // title: const Text("Home Page"),
      ),

      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('request')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("No Rrquest Found"),
              );
            }
            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;

                // Check which image is available
                String? imageUrl =
                    (data['image1'] != null && data['image1'].isNotEmpty)
                        ? data['image1']
                        : (data['image2'] != null && data['image2'].isNotEmpty)
                            ? data['image2']
                            : null;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            imageUrl != null ? NetworkImage(imageUrl) : null,
                        child: imageUrl == null
                            ? Icon(Icons.image, size: 25)
                            : null,
                      ),
                      title: Text("Time: ${data['date_time']}"),
                      subtitle: Text("Area: ${data['location']}"),
                      trailing: Text(data['category']),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
