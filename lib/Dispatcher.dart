// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:deliverthis/Product.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glass_container/glass_container.dart';
import 'Orders.dart';
import 'Login.dart';
import 'package:jelly_anim/jelly_anim.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ScheduleDelivery.dart';

class Dispatcher {
  late String id;
  late String name;

  Dispatcher(this.id, this.name) {
    FirebaseFirestore.instance
        .collection("Dispatchers")
        .add({"Id": id, "Name": name});
  }
}

class DispatcherScreen extends StatelessWidget {
  DispatcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var dispatchers = getDispatchers();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Image.asset(
              'assets/murcia_02.jpg',
              fit: BoxFit.fill,
              height: MediaQuery.of(context).size.height,
            ),
            const DispatchFrame()
          ],
        ),
      ),
    );
  }
}

class DispatchFrame extends StatelessWidget {
  const DispatchFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      contHeight: MediaQuery.of(context).size.height,
      contWidth: MediaQuery.of(context).size.width,
      contColor: Colors.transparent,
      shadowColor: Colors.transparent,
      borderRadiusColor: Colors.white,
      sigmax: 0,
      sigmay: 0,
      child: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: const [
          // ignore: prefer_const_constructors
          DispatchIcon(),
          // ignore: prefer_const_constructors
          SizedBox(height: 10),
          Expanded(
            child: DispatachSchedule(),
          )
        ],
      ),
    );
  }
}

class DispatchIcon extends StatelessWidget {
  const DispatchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: GlassContainer(
            shadowBlurRadius: 100,
            contWidth: 130,
            contColor: Colors.black,
            // ignore: sort_child_properties_last
            child: Align(
                child: Text("Kasi Couriers",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      letterSpacing: 2,
                    )))));
  }
}

class DispatachSchedule extends StatelessWidget {
  const DispatachSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getOrderPostedD(),
      builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
        if (snapshot.hasData) {
          return Expanded(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.black,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddProduct()),
                      );
                    },
                    child: GlassContainer(
                        radius: BorderRadius.circular(100),
                        contHeight: MediaQuery.of(context).size.height * 0.06,
                        contWidth: MediaQuery.of(context).size.width * 0.60,
                        borderRadiusColor: Colors.white,
                        shadowColor: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.topCenter,
                                child: Image.asset(
                                  "assets/box (1).png",
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                )),
                            Text(
                              "Add Product ",
                              style: GoogleFonts.lato(fontSize: 18),
                            )
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(200)),
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.black,
                    onTap: () {
                      //addDelivery(context);
                    },
                    child: GlassContainer(
                        radius: BorderRadius.circular(100),
                        shadowColor: Colors.transparent,
                        shadowSpreadRadius: 1,
                        borderRadiusColor: Colors.white,
                        contWidth: MediaQuery.of(context).size.width * 0.6,
                        contHeight: MediaQuery.of(context).size.height * 0.06,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.topCenter,
                                child: Image.asset(
                                  "assets/inv2.png",
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                )),
                            Text("Inventory",
                                style: GoogleFonts.lato(fontSize: 17))
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(200)),
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.black,
                    onTap: () {
                      //addDelivery(context);
                      //Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SDScreen()));
                    },
                    child: GlassContainer(
                        radius: BorderRadius.circular(100),
                        shadowColor: Colors.transparent,
                        borderRadiusColor: Colors.white,
                        contWidth: MediaQuery.of(context).size.width * 0.65,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.topCenter,
                                child: Image.asset(
                                  "assets/inv4.png",
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                )),
                            Text("Schedule a Delivery",
                                style: GoogleFonts.lato(fontSize: 17))
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                GlassContainer(
                  contHeight: 22,
                  contWidth: 100,
                  contColor: Colors.white,
                  borderRadiusColor: Colors.white,
                  shadowColor: Colors.transparent,
                  child: Text(
                    "Schedule",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) =>
                          GlassContainer(
                            contColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            borderRadiusColor: Colors.white,
                            contHeight:
                                MediaQuery.of(context).size.height * 0.42,
                            contWidth: MediaQuery.of(context).size.width,
                            child: ScheduleCard(
                                ordersposted: OrderPosted.fromjson(
                                    snapshot.data![index])),
                          ),
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                            height: 10,
                          ),
                      itemCount: snapshot.data!.length),
                )
              ],
            ),
          );
        }

        return Container(
            height: 100,
            width: 50,
            child: LoadingIndicator(
              indicatorType: Indicator.ballBeat,
              colors: [Colors.black],
            ));
      },
    );
  }
}

