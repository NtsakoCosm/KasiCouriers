// ignore_for_file: prefer_const_constructors

import 'package:deliverthis/Product.dart';
import 'package:flutter/material.dart';
import 'package:glass_container/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:input_quantity/input_quantity.dart';

class CourierForm extends StatelessWidget {
  const CourierForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(children: [
        Image.asset(
          "assets/murcia_02 (2).jpg",
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.fill,
        ),
        FormFrame()
      ]),
    ));
  }
}

class FormFrame extends StatefulWidget {
  const FormFrame({super.key});

  @override
  State<FormFrame> createState() => _FormFrameState();
}

class _FormFrameState extends State<FormFrame> {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
        contColor: Colors.transparent,
        shadowColor: Colors.transparent,
        sigmax: 0,
        sigmay: 10,
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(" What type of Vehicle do you drive? ",
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    wordSpacing: 3)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            CarTypes(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Text(" Vehicle Infomation: ",
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    wordSpacing: 3)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            //Make
            GlassContainer(
              contColor: Colors.transparent,
              //shadowColor: Colors.transparent,
              borderRadiusColor: Colors.transparent,
              child:TextField(
              decoration:
              InputDecoration(
                
                icon: Image.asset(
                  
                  "assets/car.png",
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height * 0.125,
                  width: MediaQuery.of(context).size.width * 0.125,
                  ),
                hintText: "Vehicle Brand (e.g Nissan)" ),
              
            ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
            ),
            //Model of car
            GlassContainer(
              contColor: Colors.transparent,
              //shadowColor: Colors.transparent,
              borderRadiusColor: Colors.transparent,
              child: TextField(
                decoration: InputDecoration(
                    icon: Image.asset(
                      "assets/car.png",
                      color: Colors.black,
                      height: MediaQuery.of(context).size.height * 0.125,
                      width: MediaQuery.of(context).size.width * 0.125,
                    ),
                    hintText: " What is the model? (e.g Np200)"),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
            ),
            Text(" What is your fuel efficiency  ",
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    wordSpacing: 3)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.only(left: 40, right: 30),
              child: Text(
                  " How Many litres does it take for your Vehicle to travel 100KM?(e.g 8 Litres / 100KM)?",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      wordSpacing: 3)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputQty(
                minVal: 1,
                initVal: 1,
                
                onQtyChanged: (v) {},
                steps: 1,
              ),
              Text("      /     100KM")


            ])),
            
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
            ),
            Text(" What is your Vehicle's Payload (in KG)? ",
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    wordSpacing: 3)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.only(left: 60, right: 50),
              child: Text(
                  " What is the Max Amount in KG you are willing to move at a time (50kg Minimum) ",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      wordSpacing: 3)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            InputQty(minVal: 50, initVal: 50, onQtyChanged: (v) {},steps: 50,),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Text(" How Big is Your Crew? ",
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    wordSpacing: 3)),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.only(left: 60, right: 50),
              child: Text(
                  " How many people will be in the car, delivering products? (including you) ",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      wordSpacing: 3)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            InputQty(maxVal: 10, minVal: 1, initVal: 1, onQtyChanged: (v) {}),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),

            Center(child:
            ElevatedButton(child:
             Text("Submit") ,onPressed: (){},))
            
            
          ]),
        ));
  }
}

class CarTypes extends StatefulWidget {
  const CarTypes({super.key});

  @override
  State<CarTypes> createState() => _CarTypesState();
}

class _CarTypesState extends State<CarTypes> {
  var lis = List.generate(8, (_) => Colors.transparent);
  @override
  Widget build(BuildContext context) {
    var cars = [
      "v1.png",
      "v2.png",
      "v3.png",
      "v4.png",
      "v5.png",
      "v6.png",
      "v7.png",
      "v8.png"
    ];
    var names = [
      "Scooter",
      "Hatch Back",
      "Sedan",
      "SUV",
      "Pick Up Van",
      "Cargo Van",
      "Box Truck",
      "Drop Side Truck"
    ];
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.14,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  lis = List.generate(8, (index) => Colors.transparent);
                  lis[index] = Colors.orangeAccent;
                });
              },
              child: GlassContainer(
                  contColor: lis[index],
                  shadowColor: Colors.transparent,
                  borderRadiusColor: Colors.black,
                  radius: BorderRadius.circular(10),
                  sigmax: 0,
                  sigmay: 10,
                  contHeight: MediaQuery.of(context).size.height * 0.2,
                  contWidth: MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                      child: Column(children: [
                    Text("${names[index]}"),
                    //SizedBox(height: 1,),
                    Image.asset(
                      "assets/${cars[index]}",
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.2,
                      fit: BoxFit.fitWidth,
                    ),
                  ]))),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const SizedBox(
                width: 20,
              ),
          itemCount: 8),
    );
  }
}
