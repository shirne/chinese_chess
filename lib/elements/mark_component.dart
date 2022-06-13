import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MarkComponent extends StatelessWidget {
  final double size;

  const MarkComponent({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              border: Border.all(
                width: 1.0,
                color: const Color.fromRGBO(255, 255, 255, .8),
              )),
          child: Center(
            child: Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, .8),
                  borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
          ),
        ),
      ),
    );
  }
}
