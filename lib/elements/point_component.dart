import 'package:flutter/material.dart';

class PointComponent extends StatelessWidget {
  final double size;

  const PointComponent({Key key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      ),
    );
  }
}
