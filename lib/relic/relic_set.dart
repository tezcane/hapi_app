import 'package:flutter/material.dart';
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
  const RelicSetUI({Key? key, required this.relicSet}) : super(key: key);
  final RelicSet relicSet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.cyanAccent.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTileHeader(context),
          _buildFoodTileList(context),
        ],
      ),
    );
  }

  Widget _buildFoodTileList(BuildContext context) {
    return Column(
      children: List.generate(
        relicSet.relics.length,
        (index) {
          bool isLastIndex = index == relicSet.relics.length - 1;
          return _buildRelicTile(
            relic: relicSet.relics[index],
            context: context,
            isLastIndex: isLastIndex,
          );
        },
      ),
    );
  }

  Widget _buildSectionTileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _sectionTitle(context),
        const SizedBox(height: 8.0),
        // relicSet.trKeySubtitle != null
        //     ? _sectionSubtitle(context)
        //     : const SizedBox(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context) {
    return Row(
      children: [
        if (relicSet.hasNotification) _buildSectionHoteSaleIcon(),
        Text(
          relicSet.trKeyTitle,
          style: _textTheme(context).headline6,
        )
      ],
    );
  }

  // Widget _sectionSubtitle(BuildContext context) {
  //   return Text(
  //     relicSet.trKeySubtitle!,
  //     style: _textTheme(context).subtitle2,
  //   );
  // }

  Widget _buildRelicTile({
    required BuildContext context,
    required bool isLastIndex,
    required Relic relic,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRelicDetails(relic: relic, context: context),
            _buildFoodImage(relic.asset.filename),
          ],
        ),
        !isLastIndex ? const Divider(height: 16.0) : const SizedBox(height: 8.0)
      ],
    );
  }

  Widget _buildFoodImage(String url) {
    return FadeInImage.assetNetwork(
      placeholder: 'assets/transparent.png',
      image: url,
      width: 64,
    );
  }

  Widget _buildRelicDetails({
    required BuildContext context,
    required Relic relic,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(relic.trValTitle, style: _textTheme(context).subtitle1),
        // const SizedBox(height: 16),
        // Row(
        //   children: [
        //     // Text(
        //     //   "特價" + relic.price + " ",
        //     //   style: _textTheme(context).caption,
        //     // ),
        //     // Text(
        //     //   relic.comparePrice,
        //     //   style: _textTheme(context)
        //     //       .caption
        //     //       ?.copyWith(decoration: TextDecoration.lineThrough),
        //     // ),
        //     // const SizedBox(width: 8.0),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildSectionHoteSaleIcon() {
    return Container(
      margin: const EdgeInsets.only(right: 4.0),
      child: const Icon(
        Icons.whatshot,
        color: Colors.pink,
        size: 20.0,
      ),
    );
  }

  // Widget _buildFoodHotSaleIcon() {
  //   return Container(
  //     child: const Icon(Icons.whatshot, color: Colors.pink, size: 16.0),
  //     padding: const EdgeInsets.all(4.0),
  //     decoration: BoxDecoration(
  //       color: Colors.pink.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(16.0),
  //     ),
  //   );
  // }

  TextTheme _textTheme(context) => Theme.of(context).textTheme;
}
