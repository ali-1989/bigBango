import 'package:flutter/material.dart';

import 'package:animator/animator.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:iris_tools/modules/stateManagers/assistState.dart';

class LayoutComponent extends StatefulWidget {
  final Widget body;
  final Widget drawer;

  const LayoutComponent({
    Key? key,
    required this.body,
    required this.drawer,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LayoutComponentState();
  }
}
///==========================================================================================
class LayoutComponentState extends StateSuper<LayoutComponent> {
  static bool _isOpen = false;
  static bool _withAnimation = false;
  static int _drawerTime = 400;
  static double _drawerWidth = 0;
  static double _lastXOffset = 0;


  @override
  void initState(){
    super.initState();

    _drawerWidth = AppSizes.instance.appWidth;
    _lastXOffset = _drawerWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          widget.body,

          buildDrawer(),
        ],
      ),
    );
  }

  Widget buildDrawer(){

    return WillPopScope(
      onWillPop: () async {
       if(_isOpen){
         hideDrawer();
         return false;
       }

       return true;
      },
      child: AssistBuilder(
        id: AppBroadcast.drawerMenuRefresherId,
        builder: (_, ctr, data){
          return SafeArea(
            top: true,
            child: AnimateWidget(
              resetOnRebuild: false,
              triggerOnInit: true,
              triggerOnRebuild: true,
              lowerBound: 0,
              upperBound: 1,
              repeats: 1,
              cycles: 1,
              duration: Duration(milliseconds: _drawerTime),
              builder: (_, animate){
               if(_withAnimation) {
                 if (_isOpen) {
                   _lastXOffset = animate.fromTween((v) => Tween(begin: _drawerWidth, end: 0.0))!;

                   if(_lastXOffset <= 0){
                     _withAnimation = false;
                   }
                 }
                 else {
                   _lastXOffset = animate.fromTween((v) => Tween(begin: 0.0, end: _drawerWidth))!;

                   if(_lastXOffset >= _drawerWidth){
                     _withAnimation = false;
                   }
                 }
               }

               return Transform.translate(
                  offset: Offset(_lastXOffset, 0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                      hideDrawer();
                    },
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                             /* important: for ignore close drawer when click drawer's surface */
                            },
                            child: widget.drawer
                        )
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  static Future<void> toggleDrawer(){
    if(_isOpen){
      return hideDrawer();
    }
    else {
      return showDrawer();
    }
  }

  static Future<void> showDrawer() async {
    if(_isOpen){
      return;
    }

    _isOpen = true;
    _withAnimation = true;

    AssistController.forId(AppBroadcast.drawerMenuRefresherId)!.update();
    await Future.delayed(Duration(milliseconds: _drawerTime), (){});

    return;
  }

  static Future<void> hideDrawer({int? millSec}) async {
    if(!_isOpen){
      return;
    }

    _isOpen = false;
    _withAnimation = true;

    final old = _drawerTime;
    _drawerTime = millSec?? _drawerTime;

    AssistController.forId(AppBroadcast.drawerMenuRefresherId)!.update();

    await Future.delayed(Duration(milliseconds: _drawerTime), (){});

    if(millSec != null) {
      _drawerTime = old;
    }

    return;
  }
}
