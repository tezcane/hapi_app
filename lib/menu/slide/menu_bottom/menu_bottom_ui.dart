import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:share/share.dart';

class MenuBottomUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double iconSize = 40;
    double width = w(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Tooltip(
              message: at('at.About {0}', ['a.hapi']),
              child: InkWell(
                onTap: () {
                  MenuC.to.pushSubPage(SubPage.About);
                  MenuC.to.hideMenu();
                },
                child: Hero(
                  tag: 'hapiLogo',
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Tooltip(
              message: at('at.About {0}', ['a.hapi']),
              child: InkWell(
                onTap: () {
                  MenuC.to.pushSubPage(SubPage.About);
                  MenuC.to.hideMenu();
                },
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
            Tooltip(
              message: 'i.Settings'.tr,
              child: InkWell(
                onTap: () {
                  MenuC.to.pushSubPage(SubPage.Settings);
                  MenuC.to.hideMenu();
                },
                child: const Icon(
                  Icons.settings_rounded,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
            Tooltip(
              message: at('at.Share {0} then share in mountains of rewards!',
                  ['a.hapi']),
              child: InkWell(
                onTap: () => Share.share(
                  a('a.Assalamu Alaykum') +
                      'i.,'.tr + // translate the comma
                      '\n' +
                      'i.Check out this really useful and fun Muslim app!'.tr +
                      ' https://hapi.net',
                ),
                child: const Icon(
                  Icons.share_outlined,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: width / 5),
          ],
        ),
      ),
    );
  }
}
