// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'dart:math';
import 'dart:ui';
import 'dart:collection';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timelines/timelines.dart' as tl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliverthis/Dispatcher.dart';
import 'package:deliverthis/ScheduleDelivery.dart';
import 'package:deliverthis/tests.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_timeline/flutter_timeline.dart';
import 'package:bubble_timeline/timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:glass_container/glass_container.dart';
import 'package:google_place/google_place.dart';
import 'CourierForm.dart';
import 'Orders.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bubble_timeline/bubble_timeline.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'Login.dart';
import 'Product.dart';
import 'maps.dart';
import 'package:dio/dio.dart';
import 'package:location/location.dart' as lc;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: primaryBlack,
       
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent)),
          border: UnderlineInputBorder(borderSide:BorderSide(color: Colors.transparent) )
        )
        ),
      
      debugShowCheckedModeBanner: false,
      home: SDScreen(),
    );
  }
}

class CourierScreen extends StatefulWidget {
  CourierScreen({super.key});
  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child:
            Scaffold(backgroundColor: Colors.black12, body: CourierActivity()));
  }
}

class CourierActivity extends StatefulWidget {
  CourierActivity({super.key});

  @override
  State<CourierActivity> createState() => _CourierActivityState();
}

class _CourierActivityState extends State<CourierActivity> {
  Set<Marker> _markers = {};
  List<LatLng> points = [];
  var polylinePoints = PolylinePoints();
  final pc = PanelController();
  bool indelivery = false;
  var deliverydata;
  Completer<GoogleMapController> _controller = Completer();
  lc.Location location = lc.Location();
  lc.LocationData? currentLocation;
  var _status = "Traveling to PickUp";

