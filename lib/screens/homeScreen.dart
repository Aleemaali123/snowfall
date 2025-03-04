import 'package:chtapp/screens/request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>UserRequestPage())
              );
            },
            icon: Icon(Icons.add)
        )
      ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('request').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
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
                String? imageUrl = (data['image1'] != null && data['image1'].isNotEmpty)
                    ? data['image1']
                    : (data['image2'] != null && data['image2'].isNotEmpty)
                    ? data['image2']
                    : null;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null ? Icon(Icons.image, size: 25) : null,
                  ),
                  title: Text("Location: ${data['location']}"),
                  subtitle: Text("Area: ${data['area']}"),
                  trailing: Text(data['category']),
                );
              },
            );

          }
      ),
    );
  }
}
