// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliverthis/Orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:deliverthis/Product.dart';
import 'package:flutter/material.dart';
import 'package:glass_container/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:time_range/time_range.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';
import 'package:from_to_time_picker/from_to_time_picker.dart';
import 'package:counter_button/counter_button.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:google_directions_api/google_directions_api.dart' as g;
import 'package:toggle_switch/toggle_switch.dart';

import 'package:fk_toggle/fk_toggle.dart';
import 'main.dart';

Map jsonData = {
  "Products": [{}]
};

class SDScreen extends StatelessWidget {
  SDScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            FullFrame()
          ],
        ),
      ),
    );
  }
}

class FullFrame extends StatefulWidget {
  const FullFrame({super.key});

  @override
  State<FullFrame> createState() => _FullFrameState();
}

class _FullFrameState extends State<FullFrame> {
  LatLng? pickuplatlang;
  LatLng? destinationlatlang;
  Completer<GoogleMapController> _controller = Completer();
  final CameraPosition pretoria = CameraPosition(
    target: LatLng(25.7479, 28.2293),
    zoom: 14.4746,
  );

  Set<Marker> _markers = {};
  List<LatLng> points = [];
  LatLng pickUp = LatLng(0.0, 0.0);
  LatLng destination = LatLng(0.0, 0.0);

  String kGoogleApiKey = "";
  var pickupicon = BitmapDescriptor.fromAssetImage(
          ImageConfiguration(
              size: Size(10, 10), platform: TargetPlatform.android),
          'assets/box.png')
      .then((onValue) {
    return onValue;
  });
  var sheduled = false;
  bool showmap = false;
  @override
  Widget build(BuildContext context) {
    LatLng? lat;

    var polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines

    List<Color> delivery = [Colors.white, Colors.black];

    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
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
                        ))))),
        SizedBox(
          height: 25,
        ),
        Align(
            child: GlassContainer(
          contColor: Colors.transparent,
          shadowColor: Colors.transparent,
          borderRadiusColor: Colors.transparent,
          sigmax: 20,
          child: Text(" Adress Details ",
              style: GoogleFonts.lato(
                color: Colors.black,
                letterSpacing: 2,
              )),
        )),
        SizedBox(
          height: 25,
        ),
        SearchGooglePlacesWidget(
          iconColor: Colors.transparent,
          clearIcon: (Icons.abc_outlined),
          darkMode: true,
          placeholder: "Pick Up Location:",
          apiKey: '',
          // The language of the autocompletion
          language: 'en',
          // The position used to give better recommendations. In this case we are using the user position

          onSelected: (Place place) async {
            final geolocation = await place.geolocation;
            jsonData["PickUp_Lat"] = geolocation!.coordinates.latitude;
            jsonData["PickUp_Long"] = geolocation.coordinates.longitude;
            jsonData["PickUp_Address"] = place.description;
            // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom
            final GoogleMapController controller = await _controller.future;
            lat = geolocation.coordinates;
            controller
                .animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
            controller.animateCamera(
                CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
            setState(() {
              pickUp = geolocation.coordinates;
              _markers.add(Marker(
                position: geolocation.coordinates,
                markerId: MarkerId("Pickup"),
              ));
            });
          },

          onSearch: (Place place) {},
        ),
        const SizedBox(
          height: 25,
        ),
        SearchGooglePlacesWidget(
          darkMode: true,
          placeholder: "Destination Location:",
          iconColor: Colors.transparent,
          apiKey: '',
          // The language of the autocompletion
          language: 'en',
          // The position used to give better recommendations. In this case we are using the user position

          onSelected: (Place place) async {
            final geolocation = await place.geolocation;
            destination = geolocation!.coordinates;
            jsonData["Destination_Lat"] = geolocation.coordinates.latitude;
            jsonData["Destination_Long"] = geolocation.coordinates.longitude;
            jsonData["Destination_Address"] = place.description;

            PolylineResult result =
                await polylinePoints.getRouteBetweenCoordinates(
              kGoogleApiKey, // Google Maps API Key
              PointLatLng(pickUp.latitude, pickUp.longitude),
              PointLatLng(destination.latitude, destination.longitude),
              travelMode: TravelMode.transit,
              optimizeWaypoints: true,
            );

            setState(() {
              destination = geolocation.coordinates;
              _markers.add(Marker(
                position: geolocation.coordinates,
                markerId: MarkerId("Destination"),
              ));
              points.clear();

              for (var point in result.points) {
                points.add(LatLng(point.latitude, point.longitude));
              }
            });

            // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom

            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
            controller.animateCamera(
                CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
          },
          onSearch: (Place place) {},
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            buildingsEnabled: true,
            // ignore: prefer_const_literals_to_create_immutables
            markers: _markers,
            polylines: {
              Polyline(
                  color: Colors.pink,
                  points: points,
                  polylineId: PolylineId("From-To"))
            },
            mapType: MapType.terrain,

            initialCameraPosition: pretoria,
            trafficEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),

        SDFrame()

        //AddProductSchedule()
      ],
    ));
    ;
  }
}

