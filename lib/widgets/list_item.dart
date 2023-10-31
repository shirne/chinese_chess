import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final CrossAxisAlignment titleAlign;

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.titleAlign = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    List<Widget> titles = [title];
    if (leading != null) {
      children.add(leading!);
    }
    if (subtitle != null) {
      titles.add(subtitle!);
    }
    children.add(
      Expanded(
        flex: 1,
        child: Column(
          crossAxisAlignment: titleAlign,
          children: titles,
        ),
      ),
    );
    if (trailing != null) {
      children.add(trailing!);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
