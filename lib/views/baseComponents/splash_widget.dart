import 'package:flutter/material.dart';

import 'package:app/system/constants.dart';
import 'package:app/managers/font_manager.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_sizes.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF0A17D), Color(0xFFFFFFFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
            ),
            child: SizedBox.expand(),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            //child: SvgPicture.asset('assets/images/splash.svg', fit: BoxFit.fill, allowDrawingOutsideViewBox: true)
            child: SizedBox(
                height: AppSizes.getScreenHeight(context) * 0.75,
                child: Image.asset(AppImages.logoSplash, fit: BoxFit.fill)
            ),
          ),

          Positioned(
            bottom: 40,
            left: 43,
            right: 43,
            child: Image.asset(AppImages.keyboard, fit: BoxFit.scaleDown),
          ),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ColoredBox(
                color: Colors.white,
                child: SizedBox(
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(' نسخه ی ${Constants.appVersionName}',
                          style: TextStyle(fontFamily: FontManager.instance.defaultFontFor('fa', FontUsage.bold).family)
                      ),
                    )
                ),
              )),
        ],
      ),
    );
  }
}