class SDFrame extends StatefulWidget {
  SDFrame({super.key});

  @override
  State<SDFrame> createState() => _SDFrameState();
}

class _SDFrameState extends State<SDFrame> {
  List<Widget> dates = [];
  List<Widget> sheduleddelivery = [
    const SizedBox(
      height: 50,
    ),
    GlassContainer(
      contColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Text(" Acceptable Date and Time for Pick Up : "),
    ),
    const SizedBox(
      height: 25,
    ),
    FlutterDatePickerTimeline(
      startDate: DateTime.now().add(Duration(days: 1)),
      endDate: DateTime(2023, 12, 30),
      initialSelectedDate: DateTime.now().add(Duration(days: 1)),
      onSelectedDateChange: (dateTime) {
        jsonData["Date"] = dateTime;
      },
    ),
    const SizedBox(
      height: 25,
    ),
    Container(
      child: TimeRange(
          fromTitle: Text(
            'From',
            style: TextStyle(fontSize: 13, color: Colors.black),
          ),
          toTitle: Text(
            'To',
            style: TextStyle(fontSize: 13, color: Colors.black),
          ),
          alwaysUse24HourFormat: true,
          titlePadding: 20,
          textStyle:
              TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
          activeTextStyle:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          borderColor: Colors.black,
          backgroundColor: Colors.transparent,
          activeBackgroundColor: Colors.black87,
          firstTime: TimeOfDay(hour: 00, minute: 00),
          lastTime: TimeOfDay(hour: 23, minute: 30),
          timeStep: 15,
          timeBlock: 30,
          onRangeCompleted: (range) {
            jsonData["Time"] = range!.start;
          }),
    ),
  ];

  bool addproducts = false;
  var name;
  @override
  Widget build(BuildContext context) {
    var globalindex = 0;
    while (globalindex == 1) {
      setState(() {
        dates = sheduleddelivery;
      });
    }

    return SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      GlassContainer(
        contColor: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Text(" Add Products"),
      ),
      const SizedBox(
        height: 10,
      ),
      addproducts
          ? GlassContainer(
              contColor: Colors.transparent,
              shadowColor: Colors.transparent,
              borderRadiusColor: Colors.transparent,
              sigmax: 0,
              sigmay: 20,
              contHeight: MediaQuery.of(context).size.height * 0.5,
              child: AddProductSchedule())
          : ElevatedButton(
              child: Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.transparent),
              onPressed: () {
                setState(() {
                  addproducts = true;
                });
              },
            ),
      const SizedBox(
        height: 30,
      ),
      Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FkToggle(
              onSelected: (i, f) {
                if (i == 1) {
                  
                  setState(() {
                    jsonData['Date'] = DateTime.now();
                    dates = sheduleddelivery;
                  });
                } else if (i == 0) {
                  setState(() {
                    jsonData.remove("Time");
                    jsonData.remove("Date");
                    dates = [];
                  });
                }
              },
              enabledElementColor: Colors.white,
              disabledElementColor: Colors.black,
              backgroundColor: Colors.white,
              selectedColor: Colors.black,
              width: MediaQuery.of(context).size.width * 0.4,
              height: 30,
              labels: const ['Deliver ASAP', 'Deliver Another Day']),
        ]),
      ),
      const SizedBox(
        height: 25,
      ),
      Container(
        child: Column(
          children: dates,
        ),
      ),
      const SizedBox(
        height: 25,
      ),
      GlassContainer(
          sigmax: 0,
          sigmay: 20,
          contColor: Colors.transparent,
          shadowColor: Colors.transparent,
          borderRadiusColor: Colors.transparent,
          child: TextField(
            onChanged: (data) {
              jsonData["Note"] = data;
            },
            decoration: InputDecoration(label: Text("Note to Courier")),
          )),
      
      const SizedBox(
        height: 25,
      ),
      Container(
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.black),
            onPressed: () async {
              String user = FirebaseAuth.instance.currentUser!.uid;
              var name;
              var dispatcher = await FirebaseFirestore.instance
                  .collection("Dispatcher")
                  .where("Id", isEqualTo: user)
                  .get()
                  .then((value) {
                return value.docs.first.data()["Name"];
              });
              
              OrderPosted(
                  GeoPoint(jsonData["PickUp_Lat"], jsonData["PickUp_Long"]),
                  GeoPoint(jsonData["Destination_Lat"],
                      jsonData["Destination_Long"]),
                  jsonData["PickUp_Address"],
                  jsonData["Destination_Address"],
                  jsonData["Products"],
                  dispatcher,
                  jsonData["Payment"],
                  jsonData["Note"]);
              /*
              var doc = FirebaseFirestore.instance
                  .collection("OrderPosted")
                  .where("From",
                      isEqualTo: GeoPoint(
                          jsonData["PickUp_Lat"], jsonData["PickUp_Long"]))
                  .where("To",
                      isEqualTo: GeoPoint(jsonData["Destination_Lat"],
                          jsonData["Destination_Long"]))
                  .where("FromAddress", isEqualTo: jsonData["PickUp_Address"])
                  .where(
                    "ToAddress",
                    isEqualTo: jsonData["Destination_Address"],
                  )
                  .where("Products", isEqualTo: jsonData["Products"])
                  .where("Dispatcher", isEqualTo: user)
                  .where("Payment", isEqualTo: jsonData["Payment"])
                  .where("Note", isEqualTo: jsonData["Note"])
                  .get()
                  .then((value) {
                    
                return value.docs.first.id;
              });
              */
            },
            child: Text("Place Delivery")),
      ),
    ]));
  }
}

