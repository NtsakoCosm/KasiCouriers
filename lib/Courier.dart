import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Orders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Courier {
  late String id;
  late String name;
  late String vehicle;

  Courier(this.id, this.name, this.vehicle){
    FirebaseFirestore.instance
        .collection("Dispatchers")
        .add({"Id": id, "Name": name,"Vehicle": vehicle});
  }

  getCouriers() async {
    return FirebaseFirestore.instance
        .collection("Courier")
        .get()
        .then((value) => value.docs.forEach((element) {
              element.data();
            }));
  }

  updateCourier(String doc, String id, String name, String vehicle) async {
    return FirebaseFirestore.instance
        .collection('Courier')
        .doc(doc)
        .update({'Id': id, "Name": name,"Vehicle": vehicle});
  }

  deleteCourier(String doc) async{
    return FirebaseFirestore.instance
        .collection('Courier')
        .doc(doc)
        .delete();
  }
}
