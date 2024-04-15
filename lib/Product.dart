// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliverthis/Dispatcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsform/gs_form.dart';
import 'package:glass_container/glass_container.dart';
import 'package:gsform/gs_form/widget/field.dart';
import 'package:gsform/gs_form/widget/form.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:quantity_input/quantity_input.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

num qty = 1;
String? id;
String? name;
String height = '';
String width = '';
String description = '';
String disclaimer = '';

class Product {
  late num qty;
  late String name;
  late String height;
  late String width;
  late String description;
  late String disclaimer;
  late String dispatcher;

  Product(this.qty, this.name, this.height, this.width, this.description,
      this.disclaimer, this.dispatcher) {
    create() async {
      FirebaseFirestore.instance.collection("Products").add({
        "Qty": qty,
        "Name": name,
        "Description": description,
        "Disclaimer": disclaimer,
        "Dispatcher": dispatcher,
        "Height": height,
        "Width": width,
      });
    }

    create();
  }

  factory Product.fromjson(Map json) {
    return Product(json["Qty"], json["Name"], json["Width"], json["Height"],
        json["Description"], json["Disclaimer"], json["Dispatcher"]);
  }
}

getDispatcherProducts(String dispatcher) async {
  var product;
  await FirebaseFirestore.instance
      .collection("Products")
      .where("Dispatcher", isEqualTo: dispatcher)
      .get()
      .then((value) => value.docs.forEach((element) {
            product = element.data();
          }));

  return product;
}

updateProduct(String doc, String id, String name, String description,
    String disclaimer) async {
  return FirebaseFirestore.instance.collection('Products').doc(doc).update({
    'Id': id,
    "Name": name,
    "Description": description,
    "Disclaimer": disclaimer
  });
}

deleteProduct(String doc) async {
  return FirebaseFirestore.instance.collection('Products').doc(doc).delete();
}

class AddProduct extends StatelessWidget {
  const AddProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(children: [
              Image.asset(
                'assets/murcia_02.jpg',
                fit: BoxFit.fill,
                height: MediaQuery.of(context).size.height,
              ),
              AddProductScreen(),
            ])));
  }
}

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      child: GlassContainer(
        contHeight: MediaQuery.of(context).size.height * 0.96,
        contWidth: MediaQuery.of(context).size.width * 0.97,
        contColor: Colors.transparent,
        shadowColor: Colors.transparent,
        borderRadiusColor: Colors.transparent,
        sigmax: 0,
        sigmay: 20,
        child: AddProductForm(),
      ),
    );
  }
}

class AddProductForm extends StatefulWidget {
  AddProductForm({super.key});
  var q;
  //var name;
  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      contHeight: MediaQuery.of(context).size.height * 0.10,
      contWidth: MediaQuery.of(context).size.width * 0.85,
      contColor: Colors.transparent,
      borderRadiusColor: Colors.transparent,
      shadowColor: Colors.transparent,
      sigmax: 0,
      sigmay: 20,
      child: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 0,
          ),
          Align(
              alignment: Alignment.topCenter,
              child: GlassContainer(
                  shadowBlurRadius: 100,
                  shadowColor: Colors.transparent,
                  contColor: Colors.black,
                  radius: BorderRadius.all(Radius.circular(100)),
                  // ignore: sort_child_properties_last
                  child: Align(
                      child: Text("Add Product to Inventory",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 2,
                          ))))),
          SizedBox(
            height: 25,
          ),
          Center(
            child: Image.asset(
              "assets/box (1).png",
              height: 50,
              width: 50,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          GlassField(
            text: "What are you Trying to Deliver?",
          ),
          const SizedBox(
            height: 25,
          ),
          GlassField(
            text: "Height:",
          ),
          const SizedBox(
            height: 25,
          ),
          GlassField(
            text: "Width:",
          ),
          const SizedBox(
            height: 25,
          ),
          GlassField(
            text: "Description:",
          ),
          const SizedBox(
            height: 25,
          ),
          GlassField(
            text: "Disclaimer: How Should the Product be treated?",
          ),
          const SizedBox(
            height: 25,
          ),
          Text(
            "  Size(KG):  ",
            style:
                GoogleFonts.lato(fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          const SizedBox(
            height: 25,
          ),
          InputQty(
              minVal: 1,
              initVal: 1,
              onQtyChanged: (v) {
                qty = v!;
              }),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () {},
              child: Text("I don't know the the size of my product")),
          const SizedBox(
            height: 25,
          ),
          Text(
            "  Common Item and their Size ",
            style:
                GoogleFonts.lato(fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(
            height: 25,
          ),
          CommonItems(),
          const SizedBox(
            height: 25,
          ),
          Text(
            "  Quantity:  ",
            style:
                GoogleFonts.lato(fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          const SizedBox(
            height: 25,
          ),
          InputQty(
              minVal: 1,
              initVal: 1,
              onQtyChanged: (v) {
                qty = v!;
              }),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
              onPressed: () async {
                var dispatcher = await FirebaseAuth.instance.currentUser!.uid;

                Product(qty, name!, height, width, description, disclaimer,
                    dispatcher);

                var doc = await FirebaseFirestore.instance
                    .collection("Products")
                    .where("Name", isEqualTo: name)
                    .where("Description", isEqualTo: description)
                    .where("Disclaimer", isEqualTo: disclaimer)
                    .where(
                      "Dispatcher",
                      isEqualTo: dispatcher,
                    )
                    .where("Height", isEqualTo: height)
                    .where("Width", isEqualTo: width)
                    .get();

                var id;
                for (var snapshot in doc.docs) {
                  var idd = snapshot.id;
                  id = idd;
                }

                var doc1 = await FirebaseFirestore.instance
                    .collection("Products")
                    .doc(id)
                    .set({"Id": id}, SetOptions(merge: true));

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously

                //aAddProductConfirmation(context);
              },
              child: const Text("Add Product")),
        ],
      )),
    );
  }
}

