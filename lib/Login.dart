// ignore_for_file: prefer_const_constructors

import 'package:deliverthis/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glass_container/glass_container.dart';
import 'Dispatcher.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Image.asset(
              "assets/murcia_02 (2).jpg",
              height: MediaQuery.of(context).size.height,
            ),
            LoginFrame()
          ],
        ));
  }
}

class LoginFrame extends StatelessWidget {
  const LoginFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      contHeight: MediaQuery.of(context).size.height,
      contWidth: MediaQuery.of(context).size.width,
      contColor: Colors.transparent,
      shadowColor: Colors.transparent,
      sigmax: 0,
      sigmay: 0,
      borderRadiusColor: Colors.transparent,
      child: LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    var email;
    var password;
    return Align(
      alignment: Alignment.center,
      child: GlassContainer(
        contHeight: MediaQuery.of(context).size.height * 0.40,
        contWidth: MediaQuery.of(context).size.width,
        contColor: Colors.transparent,
        shadowColor: Colors.transparent,
        borderRadiusColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Material(
              color: Colors.transparent,
              child: TextField(
                decoration: InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Username:",
                    fillColor: Colors.transparent,
                    hoverColor: Colors.black),
                onChanged: (data) {
                  email = data;
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Password:",
                  focusColor: Colors.black,
                ),
                onChanged: (data) {
                  password = data;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email, password: password);
                
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DispatcherScreen(),
                  ),
                );
              },
              child: Text("Sign in"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
