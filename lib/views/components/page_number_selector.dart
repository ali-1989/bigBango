import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/circle_container.dart';

import 'package:app/system/extensions.dart';

typedef OnChange = void Function(int index);
///==================================================================================
class PageNumberSelector extends StatefulWidget {
  final Color defaultBackColor;
  final Color selectedBackColor;
  final Color selectedTextColor;
  final Color defaultTextColor;
  final Color? arrowDisableColor;
  final OnChange? onChange;
  final int selectedIndex;
  final List<int> numbers;

  const PageNumberSelector({
    required this.defaultBackColor,
    required this.selectedBackColor,
    this.selectedTextColor = Colors.white,
    this.defaultTextColor = Colors.black,
    this.selectedIndex = 0,
    this.arrowDisableColor,
    this.onChange,
    required this.numbers,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _PageNumberSelectorState();
}
///=========================================================================================
class _PageNumberSelectorState extends State<PageNumberSelector> with TickerProviderStateMixin {
  int currentIndex = 0;
  int startIndex = 0;
  List<int> showNumbers = [];
  late Color arrowDisableColor;
  late AnimationController animController;
  late Animation<int> alphaAnim;
  Tween<int> alphaTween = IntTween(begin: 10, end:255);

  @override
  void initState(){
    super.initState();

    animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    alphaAnim = alphaTween.animate(animController);

    arrowDisableColor = widget.arrowDisableColor?? Colors.grey.shade300;
    currentIndex = widget.selectedIndex;
    init();
  }

  void init(){
    showNumbers.clear();

    if(widget.numbers.length < 6){
      showNumbers.addAll(widget.numbers);
    }
    else {
      if(startIndex + 3 < currentIndex){
        startIndex++;
      }

      if(startIndex > 0 && startIndex >= currentIndex){
        startIndex--;
      }

      if(startIndex + 5 > widget.numbers.length){
        startIndex = widget.numbers.length -5;
      }

      for(int i = startIndex; i < startIndex +5; i++){
        showNumbers.add(widget.numbers[i]);
      }
    }
  }

  @override
  void didUpdateWidget(covariant PageNumberSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    /*if(oldWidget.selectIndex != widget.selectIndex || oldWidget.numbers.length != widget.numbers.length){

    }*/
    currentIndex = widget.selectedIndex;
    init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: RotatedBox(
              quarterTurns: 2,
              child: Icon(Icons.arrow_back_ios, color: _canPrev()? Colors.black54 : arrowDisableColor)
          ),
          onPressed: onPrevClick,
        ),

        ...List.generate(showNumbers.length, (index) {
          final num = showNumbers[index];
          //bool isSelected = widget.numbers[currentIndex] == num;
          bool isSelected = currentIndex == startIndex + index;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: GestureDetector(
              onTap: (){
                if(startIndex + index == currentIndex){
                  return;
                }

                onNumberClick(startIndex + index);
              },
              child: AnimatedBuilder(
                animation: animController,
                builder: (_, child) {
                  return CircleContainer(
                    backColor: isSelected? widget.selectedBackColor.withAlpha(alphaAnim.value): widget.defaultBackColor,
                    border: Border.all(style: BorderStyle.none),
                    child: Center(
                        child: Text('$num')
                            .fsR(-2).color(isSelected? widget.selectedTextColor : widget.defaultTextColor)
                    ),
                  );
                },
              ),
            ),
          );
        }),

        IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _canNext()? Colors.black54 : arrowDisableColor),
          onPressed: onNextClick,
        ),
      ],
    );
  }

  bool _canNext(){
    return currentIndex+1 < widget.numbers.length;
  }

  bool _canPrev(){
    return currentIndex > 0;
  }

  void onNextClick() {
    if(!_canNext()){
      return;
    }

    currentIndex++;
    rebuild();
  }

  void onPrevClick() {
    if(!_canPrev()){
      return;
    }

    currentIndex--;
    rebuild();
  }

  void onNumberClick(int index) {
    //currentIndex = widget.numbers.indexOf(index);
    currentIndex = index;
    rebuild();
  }

  void rebuild(){
    init();
    setState(() {});

    animController.reset();
    animController.forward();
    widget.onChange?.call(currentIndex);
  }
}

/*Visibility(
    visible: _canPrev(),
    child: Circle(size: 7, color: widget.defaultColor)
),*/