class GlassField extends StatelessWidget {
  GlassField({super.key, this.text});
  String? text;
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      contColor: Colors.transparent,
      borderRadiusColor: Colors.black26,
      shadowColor: Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: TextField(
          onChanged: (data) {
            //print('object');
            switch (text) {
              case "What are you Trying to Deliver?":
                name = data;
                throw () {};
              case "Height:":
                height = data;
                throw () {};
              case "Width:":
                width = data;
                throw () {};
              case "Description:":
                description = data;
                throw () {};
              case "Disclaimer: How Should the Product be treated?":
                disclaimer = data;
                throw () {};
            }
          },
          decoration: InputDecoration(
              hintStyle: const TextStyle(color: Colors.black, fontSize: 15),
              hintText: text),
        ),
      ),
    );
  }
}

class CommonItems extends StatefulWidget {
  const CommonItems({super.key});

  @override
  State<CommonItems> createState() => _CommonItemsState();
}

class _CommonItemsState extends State<CommonItems> {
  var itemscolors = List.generate(4, (_) => Colors.transparent);
  var currentindex;
  bool picked = false;

  var types = [
    "assets/WC/Catering&Events/catering.png",
    "assets/WC/appliances.png",
    "assets/WC/electronics.png",
    "assets/WC/furniture.png",
  ];
  var typenames = [
    "  Catering&Events  ",
    "Appliances",
    "Electronics",
    "Furniture"
  ];
  var numcards;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.14,
            width: MediaQuery.of(context).size.width,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        picked = true;
                        currentindex = index;
                        itemscolors =
                            List.generate(4, (_) => Colors.transparent);
                        itemscolors[index] = Colors.orangeAccent;
                      });
                    },
                    child: GlassContainer(
                        shadowColor: Colors.transparent,
                        borderRadiusColor: Colors.black,
                        contColor: itemscolors[index],
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "${typenames[index]}",
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w900),
                              ),
                              Image.asset(
                                "${types[index]}",
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                width: MediaQuery.of(context).size.width * 0.25,
                              ),
                            ])),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    ),
                itemCount: 4)),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        picked
            ? Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      if (currentindex == 0) {
                        var catering = [
                          "assets/WC/Catering&Events/stackablechair.png",
                          "assets/WC/Catering&Events/foldabletable.png",
                          "assets/WC/Furniture/recycledbench.png",
                          "assets/WC/Furniture/woodenbench.png",
                        ];
                        var cateringnames = [
                          "Stackable Chair",
                          "Foldable Table",
                          "Recyled Bench",
                          "Wooden Bench"
                        ];
                        var cateringsizes = [2, 12, 120, 60];
                        return GestureDetector(
                          onTap: () {},
                          child: GlassContainer(
                              //shadowColor: Colors.transparent,
                              borderRadiusColor: Colors.black,
                              shadowBlurRadius: 500,
                              sigmax: 0,
                              sigmay: 10,
                              contColor: Colors.transparent,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Center(
                                        child: Text(
                                      "   ${cateringnames[index]}   ",
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w900),
                                    )),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                    Image.asset(
                                      "${catering[index]}",
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.15,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                    Center(
                                        child: Text(
                                      "   ~${cateringsizes[index]}-KG   ",
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w900),
                                    )),
                                  ])),
                        );
                      } else if (currentindex == 1) {
                        var appliances = [
                          "assets/WC/appliances/Mini-Fridge.png",
                          "assets/WC/appliances/TopFreezerFridge.png",
                          "assets/WC/appliances/BottomFreezerFridge.png",
                          "assets/WC/appliances/SideBySideFridge.png",
                          "assets/WC/appliances/FrenchDoorFridge.png",
                          "assets/WC/appliances/small.png",
                          "assets/WC/appliances/medium.png",
                          "assets/WC/appliances/large.png",
                          "assets/WC/appliances/extra.png",
                          "assets/WC/appliances/frontloader.png",
                          "assets/WC/appliances/toploader.png",
                          "assets/WC/appliances/dryer.png",
                          "assets/WC/appliances/stacked.png",
                          "assets/WC/appliances/stovetop.png",
                          "assets/WC/appliances/coven.png",
                          "assets/WC/appliances/soven.png",
                          "assets/WC/appliances/microwave.png",
                        ];
                        var appliancenames = [
                          "Mini-Fridge",
                          "Top Freezer-Fridge",
                          "Bottom Freezer-Fridge",
                          "Side By Side-Fridge",
                          "French Door-Fridge",
                          "Small Chest-Freezer",
                          "Medium Chest-Freezer",
                          "Large Chest-Freezer",
                          "Extra Large Chest-Freezer",
                          "    Front Loading \n Washing Machine",
                          "    Top Loading \n Washing Machine",
                          "Dryer",
                          "Stacked Washer Dryer",
                          "Stove Top Oven",
                          "Commercial Oven/Stove",
                          "Standard Oven",
                          "Microwave"
                        ];
                        var appliancesizes = [
                          27,
                          80,
                          85,
                          131,
                          138,
                          25,
                          32,
                          43,
                          64,
                          56,
                          61,
                          96,
                          108,
                          79,
                          193,
                          54,
                          17
                        ];
                        return GestureDetector(
                          onTap: () {},
                          child: GlassContainer(
                              //shadowColor: Colors.transparent,
                              borderRadiusColor: Colors.black,
                              shadowBlurRadius: 500,
                              sigmax: 0,
                              sigmay: 10,
                              contColor: Colors.transparent,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Center(
                                        child: Text(
                                      "   ${appliancenames[index]}   ",
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w900),
                                    )),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                    Image.asset(
                                      "${appliances[index]}",
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.15,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                    Center(
                                        child: Text(
                                      "   ~${appliancesizes[index]}-KG   ",
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w900),
                                    )),
                                  ])),
                        );
                      } else if (currentindex == 3) {
                        var appliances = [
                          "assets/WC/Furniture/twin.jpg",
                          "assets/WC/Furniture/full.jpg",
                          "assets/WC/Furniture/Queen.jpg",
                          "assets/WC/Furniture/king.jpg",
                          "assets/WC/Furniture/sofa.png",
                          "assets/WC/Furniture/sofa.png",
                          "assets/WC/Furniture/sofa.png",
                          "assets/WC/Furniture/sofa.png",
                          "assets/WC/Furniture/sofa.png",
                          "assets/WC/Furniture/sofa.png",
                          "assets/WC/Furniture/sofa.png",
                          "assets/WC/Furniture/sofa.png",
                          "assets/WC/Furniture/barstool.png",
                          "assets/WC/Furniture/gamer.png",
                          "assets/WC/Furniture/genchair.png",
                          "assets/WC/Furniture/genchair.png",
                          "assets/WC/Furniture/genchair.png",
                          "assets/WC/Furniture/genchair.png",
                          "assets/WC/Furniture/genchair.png",
                        ];
                        var appliancenames = [
                          "Twin-Bed + Base",
                          "Full-Bed + Base",
                          "Queen-Bed + Base",
                          "King-Bed + Base",
                          "Love Seat",
                          "Sleeper sofa/sofa bed",
                          "2 Seat Sofa",
                          "3 Seat Sofa",
                          "4 Seat Sofa",
                          "4 Seat Sectional",
                          "5 Seat Sectional",
                          "6 Seat Sectional",
                          "Bar stool",
                          "Gaming Chair",
                          "Chair: Conservatory,Cane",
                          "Chair: Easy,Fireside,Lounge",
                          "Chair: Padded,Dining,Kitchen,Carver",
                          "Chair: High,Rocking",
                          "Chair: Not Padded,Dining,Kitchen,Carver",
                        ];
                        var appliancesizes = [
                          27,
                          60,
                          68,
                          80,
                          101,
                          160,
                          102,
                          151,
                          180,
                          453,
                          567,
                          680,
                          10,
                          30,
                          15,
                          15,
                          6,
                          11,
                          6,
                          120,
                        ];
                        return GestureDetector(
                          onTap: () {},
                          child: GlassContainer(
                              //shadowColor: Colors.transparent,
                              borderRadiusColor: Colors.black,
                              shadowBlurRadius: 500,
                              sigmax: 0,
                              sigmay: 10,
                              contColor: Colors.transparent,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Center(
                                        child: Text(
                                      "   ${appliancenames[index]}   ",
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w900),
                                    )),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                    Image.asset(
                                      "${appliances[index]}",
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.15,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                    Center(
                                        child: Text(
                                      "   ~${appliancesizes[index]}-KG   ",
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w900),
                                    )),
                                  ])),
                        );
                      } else if (currentindex == 2) {
                        var electronicnames = [
                          "32 inch TV",
                          "40 inch TV",
                         
                          "50 inch TV",
                          "55 inch TV",
                          "60 inch TV",
                          "65 inch TV",
                          "70 inch TV",
                          "75 inch TV",
                          "80 inch TV",
                          "Book Shelf Speaker",
                          "Behringer Active Speaker",
                          "Tower Speaker"

                          
                          
                          
                        ];
                        var electronicsizes = [
                          5,
                          10,
                          16,
                          18,
                          23,
                          27,
                          34,
                          41,
                          54,
                          6,
                          25,
                          14
                        ];
                        var electronics = [
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/tv.jpg",
                          "assets/WC/Electronics/bookshelf.jpg",
                          "assets/WC/Electronics/behringer.jpg",
                          "assets/WC/Electronics/towerspeakers.jpg",
                          
                        ];
                        return GestureDetector(
                          onTap: () {},
                          child: GlassContainer(
                              //shadowColor: Colors.transparent,
                              borderRadiusColor: Colors.black,
                              shadowBlurRadius: 500,
                              sigmax: 0,
                              sigmay: 10,
                              contColor: Colors.transparent,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Center(
                                        child: Text(
                                      "   ${electronicnames[index]}   ",
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w900),
                                    )),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                    Image.asset(
                                      "${electronics[index]}",
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.15,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                    Center(
                                        child: Text(
                                      "   ~${electronicsizes[index]}-KG   ",
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w900),
                                    )),
                                  ])),
                        );
                      }

                      return LoadingIndicator(
                          indicatorType: Indicator.ballPulseSync);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.05,
                        ),
                    itemCount: currentindex == 1
                        ? 17
                        : currentindex == 3
                            ? 20
                            : currentindex == 0
                                ? 4
                                : currentindex == 2
                                    ? 12
                                    : 0))
            : Container()
      ],
    );
  }
}

