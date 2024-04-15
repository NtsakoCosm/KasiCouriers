import 'Product.dart';
import 'Courier.dart';
import 'Dispatcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glass_container/glass_container.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderPosted {
  late GeoPoint from;
  late GeoPoint to;
  late String fromAdress;
  late String toAdress;
  late List<Map> products;
  late String dispatcher;
  late num payment;
  late String note;

  OrderPosted(this.from, this.to,this.fromAdress,this.toAdress, this.products, this.dispatcher, this.payment,this.note)  {
    FirebaseFirestore.instance.collection("OrderPosted").add({
      
      "From": from,
      "To": to,
      "Dispatcher": dispatcher,
      "Products": products[0],
      "FromAddress": fromAdress,
      "DestinationAddress":toAdress,
      "Note": note,
      "Payment": payment
    });
  }

  factory OrderPosted.fromjson(Map json) {
    return OrderPosted(
        json["From"], json["To"], json["FromAddress"], json["DestinationAddress"],
        json["Products"], json["Dispatcher"],
        json["Payment"],
        json["Note"]
        );
  }
}

class OrderAccepted {
  late OrderPosted op;
  late String id;
  late Courier courier;

  OrderAccepted(this.op, this.courier, this.id) {
    FirebaseFirestore.instance
        .collection("Dispatchers")
        .add({"Id": id, "OrdersPosted": op, "Courier": courier});
  }
}

Future<List<Map>> getOrderPostedD() async {
  var user = FirebaseAuth.instance.currentUser?.uid;

  List<Map> data = [];
  await FirebaseFirestore.instance
      .collection("OrderPosted")
      .where("Dispatcher", isEqualTo: user)
      .get()
      .then((value) => value.docs.forEach((element) {
            data.add(element.data());
          }));

  return data;
}

updateOrderPosted(
  String doc,
  String id,
  String from,
  String to,
  List<Product> products,
  Dispatcher dispatcher,
) async {
  return FirebaseFirestore.instance
      .collection('OrderPosted')
      .doc(doc)
      .update({'Id': id, "From": from, "To": to, "Dispatcher": dispatcher});
}

deleteOrderPosted(String doc) async {
  return FirebaseFirestore.instance.collection('OrderPosted').doc(doc).delete();
}

getOrdersAccepted() async {
  return FirebaseFirestore.instance
      .collection("OrdersAccepted")
      .get()
      .then((value) => value.docs.forEach((element) {
            element.data();
          }));
}

updateOrdersAccepted(
    String doc, String id, Courier courier, OrderPosted op) async {
  return FirebaseFirestore.instance
      .collection('OrdersAccepted')
      .doc(doc)
      .update({'Id': id, "Courier": courier, "OrdersPosted": op});
}

deleteOrdersAccepted(String doc) async {
  return FirebaseFirestore.instance
      .collection('OrdersAccepted')
      .doc(doc)
      .delete();
}

Future<List<Map<String, dynamic>>> getOrderPostedC() async {
  var snapshot =
      await FirebaseFirestore.instance.collection("OrderPosted").get();
  return snapshot.docs.map((doc) => doc.data()).toList();
}