class AddProductSchedule extends StatefulWidget {
  const AddProductSchedule({super.key});

  @override
  State<AddProductSchedule> createState() => _AddProductScheduleState();
}

class _AddProductScheduleState extends State<AddProductSchedule> {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser?.uid;
    var fb = FirebaseFirestore.instance
        .collection("Products")
        .where("Dispatcher", isEqualTo: user)
        .get();
    return FutureBuilder(
      future: fb,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data.docs[0].data());
          return ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 20,
                );
              },
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var sb = SheduleButton(
                  qtymax: snapshot.data.docs[index].data()["Qty"],
                  product: snapshot.data.docs[index].data()["Name"],
                );

                return GlassContainer(
                  sigmax: 0,
                  sigmay: 20,
                  contColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  contHeight: MediaQuery.of(context).size.height * 0.15,
                  contWidth: MediaQuery.of(context).size.width * 0.8,
                  borderRadiusColor: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/box (1).png",
                                height: 45,
                                width: 45,
                              ),
                              Text(
                                " ${snapshot.data.docs[index].data()["Name"]}",
                                style: GoogleFonts.lato(fontSize: 15),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      sb,
                    ],
                  ),
                );
              });
        } else if (!snapshot.hasData) {}
        return LoadingIndicator(indicatorType: Indicator.ballPulseSync);
      },
    );
  }
}

class ScheduleMap extends StatefulWidget {
  ScheduleMap({super.key});
  LatLng? latlng;
  @override
  State<ScheduleMap> createState() => ScheduleMapState();
}

class ScheduleMapState extends State<ScheduleMap> {
  late LatLng latlng = widget.latlng!;

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(0, 0),
      zoom: 14.4746,
    );

    // ignore: unused_local_variable

    Set<Marker> _markers = {
      Marker(
        markerId: MarkerId("From"),
        position: LatLng(0, 0),
      )
    };

    return GoogleMap(
      // ignore: prefer_const_literals_to_create_immutables
      markers: _markers,
      mapType: MapType.terrain,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}

class SheduleButton extends StatefulWidget {
  SheduleButton(
      {super.key,
      this.title = "Add to Schedule",
      this.qty = 0,
      this.clr = Colors.black,
      this.qtymax,
      this.product});
  String title = "Add to Schedule";
  num qty = 0;
  Color clr = Colors.black;
  num? qtymax;
  String? product;

  @override
  State<SheduleButton> createState() => _SheduleButtonState();
}

class _SheduleButtonState extends State<SheduleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(
              child: InputQty(
                  initVal: 0,
                  maxVal: widget.qtymax!,
                  onQtyChanged: (q) {
                    widget.qty = q!;

                    if ((widget.title == "Added" ||
                            widget.title == "Updated") &&
                        widget.qty > 0) {
                      setState(() {
                        widget.title = "Update";
                        widget.clr = Colors.black;
                      });
                    } else if (widget.title == "Update" && q <= 0) {
                      setState(() {
                        widget.title = 'Add to Schedule';
                        widget.clr = Colors.black;
                        jsonData["Products"][0].remove(widget.product);
                      });
                    } else if (widget.title == "Added" && q == 0) {
                      setState(() {
                        widget.title = "Add to Schedule";
                        widget.clr = Colors.black;
                      });
                      jsonData["Products"][0].remove(widget.product);
                    }
                  }),
            ),
            ElevatedButton(
                onPressed: () {
                  if ((widget.title == "Update") && widget.qty > 0) {
                    setState(() {
                      widget.title = 'Updated';
                      widget.clr = Colors.green;
                      jsonData["Products"][0][widget.product] = widget.qty;
                    });
                  } else if (widget.title == "Add to Schedule" &&
                      widget.qty > 0) {
                    setState(() {
                      widget.title = 'Added';
                      widget.clr = Colors.green;
                      jsonData["Products"][0][widget.product] = widget.qty;
                    });
                    print(jsonData);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: widget.clr),
                child: Text(widget.title))
          ],
        ));
  }
}
