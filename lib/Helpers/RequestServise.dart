import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdt/Helpers/Constants.dart';

abstract class RequestServiseAbstract {
  void completeForm(Map<dynamic, dynamic> itemsList,
      Function(void value, dynamic errorType) completion);
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class RequestServise extends RequestServiseAbstract {
  CollectionReference _usersCollection =
      firestore.collection(ProjectConstants.usersCollectionName);
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Duration timeout = Duration(seconds: 20);

  void completeForm(Map<dynamic, dynamic> itemsList,
      Function(void value, dynamic errorType) completion) {
    String currentUserId;
    _usersCollection
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                var id = doc["id"];
                if (id == _firebaseAuth.currentUser.uid) {
                  currentUserId = doc.id;
                }
              })
            })
        .whenComplete(() => {
              _usersCollection
                  .doc(currentUserId)
                  .update({
                    ProjectConstants.completedFormsCollectionName:
                        FieldValue.arrayUnion([itemsList])
                  })
                  .timeout(timeout)
                  .then((value) => completion(value, null))
                  .catchError((error) => completion(null, error))
            });
  }
}