class ScheduleCard extends StatelessWidget {
  ScheduleCard({super.key, this.ordersposted});
  OrderPosted? ordersposted;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomRight,
        child: Column(children: [
          const SizedBox(
            height: 10,
          ),
          Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingIndicator(
                    indicatorType: Indicator.ballClipRotateMultiple,
                    colors: [Colors.black],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Looking for Driver",
                    style: GoogleFonts.lato(fontSize: 15),
                  )
                ],
              )),

          const SizedBox(
            height: 10,
          ),

          Container(
            child: Row(
              // ignore: prefer_const_literals_to_create_immutables

              children: [
                const Icon(Icons.add_box_outlined, size: 20),
                const Text(" Items:"),
                Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Container(
                        child: Row(
                      children: [
                        Expanded(
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return OrderPostedProducts();
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(
                                        width: 10,
                                      ),
                              itemCount: ordersposted!.products.length),
                        ),
                        const Icon(
                          Icons.add,
                          size: 28,
                          color: Colors.black,
                        ),
                      ],
                    ))),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),
          Container(
            child: Row(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Icon(Icons.scale_outlined, size: 20),
                const Text(" Size(Kg):")
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            child: Row(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Icon(Icons.directions_train_outlined, size: 20),
                const Text(" Distance(KM):")
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            child: Row(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                const Icon(Icons.monetization_on_outlined, size: 20),
                const Text(" Pay(R):")
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GlassContainer(
              contColor: Colors.white,
              shadowColor: Colors.transparent,
              borderRadiusColor: Colors.black,
              contHeight: 35,
              radius: const BorderRadius.all(Radius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.share_location_outlined),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                      "From: lat:${ordersposted!.from.latitude}-lon:${ordersposted!.from.longitude}"),

                  //
                ],
              )),
          // ignore: prefer_const_constructors
          SizedBox(
            height: 20,
          ),
          GlassContainer(
              contColor: Colors.white,
              shadowColor: Colors.transparent,
              borderRadiusColor: Colors.black,
              contHeight: 35,
              radius: const BorderRadius.all(Radius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.location_pin),
                  // ignore: prefer_const_constructors
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                      "From: lat:${ordersposted!.to.latitude}-lon:${ordersposted!.from.longitude}"),

                  //Icon(Icons.location_pin),
                ],
              )),
          // ignore: prefer_const_constructors
          SizedBox(
            height: 15,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white),
                  child: const Text("Show on map")),
            ],
          ),
        ]));
  }
}

addDelivery(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text(
      "Send Request",
      style: GoogleFonts.lato(color: Colors.white),
    ),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    elevation: 50,
    clipBehavior: Clip.hardEdge,
    backgroundColor: Colors.transparent,
    title: Text(
      "Schedule Delivery",
      style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return GlassContainer(
        contHeight: MediaQuery.of(context).size.height * 0.9,
        contWidth: MediaQuery.of(context).size.width * 0.9,
        contColor: Colors.white12,
        shadowColor: Colors.transparent,
        borderRadiusColor: Colors.transparent,
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: TextField(
                decoration: InputDecoration(
                    labelText: "From",
                    prefixIconColor: Colors.black,
                    suffixIconColor: Colors.black),
              ),
            )
          ],
        ),
      );
    },
  );
}

getDispatchers() async {
  return FirebaseFirestore.instance
      .collection("Dispatchers")
      .get()
      .then((value) => value.docs.forEach((element) {
            element.data();
          }));
}

updateDispatcher(String doc, String id, String name) async {
  return FirebaseFirestore.instance
      .collection('Dispatchers')
      .doc(doc)
      .update({'Id': id, "Name": name});
}

deleteDispatcher(String doc) async {
  return FirebaseFirestore.instance.collection('Dispatchers').doc(doc).delete();
}

class OrderPostedProducts extends StatelessWidget {
  OrderPostedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getOrderPostedD(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return GlassContainer(
            shadowBlurRadius: 50,
            borderRadiusColor: Colors.white,
            contColor: Colors.white,
            child: Row(
              children: [
                const Icon(
                  Icons.edit,
                  size: 15,
                  color: Colors.black,
                ),
                Text(
                  "",
                  style: GoogleFonts.lato(color: Colors.black),
                ),
                const SizedBox(
                  width: 5,
                )
              ],
            ),
          );
        } else {
          const Text("No Item");
        }
        ;

        return const LoadingIndicator(
          indicatorType: Indicator.ballClipRotateMultiple,
          colors: [Colors.black],
        );

        //return CircularProgressIndicator();
      },
    );
  }
}