  @override
  Widget build(BuildContext context) {
    var control;

    void getlocation() async {
      location.getLocation().then((value) {
        setState(() {
          currentLocation = value;
        });
      });
    }

    location.onLocationChanged.listen((e) {
      currentLocation = e;
    });

    getlocation();

    final CameraPosition pretoria = CameraPosition(
      target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      zoom: 14.4746,
    );
    return SlidingUpPanel(
        controller: pc,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        boxShadow: const <BoxShadow>[
          BoxShadow(blurRadius: 0.0, color: Colors.transparent)
        ],
        color: Colors.transparent,
        backdropColor: Colors.transparent,
        body: currentLocation == null
            ? Container()
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  myLocationEnabled: true,
                  // ignore: prefer_const_literals_to_create_immutables
                  markers: _markers,
                  polylines: {
                    Polyline(
                        width: 6,
                        color: Colors.black,
                        points: points,
                        polylineId: PolylineId("To"))
                  },
                  mapType: MapType.terrain,

                  initialCameraPosition: pretoria,

                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    //controller = control;
                  },
                ),
              ),
        panelBuilder: (sr) {
          return FutureBuilder(
            future: getOrderPostedC(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return GlassContainer(
                    shadowColor: Colors.transparent,
                    contColor: Colors.transparent,
                    borderRadiusColor: Colors.transparent,
                    child: Column(
                      children: [
                        GestureDetector(
                          onVerticalDragEnd: (d) {
                            sr.jumpTo(0);
                          },
                          onVerticalDragDown: ((d) {
                            if (pc.isPanelOpen) {
                              pc.close();
                            }
                          }),
                          child: Center(
                              child: Container(
                            height: 10,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                            //height: MediaQuery.of(context).size.height*0.75,
                            child: ListView.separated(
                                controller: sr,
                                itemBuilder: (BuildContext context, int index) {
                                  var pickuplat =
                                      snapshot.data[index]["From"].latitude;
                                  var pickuplong =
                                      snapshot.data[index]["From"].longitude;
                                  var destinationlat =
                                      snapshot.data[index]["To"].latitude;
                                  var destinationlong =
                                      snapshot.data[index]["To"].longitude;
                                  var keys =
                                      snapshot.data[index]["Products"].keys;

                                  List<Widget> items = [];
                                  //ITEMS:
                                  for (var k in keys) {
                                    items.add(GlassContainer(
                                        shadowColor: Colors.orangeAccent,
                                        borderRadiusColor: Colors.orangeAccent,
                                        contColor: Colors.orangeAccent,
                                        shadowSpreadRadius: 0,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 1, bottom: 1),
                                          child: Text(
                                            " $k ",
                                            style: GoogleFonts.lato(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: 2,
                                                color: Colors.black),
                                          ),
                                        )));
                                  }

                                  return !indelivery
                                      ? Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: const [
                                                  Colors.black54,
                                                  Colors.black87
                                                ]),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01,
                                              ),
                                              //Name:
                                              Center(
                                                  child: GlassContainer(
                                                shadowColor:
                                                    Colors.orangeAccent,
                                                shadowSpreadRadius: 5,
                                                contColor: Colors.white,
                                                child: Text(
                                                  "    ${snapshot.data[index]["Dispatcher"]}    ",
                                                  style: GoogleFonts.lato(
                                                      fontSize: 18,
                                                      letterSpacing: 3,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color:
                                                          Colors.orangeAccent),
                                                ),
                                              )),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              Image.asset(
                                                "assets/d9.png",
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                              //Delivery Items Header
                                              Center(
                                                child: GlassContainer(
                                                    shadowColor:
                                                        Colors.orangeAccent,
                                                    borderRadiusColor:
                                                        Colors.white,
                                                    shadowSpreadRadius: 1,
                                                    contColor: Colors.white,
                                                    child: Text(
                                                      "   Delivery Items:  ",
                                                      style: GoogleFonts.lato(
                                                          fontSize: 18,
                                                          wordSpacing: 5,
                                                          letterSpacing: 2,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors
                                                              .orangeAccent),
                                                    )),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),

                                              //Items
                                              Align(
                                                  alignment: Alignment.center,
                                                  child: Wrap(
                                                    children: [
                                                      Container(
                                                        child: Wrap(
                                                          spacing: 10,
                                                          runSpacing: 20,
                                                          alignment:
                                                              WrapAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          direction:
                                                              Axis.horizontal,
                                                          children: items,
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.04,
                                              ),

                                              //From Widget
                                              GlassContainer(
                                                  contColor: Colors.greenAccent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  contWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                  borderRadiusColor:
                                                      Colors.greenAccent,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .my_location_outlined,
                                                            color:
                                                                Colors.black),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text("From : ",
                                                            style: GoogleFonts
                                                                .lato(
                                                                    color: Colors
                                                                        .black)),
                                                        Text(
                                                          "${snapshot.data[index]["FromAddress"]}",
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              //To Widget
                                              GlassContainer(
                                                  contColor: Colors.greenAccent,
                                                  borderRadiusColor:
                                                      Colors.greenAccent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  contWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          color: Colors.black,
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text("To : ",
                                                            style: GoogleFonts
                                                                .lato(
                                                                    color: Colors
                                                                        .black)),
                                                        Text(
                                                          "${snapshot.data[index]["DestinationAddress"]}",
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.04,
                                              ),
                                              //Distance
                                              Align(
                                                  alignment: Alignment.center,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.0,
                                                      ),
                                                      GlassContainer(
                                                        contColor:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.white54,
                                                        radius: BorderRadius
                                                            .circular(5),
                                                        shadowSpreadRadius: 0,
                                                        borderRadiusColor:
                                                            Colors.transparent,
                                                        child: Text(
                                                          "  KM  ",
                                                          style: GoogleFonts.lato(
                                                              fontSize: 17,
                                                              letterSpacing: 5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: Colors
                                                                  .orangeAccent),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.04,
                                              ),
                                              //Weight
                                              Align(
                                                  alignment: Alignment.center,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.0,
                                                      ),
                                                      GlassContainer(
                                                        contColor:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.white38,
                                                        radius: BorderRadius
                                                            .circular(5),
                                                        shadowSpreadRadius: 0,
                                                        borderRadiusColor:
                                                            Colors.transparent,
                                                        child: Text(
                                                          "  3.5 KG  ",
                                                          style: GoogleFonts.lato(
                                                              fontSize: 17,
                                                              letterSpacing: 5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: Colors
                                                                  .orangeAccent),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.04,
                                              ),

                                              //Pay
                                              Align(
                                                  alignment: Alignment.center,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.0,
                                                      ),
                                                      GlassContainer(
                                                        contColor:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.white38,
                                                        radius: BorderRadius
                                                            .circular(5),
                                                        shadowSpreadRadius: 0,
                                                        borderRadiusColor:
                                                            Colors.transparent,
                                                        child: Text(
                                                          " R${snapshot.data[index]["Payment"]} ",
                                                          style: GoogleFonts.lato(
                                                              fontSize: 17,
                                                              letterSpacing: 5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: Colors
                                                                  .orangeAccent),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.04,
                                              ),
                                              //Show on map and accept
                                              Align(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                foregroundColor:
                                                                    Colors
                                                                        .black,
                                                                backgroundColor:
                                                                    Colors
                                                                        .greenAccent),
                                                        onPressed: () async {
                                                          //print(snapshot.data[index]);
                                                          var pickuplat =
                                                              snapshot
                                                                  .data[index]
                                                                      ["From"]
                                                                  .latitude;
                                                          var pickuplong =
                                                              snapshot
                                                                  .data[index]
                                                                      ["From"]
                                                                  .longitude;
                                                          var destinationlat =
                                                              snapshot
                                                                  .data[index]
                                                                      ["To"]
                                                                  .latitude;
                                                          var destinationlong =
                                                              snapshot
                                                                  .data[index]
                                                                      ["To"]
                                                                  .longitude;
                                                          /*
                                                    var apiKey =
                                                        'AIzaSyDXtVPq1xF9xsIZ1CJl3OzmJ3LQOQ5NKBU';
                                                    PolylineResult result =
                                                        await polylinePoints
                                                            .getRouteBetweenCoordinates(
                                                      apiKey, // Google Maps API Key
                                                      PointLatLng(pickuplat,
                                                          pickuplong),
                                                      PointLatLng(
                                                          destinationlat,
                                                          destinationlong),
                                                      travelMode:
                                                          TravelMode.driving,
                                                      optimizeWaypoints: true,
                                                    );
                                                    
                                                    */
                                                          setState(() {
                                                            _markers = {};
                                                            points = [];
                                                            _markers.add(Marker(
                                                                markerId: MarkerId(
                                                                    "$pickuplat"),
                                                                position: LatLng(
                                                                    pickuplat,
                                                                    pickuplong)));

                                                            _markers.add(Marker(
                                                                markerId: MarkerId(
                                                                    "$destinationlat"),
                                                                position: LatLng(
                                                                    destinationlat,
                                                                    destinationlong)));
                                                            /*
                                                      for (var point
                                                          in result.points) {
                                                        points.add(LatLng(
                                                            point.latitude,
                                                            point.longitude));
                                                      }*/
                                                          });

                                                          final GoogleMapController
                                                              controller =
                                                              await _controller
                                                                  .future;
                                                          controller.animateCamera(
                                                              CameraUpdate
                                                                  .newLatLng(LatLng(
                                                                      pickuplat,
                                                                      pickuplong)));
                                                          controller.animateCamera(
                                                              CameraUpdate.newLatLng(LatLng(
                                                                  destinationlat,
                                                                  destinationlong)));
                                                          pc.close();
                                                          sr.jumpTo(0);
                                                        },
                                                        child: Text(
                                                            "Show on Map")),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            pc.close();
                                                            indelivery = true;
                                                            deliverydata =
                                                                snapshot.data[
                                                                    index];
                                                          });
                                                          var acceptlat =
                                                              currentLocation!
                                                                  .latitude;
                                                          var acceptlong =
                                                              currentLocation!
                                                                  .longitude;

                                                          var pickuplat =
                                                              snapshot
                                                                  .data[index]
                                                                      ["From"]
                                                                  .latitude;
                                                          var pickuplong =
                                                              snapshot
                                                                  .data[index]
                                                                      ["From"]
                                                                  .longitude;

                                                          var apiKey =
                                                              'AIzaSyDXtVPq1xF9xsIZ1CJl3OzmJ3LQOQ5NKBU';

                                                          setState(() {
                                                            points = [];
                                                            _markers = {};

                                                            _markers.add(Marker(
                                                                markerId: MarkerId(
                                                                    "PickUp-Accepted"),
                                                                position: LatLng(
                                                                    pickuplat,
                                                                    pickuplong)));
                                                            location
                                                                .onLocationChanged
                                                                .listen(
                                                                    (event) async {
                                                              GoogleMapController
                                                                  c =
                                                                  await _controller
                                                                      .future;
                                                              c.animateCamera(CameraUpdate.newCameraPosition(
                                                                  CameraPosition(
                                                                      zoom: 17,
                                                                      target: LatLng(
                                                                          event
                                                                              .latitude!,
                                                                          event
                                                                              .longitude!))));
                                                            });

                                                            constantupdate() async {
                                                              PolylineResult
                                                                  result =
                                                                  await polylinePoints
                                                                      .getRouteBetweenCoordinates(
                                                                apiKey, // Google Maps API Key
                                                                PointLatLng(
                                                                    currentLocation!
                                                                        .latitude!,
                                                                    currentLocation!
                                                                        .longitude!),
                                                                PointLatLng(
                                                                    pickuplat,
                                                                    pickuplong),
                                                                travelMode:
                                                                    TravelMode
                                                                        .driving,
                                                                optimizeWaypoints:
                                                                    true,
                                                              );

                                                              for (var point
                                                                  in result
                                                                      .points) {
                                                                //

                                                                points.add(LatLng(
                                                                    point
                                                                        .latitude,
                                                                    point
                                                                        .longitude));
                                                              }

                                                              location
                                                                  .onLocationChanged
                                                                  .listen(
                                                                      (event) async {
                                                                getDistanceMatrix() async {
                                                                  try {
                                                                    var response =
                                                                        await Dio()
                                                                            .get("https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${pickuplat},${pickuplong}&origins=${event.latitude},${event.longitude}&mode=driving&key=$apiKey");

                                                                    return response
                                                                        .data;
                                                                  } catch (e) {
                                                                    print(e);
                                                                  }
                                                                }

                                                                var fiveMinUpdateData;

                                                                GoogleMapController
                                                                    c =
                                                                    await _controller
                                                                        .future;
                                                                c.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                                                                    zoom: 17,
                                                                    target: LatLng(
                                                                        event
                                                                            .latitude!,
                                                                        event
                                                                            .longitude!))));

                                                                setState(() {
                                                                  //currentLocation = event;

                                                                  mapupdate() async {
                                                                    PolylineResult
                                                                        result =
                                                                        await polylinePoints
                                                                            .getRouteBetweenCoordinates(
                                                                      apiKey,
                                                                      PointLatLng(
                                                                          currentLocation!
                                                                              .latitude!,
                                                                          currentLocation!
                                                                              .longitude!),
                                                                      PointLatLng(
                                                                          pickuplat,
                                                                          pickuplong),
                                                                      travelMode:
                                                                          TravelMode
                                                                              .driving,
                                                                      optimizeWaypoints:
                                                                          true,
                                                                    );
                                                                    points = [];

                                                                    for (var point
                                                                        in result
                                                                            .points) {
                                                                      //

                                                                      points.add(LatLng(
                                                                          point
                                                                              .latitude,
                                                                          point
                                                                              .longitude));
                                                                    }
                                                                  }

                                                                  //mapupdate();
                                                                });
                                                              });
                                                            }

                                                            //onstantupdate();
                                                          });
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                foregroundColor:
                                                                    Colors
                                                                        .black,
                                                                backgroundColor:
                                                                    Colors
                                                                        .orangeAccent),
                                                        child: Text(
                                                            "Accept Delivery")),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                              ),
                                            ],
                                          ),
                                        )
                                      : GlassContainer(
                                          contWidth:
                                              MediaQuery.of(context).size.width,
                                          contColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          borderRadiusColor: Colors.black,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors: const [
                                                  Colors.white70,
                                                  Colors.white
                                                ])),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  AppBar(
                                                    title: Text(" $_status "),
                                                    centerTitle: true,
                                                  ),
                                                  //Text("${deliverydata}"),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child:
                                                        Text("I have arrived"),
                                                    onPressed: () {
                                                      setState(() {
                                                        _status = "Arrived";
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child: Text(
                                                        "I am loading the package"),
                                                    onPressed: () {
                                                      setState(() {
                                                        _status =
                                                            "Loading package";
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child: Text(
                                                        "The Package is as described"),
                                                    onPressed: () {
                                                      setState(() {
                                                        _status =
                                                            "Loading package";
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child: Text(
                                                        "I have completed the pickup"),
                                                    onPressed: () {
                                                      setState(() {
                                                        _status =
                                                            "Pickup complete";
                                                      });
                                                    },
                                                  ),
                                                ]),
                                          ),
                                        );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                                // ignore: dead_code
                                itemCount:
                                    !indelivery ? snapshot.data.length : 1))
                      ],
                    ));
              } else {}
              return LoadingIndicator(indicatorType: Indicator.ballPulseSync);
            },
            // ignore: dead_code
          );
        });
  }
}
