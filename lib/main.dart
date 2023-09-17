import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encryption_demo/encrypt_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firestoreInstance = FirebaseFirestore.instance;
  TextEditingController userNameController = TextEditingController();
  List<String> encryptedUserNames = [];
  List<String> decryptedUserNames = [];

  Future<void> saveUserName({required String username, required EncryptedUserData userData}) async {
    // Save the input string along with the iv, which will be used for decoding later
    await firestoreInstance.collection('users').doc(username).set(userData.toJson());
  }

  Future<void> getUserName() async {
    decryptedUserNames.clear();
    encryptedUserNames.clear();
    final userData = await firestoreInstance.collection('users').get();
    for (var element in userData.docs) {
      String decryptedUserName = await EncryptData().decryptWithAESAlgorithm(
        element.data()["username"],
        element.data()["iv"],
      );
      decryptedUserNames.add(decryptedUserName);
      encryptedUserNames.add(
        element.data()["username"],
      );
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Encryption Demo"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: userNameController,
            decoration: InputDecoration(
              label: const Text("Username"),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: TextButton(
              onPressed: () async {
                if (userNameController.text.isNotEmpty) {
                  try {
                    // Step 1: encrypt the entered username
                    EncryptedUserData userData =
                        await EncryptData().encryptWithAESAlgorithm(userNameController.text.toString());

                    // Step 2: save the encrypted username to firebase or database
                    await saveUserName(
                      username: userNameController.text.toString(),
                      userData: userData,
                    );

                    userNameController.clear();

                    // Step 3: fetch the data from firebase or database
                    await getUserName();

                    // Step 4: update the ui
                    setState(() {});
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                }
              },
              style: TextButton.styleFrom(
                side: BorderSide(
                  width: 0.5,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              child: const Text("Save Username"),
            ),
          ),
          const Text(
            "UserNames",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: decryptedUserNames.length,
            itemBuilder: (BuildContext context, int index) {
              return decryptedUserNames.isNotEmpty
                  ? ListTile(
                      title: Text(
                        decryptedUserNames[index],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Encrypted Username: ${encryptedUserNames[index]}"),
                    )
                  : null;
            },
          ),
        ],
      ),
    );
  }
}
