import 'package:app/system/extensions.dart';
import 'package:app/views/circle_container.dart';
import 'package:flutter/material.dart';

typedef OnChange = void Function(int index);
///==================================================================================
class PageNumberSelector extends StatefulWidget {
  final Color defaultColor;
  final Color selectColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color? disableColor;
  final OnChange? onChange;
  final int selectIndex;
  final List<int> numbers;

  const PageNumberSelector({
    required this.defaultColor,
    required this.selectColor,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,
    this.selectIndex = 0,
    this.disableColor,
    this.onChange,
    required this.numbers,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _PageNumberSelectorState();
}
///=========================================================================================
class _PageNumberSelectorState extends State<PageNumberSelector> {
  int currentIndex = 0;
  List<int> showNumbers = [];
  late Color disableColor;

  @override
  void initState(){
    super.initState();

    disableColor = widget.disableColor?? Colors.grey.shade300;
    currentIndex = widget.selectIndex;
    init();
  }

  void init(){
    showNumbers.clear();

    if(widget.numbers.length < 6){
      showNumbers.addAll(widget.numbers);
    }
    else {
      final dif = widget.numbers.length - currentIndex;

      if(dif > 5){
        var start = currentIndex;

        if(currentIndex > 0){
          start--;
        }

        for(int i = start; i < start +5; i++){
          showNumbers.add(widget.numbers[i]);
        }
      }
      else {
        final temp = <int>[];
        for(int i = widget.numbers.length-1; i > widget.numbers.length -6; i--){
          temp.add(widget.numbers[i]);
        }

        showNumbers.addAll(temp.reversed.toList());
      }
    }
  }

  @override
  void didUpdateWidget(covariant PageNumberSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    /*if(oldWidget.selectIndex != widget.selectIndex || oldWidget.numbers.length != widget.numbers.length){

    }*/
    currentIndex = widget.selectIndex;
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
              child: Icon(Icons.arrow_back_ios, color: _canPrev()? Colors.black87 : disableColor)
          ),
          onPressed: onPrevClick,
        ),

        /*Visibility(
            visible: _canPrev(),
            child: Circle(size: 7, color: widget.defaultColor)
        ),*/

        ...List.generate(showNumbers.length, (index) {
          final num = showNumbers[index];
          bool isSelected = widget.numbers[currentIndex] == num;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: GestureDetector(
              onTap: (){
                onNumberClick(num);
              },
              child: CircleContainer(
                backColor: isSelected? widget.selectColor: widget.defaultColor,
                border: Border.all(style: BorderStyle.none),
                child: Center(
                    child: Text('$num')
                        .fsR(-2).color(isSelected? widget.selectedTextColor : widget.unselectedTextColor)
                ),
              ),
            ),
          );
        }),

        IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _canNext()? Colors.black87 : disableColor),
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
    init();
    setState(() {});
    widget.onChange?.call(currentIndex);
  }

  void onPrevClick() {
    if(!_canPrev()){
      return;
    }

    currentIndex--;
    init();
    setState(() {});
    widget.onChange?.call(currentIndex);
  }

  void onNumberClick(int num) {
    currentIndex = widget.numbers.indexOf(num);

    init();
    setState(() {});
    widget.onChange?.call(currentIndex);
  }
}