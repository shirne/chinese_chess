

import 'package:flutter/material.dart';

class TabCard extends StatefulWidget{
  final List<Widget> titles;
  final List<Widget> bodies;
  final MainAxisAlignment titleAlign;
  final EdgeInsetsGeometry titlePadding;
  final BoxDecoration titleDecoration;
  final BoxDecoration titleActiveDecoration;
  final Axis direction;

  const TabCard({Key key,
    this.titles,
    this.bodies,
    this.direction = Axis.vertical,
    this.titleAlign = MainAxisAlignment.start,
    this.titlePadding,
    this.titleDecoration = const BoxDecoration(color: Colors.black12),
    this.titleActiveDecoration = const BoxDecoration(color: Colors.white)
  }) : super(key: key);


  @override
  State<TabCard> createState() => TabCardState();
}

class TabCardState extends State<TabCard> {
  int index = 0;
  List<Widget> titles;
  BoxDecoration titleDecoration;

  ValueNotifier<int> onTabChange;

  @override
  void initState() {
    super.initState();
    onTabChange = ValueNotifier<int>(index);

    titles = widget.titles.map<Widget>((e) {
      int curIndex =  widget.titles.indexOf(e);
      return TabCardTitleItem(myIndex: curIndex, child: e,);
    }).toList();
  }

  updateIndex(int i){
    setState(() {
      index = i;
    });
    onTabChange.value = i;
  }

  @override
  Widget build(BuildContext context) {

    return Flex(
        direction: widget.direction,
        children: [
          Row(
            mainAxisAlignment: widget.titleAlign,
            children: titles,
          ),
          Expanded(
              child: IndexedStack(
                index: index,
                sizing: StackFit.expand,
                children: widget.bodies,
              )
          )
      ],
    );
  }
}

class TabCardTitleItem extends StatefulWidget{
  final int myIndex;
  final Widget child;

  const TabCardTitleItem({Key key, this.myIndex, this.child}) : super(key: key);

  @override
  State<TabCardTitleItem> createState() => TabCardTitleItemState();
}

class TabCardTitleItemState extends State<TabCardTitleItem> {
  bool isActive = false;
  TabCardState tabCard;

  @override
  void initState() {
    super.initState();
    tabCard = context.findRootAncestorStateOfType<TabCardState>();
    if(tabCard != null) {
      if(widget.myIndex == tabCard.index){
        isActive = true;
      }
      tabCard.onTabChange.addListener(indexListener);
    }
  }

  indexListener(){
    setState(() {
      isActive = tabCard.index == widget.myIndex;
    });
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: (){
          tabCard.updateIndex(widget.myIndex);
        },
        child:AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutQuint,
            padding: tabCard.widget.titlePadding,
            decoration: isActive ?
            tabCard.widget.titleActiveDecoration :
            tabCard.widget.titleDecoration,
            child:widget.child
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabCard.onTabChange.removeListener(indexListener);
  }
}