import 'package:flutter/material.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/relic/relic.dart';

class RelicSet<Relic> {
  RelicSet({
    required this.trKeyTitle,
    required this.relics,
    this.hasNotification = false,
  });
  final String trKeyTitle;
  final List<Relic> relics;
  bool hasNotification;
}

class RelicSetUI extends StatelessWidget {
  const RelicSetUI(this.relicSet);
  final RelicSet relicSet;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _relicTileHeader(context),
          _relicTileList(context),
        ],
      ),
    );
  }

  Widget _relicTileHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              if (relicSet.hasNotification) _notificationIcon(),
              T(relicSet.trKeyTitle, tsB)
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _relicTileList(BuildContext context) {
    return Column(
      children: List.generate(
        relicSet.relics.length,
        (index) {
          return _relicTile(
            relic: relicSet.relics[index],
            context: context,
            isLastIndex: index == relicSet.relics.length - 1,
          );
        },
      ),
    );
  }

  Widget _relicTile({
    required BuildContext context,
    required bool isLastIndex,
    required Relic relic,
  }) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image(image: AssetImage(relic.asset.filename)),
            T(relic.trValTitle, tsN),
          ],
        ),
        isLastIndex ? const Divider(height: 16.0) : const SizedBox(height: 8.0)
      ],
    );
  }

  Widget _notificationIcon() {
    return Container(
      margin: const EdgeInsets.only(right: 4.0),
      child: const Icon(Icons.whatshot, color: Colors.pink, size: 20.0),
    );
  }

  // Widget _notificationIcon() {
  //   return Container(
  //     child: const Icon(Icons.whatshot, color: Colors.pink, size: 16.0),
  //     padding: const EdgeInsets.all(4.0),
  //     decoration: BoxDecoration(
  //       color: Colors.pink.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(16.0),
  //     ),
  //   );
  // }
}
