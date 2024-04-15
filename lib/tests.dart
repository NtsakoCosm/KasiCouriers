import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDataWidget extends StatefulWidget {
  late final int? data;

  MyDataWidget({Key? key, this.data}) : super(key: key);

  @override
  _MyDataWidgetState createState() => _MyDataWidgetState();
}

class _MyDataWidgetState extends State<MyDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.data.toString());
  }
}

class MyButtonWidget extends StatefulWidget {
  final MyDataWidget? dataWidget;

  MyButtonWidget({Key? key, this.dataWidget}) : super(key: key);

  @override
  State<MyButtonWidget> createState() => _MyButtonWidgetState();
}

class _MyButtonWidgetState extends State<MyButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState (() {
          widget.dataWidget!.data = 1;
        });
      },
      child: Text('Increment'),
    );
  }
}


class Tes extends StatelessWidget {
  const Tes({super.key});

  @override
  Widget build(BuildContext context) {
    MyDataWidget dataWidget = MyDataWidget(data: 0);
    MyButtonWidget buttonWidget = MyButtonWidget(dataWidget: dataWidget);
    return Container(child: Row(children: [dataWidget,buttonWidget]),);
  }
}