aAddProductConfirmation(BuildContext context) {
  // set up the button
  Widget scheduledelivery = ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
    child: Text(
      "Schedule Delivery",
      style: GoogleFonts.lato(color: Colors.black),
    ),
    onPressed: () {},
  );
  Widget addproduct = ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
    child: Text(
      "Add Another product",
      style: GoogleFonts.lato(color: Colors.black),
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
      addproduct,
      scheduledelivery,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        actions: [
          addproduct,
          scheduledelivery,
        ],
        content: GlassContainer(
          contHeight: MediaQuery.of(context).size.height * 0.127,
          contWidth: MediaQuery.of(context).size.width * 0.7,
          contColor: Colors.transparent,
          shadowSpreadRadius: 100,
          shadowColor: Colors.transparent,
          borderRadiusColor: Colors.transparent,
          child: Stack(
            children: [
              //SizedBox(height: 10,),
              Align(
                child: Icon(Icons.check),
              ),
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 100,
                    width: 100,
                    child: LoadingIndicator(
                        colors: [Colors.white],
                        indicatorType: Indicator.ballTrianglePath),
                  )),

              /*GlassContainer(
                shadowColor: Colors.transparent,
                radius: BorderRadius.all(Radius.circular(10)),
                borderRadiusColor: Colors.black,
                 contColor: Colors.transparent,
                child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  
                  children: [
                    //Icon(Icons.check),
                    
                    Image.asset(
                    "assets/package.png",
                    height: 40,
                    width: 40,
                  ),
                  SizedBox(width: 10,),
                    Text("Product added to Inventory",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900
                    )
                    ),
                    SizedBox(
                        width: 10,
                      ),
                    Image.asset(
                    "assets/box.png",
                    height: 40,
                    width: 40,
                  )
                    
                  ],
                )),

              )
             
              

              ,SizedBox(height: 10,),
              GlassContainer(
                contHeight: MediaQuery.of(context).size.height*0.25,
                contWidth: MediaQuery.of(context).size.width * 0.8,
                shadowColor: Colors.transparent,
                contColor: Colors.black,
                borderRadiusColor: Colors.white,
                child:  
                Column(children: [
                  SizedBox(height: 10,),
                  Text(
                        "Your Product was added to your inventory, You can add another Product, or Shedule a Delivery. You can further split your Product Deliveries to smaller loads or or Deliver them all at once",
                        style: GoogleFonts.lato(
                        height: 1.7,
                        color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15, wordSpacing: 15),
                      ),
                ],)
                
              )
              
               */
            ],
          ),
        ),
      );
    },
  );
}
