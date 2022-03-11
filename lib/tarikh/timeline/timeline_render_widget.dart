import 'dart:math';
import 'dart:ui' as ui;

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flutter/material.dart';
import 'package:hapi/tarikh/colors.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/ticks.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';
import 'package:intl/intl.dart';
import 'package:nima/nima/math/aabb.dart' as nima;

/// These two callbacks are used to detect if a bubble or an entry have been tapped.
/// If that's the case, [ArticlePage] will be pushed onto the [Navigator] stack.
typedef TouchBubbleCallback = Function(TapTarget? bubble);
typedef TouchEntryCallback = Function(TimelineEntry? entry);

/// This couples with [TimelineRenderObject].
///
/// This widget's fields are accessible from the [RenderBox] so that it can
/// be aligned with the current state.
class TimelineRenderWidget extends LeafRenderObjectWidget {
  const TimelineRenderWidget({
    Key? key,
    required this.topOverlap,
    required this.focusItem,
    required this.touchBubble,
    required this.touchEntry,
    required this.needsRepaint,
  }) : super(key: key);

  final double topOverlap;
  final MenuItemData focusItem;
  final TouchBubbleCallback touchBubble;
  final TouchEntryCallback touchEntry;
  // TODO this is needed or good to have MAYBE?, but not used anywhere now
  // Replaced old way of using timeline null checks
  final bool needsRepaint;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TimelineRenderObject()
      ..touchBubble = touchBubble
      ..touchEntry = touchEntry
      ..focusItem = focusItem
      ..topOverlap = topOverlap
      ..needsRepaint = needsRepaint;
  }

  @override
  // TODO who and when is this called?  needsRepaint needed then?
  void updateRenderObject(
      BuildContext context, covariant TimelineRenderObject renderObject) {
    renderObject
      ..focusItem = focusItem
      ..touchBubble = touchBubble
      ..touchEntry = touchEntry
      ..topOverlap = topOverlap
      ..needsRepaint = needsRepaint;
  }

  // TODO needed?, was originally here:
  @override
  didUnmountRenderObject(covariant TimelineRenderObject renderObject) {
    TarikhController.t.isActive = false;
  }
}

/// A custom renderer is used for the the timeline object.
/// The [Timeline] serves as an abstraction layer for the positioning and advancing logic.
///
/// The core method of this object is [paint()]: this is where all the elements
/// are actually drawn to screen.
class TimelineRenderObject extends RenderBox {
  final TarikhController cTrkh = TarikhController.to; // for speed and less code
  static final Timeline t = TarikhController.t; // for speed and less code

  static const List<Color> LineColors = [
    Color.fromARGB(255, 125, 195, 184),
    Color.fromARGB(255, 190, 224, 146),
    Color.fromARGB(255, 238, 155, 75),
    Color.fromARGB(255, 202, 79, 63),
    Color.fromARGB(255, 128, 28, 15)
  ];

  double _topOverlap = 0.01; //.01 since check below, we use 0.0 by default now
  final Ticks _ticks = Ticks();
  MenuItemData? _focusItem;
  MenuItemData? _processedFocusItem;
  final List<TapTarget> _tapTargets = []; // was List<TapTarget>();
  TouchBubbleCallback? touchBubble;
  TouchEntryCallback? touchEntry;

  bool _needsRepaint = false;

  // Adjust event top/bottom favorite gutter padding here:
  static const double GutterPadTop = 0.0; // set gutter all the way to top
  static const double GutterPadBottom = 60.0; // set gutter above fab

  @override
  bool get sizedByParent => true;

  double get topOverlap => _topOverlap;
  MenuItemData? get focusItem => _focusItem;

  set topOverlap(double value) {
    if (_topOverlap == value) {
      return;
    }
    _topOverlap = value;
    updateFocusItem();
    markNeedsPaint();
    markNeedsLayout();
  }

  //was set timeline(Timeline? value) TODO search old code of any usage of this
  set needsRepaint(bool value) {
    if (_needsRepaint == value) {
      return;
    }
    _needsRepaint = value;
    updateFocusItem();
    t.onNeedPaint = markNeedsPaint;
    markNeedsPaint();
    markNeedsLayout();
  }

  set focusItem(MenuItemData? value) {
    if (_focusItem == value) {
      return;
    }
    _focusItem = value;
    _processedFocusItem = null;
    updateFocusItem();
  }

  /// If [_focusItem] has been updated with a new value, update the current view.
  void updateFocusItem() {
    // TODO asdf btn action here?
    if (_processedFocusItem == _focusItem) {
      return;
    }
    // TODO was also checking timeline == null:
    if (_focusItem == null || topOverlap == 0.0) {
      return;
    }

    /// Adjust the current timeline padding and consequently the viewport.
    if (_focusItem!.pad) {
      t.padding = EdgeInsets.only(
          top: topOverlap + _focusItem!.padTop + Timeline.Parallax,
          bottom: 0.0); //_focusItem!.padBottom);
      t.setViewport(
          start: _focusItem!.start,
          end: _focusItem!.end,
          animate: true,
          pad: true);
    } else {
      t.padding = EdgeInsets.zero;
      t.setViewport(
          start: _focusItem!.start, end: _focusItem!.end, animate: true);
    }
    _processedFocusItem = _focusItem;
  }

  /// Check if the current tap on the screen has hit a bubble.
  @override
  bool hitTestSelf(Offset screenOffset) {
    touchEntry!(null);
    for (TapTarget bubble in _tapTargets.reversed) {
      if (bubble.rect.contains(screenOffset)) {
        if (touchBubble != null) {
          touchBubble!(bubble);
        }
        return true;
      }
    }
    touchBubble!(null);

    return true;
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

  /// Adjust the viewport when needed.
  @override
  void performLayout() {
    t.setViewport(height: size.height, animate: true);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    // if (!_needsRepaint) { // THIS BROKE UI, white screen
    //   return;
    // }
    // _needsRepaint = false;

    /// Fetch the background colors from the [Timeline] and compute the fill.
    List<TimelineBackgroundColor> backgroundColors = t.backgroundColors;
    ui.Paint? backgroundPaint;
    if (backgroundColors.isNotEmpty) {
      double rangeStart = backgroundColors.first.start;
      double range = backgroundColors.last.start - backgroundColors.first.start;
      List<ui.Color> colors = <ui.Color>[];
      List<double> stops = <double>[];
      for (TimelineBackgroundColor bg in backgroundColors) {
        colors.add(bg.color);
        stops.add((bg.start - rangeStart) / range);
      }
      double s = t.computeScale(t.renderStart, t.renderEnd);
      double y1 = (backgroundColors.first.start - t.renderStart) * s;
      double y2 = (backgroundColors.last.start - t.renderStart) * s;

      /// Fill Background.
      backgroundPaint = ui.Paint()
        ..shader = ui.Gradient.linear(
            ui.Offset(0.0, y1), ui.Offset(0.0, y2), colors, stops)
        ..style = ui.PaintingStyle.fill;

      if (y1 > offset.dy) {
        canvas.drawRect(
            Rect.fromLTWH(
                offset.dx, offset.dy, size.width, y1 - offset.dy + 1.0),
            ui.Paint()..color = backgroundColors.first.color);
      }

      /// Draw the background on the canvas.
      canvas.drawRect(
          Rect.fromLTWH(offset.dx, y1, size.width, y2 - y1), backgroundPaint);
    }

    _tapTargets.clear();
    double renderStart = t.renderStart;
    double renderEnd = t.renderEnd;
    double scale = size.height / (renderEnd - renderStart);

    if (t.renderedAssets.isNotEmpty) {
      canvas.save();
      canvas.clipRect(offset & size);
      for (TimelineAsset asset in t.renderedAssets) {
        if (asset.opacity > 0) {
          double rs = 0.2 + asset.scale * 0.8;

          double w = asset.width * Timeline.AssetScreenScale;
          double h = asset.height * Timeline.AssetScreenScale;

          /// Draw the correct asset.
          if (asset is TimelineImage) {
            canvas.drawImageRect(
                asset.image,
                Rect.fromLTWH(0.0, 0.0, asset.width, asset.height),
                Rect.fromLTWH(
                    offset.dx + size.width - w, asset.y, w * rs, h * rs),
                Paint()
                  ..isAntiAlias = true
                  ..filterQuality = ui.FilterQuality.low
                  ..color = Colors.white.withOpacity(asset.opacity));
          } else if (asset is TimelineNima) {
            /// If we have a [TimelineNima] asset, set it up properly and paint it.
            ///
            /// 1. Calculate the bounds for the current object.
            /// An Axis-Aligned Bounding Box (AABB) is already set up when the asset is first loaded.
            /// We rely on this AABB to perform screen-space calculations.
            Alignment alignment = Alignment.center;
            BoxFit fit = BoxFit.cover;

            nima.AABB bounds = asset.setupAABB;

            double contentHeight = bounds[3] - bounds[1];
            double contentWidth = bounds[2] - bounds[0];
            double x = -bounds[0] -
                contentWidth / 2.0 -
                (alignment.x * contentWidth / 2.0) +
                asset.offset;
            double y = -bounds[1] -
                contentHeight / 2.0 +
                (alignment.y * contentHeight / 2.0);

            Offset renderOffset = Offset(offset.dx + size.width - w, asset.y);
            Size renderSize = Size(w * rs, h * rs);

            double scaleX = 1.0, scaleY = 1.0;

            canvas.save();

            /// This widget is always set up to use [BoxFit.cover].
            /// But this behavior can be customized according to anyone's needs.
            /// The following switch/case contains all the various alternatives native to Flutter.
            switch (fit) {
              case BoxFit.fill:
                scaleX = renderSize.width / contentWidth;
                scaleY = renderSize.height / contentHeight;
                break;
              case BoxFit.contain:
                double minScale = min(renderSize.width / contentWidth,
                    renderSize.height / contentHeight);
                scaleX = scaleY = minScale;
                break;
              case BoxFit.cover:
                double maxScale = max(renderSize.width / contentWidth,
                    renderSize.height / contentHeight);
                scaleX = scaleY = maxScale;
                break;
              case BoxFit.fitHeight:
                double minScale = renderSize.height / contentHeight;
                scaleX = scaleY = minScale;
                break;
              case BoxFit.fitWidth:
                double minScale = renderSize.width / contentWidth;
                scaleX = scaleY = minScale;
                break;
              case BoxFit.none:
                scaleX = scaleY = 1.0;
                break;
              case BoxFit.scaleDown:
                double minScale = min(renderSize.width / contentWidth,
                    renderSize.height / contentHeight);
                scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
                break;
            }

            /// 2. Move the [canvas] to the right position so that the widget's position
            /// is center-aligned based on its offset, size and alignment position.
            canvas.translate(
                renderOffset.dx +
                    renderSize.width / 2.0 +
                    (alignment.x * renderSize.width / 2.0),
                renderOffset.dy +
                    renderSize.height / 2.0 +
                    (alignment.y * renderSize.height / 2.0));

            /// 3. Scale depending on the [fit].
            canvas.scale(scaleX, -scaleY);

            /// 4. Move the canvas to the correct [_nimaActor] position calculated above.
            canvas.translate(x, y);

            /// 5. perform the drawing operations.
            asset.actor.draw(canvas, asset.opacity);

            /// 6. Restore the canvas' original transform state.
            canvas.restore();

            /// 7. This asset is also a *tappable* element, add it to the list
            /// so it can be processed.
            _tapTargets.add(TapTarget(asset.entry, renderOffset & renderSize));
          } else if (asset is TimelineFlare) {
            /// If we have a [TimelineFlare] asset set it up properly and paint it.
            ///
            /// 1. Calculate the bounds for the current object.
            /// An Axis-Aligned Bounding Box (AABB) is already set up when the asset is first loaded.
            /// We rely on this AABB to perform screen-space calculations.
            Alignment alignment = Alignment.center;
            BoxFit fit = BoxFit.cover;

            flare.AABB bounds = asset.setupAABB;
            double contentWidth = bounds[2] - bounds[0];
            double contentHeight = bounds[3] - bounds[1];
            double x = -bounds[0] -
                contentWidth / 2.0 -
                (alignment.x * contentWidth / 2.0) +
                asset.offset;
            double y = -bounds[1] -
                contentHeight / 2.0 +
                (alignment.y * contentHeight / 2.0);

            Offset renderOffset = Offset(offset.dx + size.width - w, asset.y);
            Size renderSize = Size(w * rs, h * rs);

            double scaleX = 1.0, scaleY = 1.0;

            canvas.save();

            /// This widget is always set up to use [BoxFit.cover].
            /// But this behavior can be customized according to anyone's needs.
            /// The following switch/case contains all the various alternatives native to Flutter.
            switch (fit) {
              case BoxFit.fill:
                scaleX = renderSize.width / contentWidth;
                scaleY = renderSize.height / contentHeight;
                break;
              case BoxFit.contain:
                double minScale = min(renderSize.width / contentWidth,
                    renderSize.height / contentHeight);
                scaleX = scaleY = minScale;
                break;
              case BoxFit.cover:
                double maxScale = max(renderSize.width / contentWidth,
                    renderSize.height / contentHeight);
                scaleX = scaleY = maxScale;
                break;
              case BoxFit.fitHeight:
                double minScale = renderSize.height / contentHeight;
                scaleX = scaleY = minScale;
                break;
              case BoxFit.fitWidth:
                double minScale = renderSize.width / contentWidth;
                scaleX = scaleY = minScale;
                break;
              case BoxFit.none:
                scaleX = scaleY = 1.0;
                break;
              case BoxFit.scaleDown:
                double minScale = min(renderSize.width / contentWidth,
                    renderSize.height / contentHeight);
                scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
                break;
            }

            /// 2. Move the [canvas] to the right position so that the widget's position
            /// is center-aligned based on its offset, size and alignment position.
            canvas.translate(
                renderOffset.dx +
                    renderSize.width / 2.0 +
                    (alignment.x * renderSize.width / 2.0),
                renderOffset.dy +
                    renderSize.height / 2.0 +
                    (alignment.y * renderSize.height / 2.0));

            /// 3. Scale depending on the [fit].
            canvas.scale(scaleX, scaleY);

            /// 4. Move the canvas to the correct [_flareActor] position calculated above.
            canvas.translate(x, y);

            /// 5. perform the drawing operations.
            asset.actor.modulateOpacity = asset.opacity;
            asset.actor.draw(canvas);

            /// 6. Restore the canvas' original transform state.
            canvas.restore();

            /// 7. This asset is also a *tappable* element, add it to the list
            /// so it can be processed.
            _tapTargets.add(TapTarget(asset.entry, renderOffset & renderSize));
          }
        }
      }
      canvas.restore();
    }

    /// Paint the [Ticks] on the left side of the screen.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        offset.dx, offset.dy + topOverlap, size.width, size.height));
    _ticks.paint(context, offset, -renderStart * scale, scale, size.height, t);
    canvas.restore();

    /// And then draw the rest of the timeline.
    if (t.rootEntries.isNotEmpty) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(offset.dx + t.gutterWidth, offset.dy,
          size.width - t.gutterWidth, size.height));
      drawItems(
          context,
          offset,
          t.rootEntries,
          t.gutterWidth +
              Timeline.LineSpacing -
              Timeline.DepthOffset * t.renderOffsetDepth,
          scale,
          0);
      canvas.restore();
    }

    // Replace two commented out (very large) if statement logic with these two:
    if (t.nextEntry != null && t.nextEntryOpacity > 0.0) {
      cTrkh.setTBtnDn(cTrkh.getTimeBtn(t.nextEntry, t.nextEntryOpacity));
    } else {
      TimeBtn trkhTimeBtn = cTrkh.timeBtnDn.value;
      TimeBtn timeBtnTemp = cTrkh.getTimeBtn(trkhTimeBtn.entry, 1.0);

      // don't update unless we have a new value
      if (trkhTimeBtn.timeUntil != timeBtnTemp.timeUntil ||
          trkhTimeBtn.pageScrolls != timeBtnTemp.pageScrolls) {
        cTrkh.updateTBtnDn(timeBtnTemp.timeUntil, timeBtnTemp.pageScrolls);
      }
    }

    if (t.prevEntry != null && t.prevEntryOpacity > 0.0) {
      cTrkh.setTBtnUp(cTrkh.getTimeBtn(t.prevEntry, t.prevEntryOpacity));
    } else {
      TimeBtn trkhTimeBtn = cTrkh.timeBtnUp.value;
      TimeBtn timeBtnTemp = cTrkh.getTimeBtn(trkhTimeBtn.entry, 1.0);

      // don't update unless we have a new value
      if (trkhTimeBtn.timeUntil != timeBtnTemp.timeUntil ||
          trkhTimeBtn.pageScrolls != timeBtnTemp.pageScrolls) {
        cTrkh.updateTBtnUp(timeBtnTemp.timeUntil, timeBtnTemp.pageScrolls);
      }
    }

    /// After a few moments of inaction on the timeline, if there's enough space,
    /// an arrow pointing to the next event on the timeline will appear on the
    /// bottom of the screen. Draw it, and add it as another [TapTarget].
    // if (t.nextEntry != null && t.nextEntryOpacity > 0.0) {
    //   double x = offset.dx + t.gutterWidth - Timeline.GutterLeft;
    //   double opacity = t.nextEntryOpacity;
    //   Color color = Color.fromRGBO(69, 211, 197, opacity);
    //   double pageSize = (t.renderEnd - t.renderStart);
    //   double pageReference = t.renderEnd;
    //
    //   /// Use a Paragraph to draw the arrow's label and page scrolls on canvas:
    //   /// 1. Create a [ParagraphBuilder] that'll be initialized with the correct styling information;
    //   /// 2. Add some text to the builder;
    //   /// 3. Build the [Paragraph];
    //   /// 4. Lay out the text with custom [ParagraphConstraints].
    //   /// 5. Draw the Paragraph at the right offset.
    //   const double MaxLabelWidth = 1200.0;
    //   ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    //       textAlign: TextAlign.start, fontFamily: "Roboto", fontSize: 20.0))
    //     ..pushStyle(ui.TextStyle(color: color));
    //
    //   builder.addText(t.nextEntry!.label!);
    //   ui.Paragraph labelParagraph = builder.build();
    //   labelParagraph.layout(ui.ParagraphConstraints(width: MaxLabelWidth));
    //
    //   double y = offset.dy + size.height - 200.0;
    //   double labelX =
    //       x + size.width / 2.0 - labelParagraph.maxIntrinsicWidth / 2.0;
    //   canvas.drawParagraph(labelParagraph, Offset(labelX, y));
    //   y += labelParagraph.height;
    //
    //   /// Calculate the boundaries of the arrow icon.
    //   Rect nextEntryRect = Rect.fromLTWH(labelX, y,
    //       labelParagraph.maxIntrinsicWidth, offset.dy + size.height - y);
    //
    //   const double radius = 25.0;
    //   labelX = x + size.width / 2.0;
    //   y += 15 + radius;
    //
    //   /// Draw the background circle.
    //   canvas.drawCircle(
    //       Offset(labelX, y),
    //       radius,
    //       Paint()
    //         ..color = color
    //         ..style = PaintingStyle.fill);
    //   nextEntryRect.expandToInclude(Rect.fromLTWH(
    //       labelX - radius, y - radius, radius * 2.0, radius * 2.0));
    //   Path path = Path();
    //   double arrowSize = 6.0;
    //   double arrowOffset = 1.0;
    //
    //   /// Draw the stylized arrow on top of the circle.
    //   path.moveTo(x + size.width / 2.0 - arrowSize,
    //       y - arrowSize + arrowSize / 2.0 + arrowOffset);
    //   path.lineTo(x + size.width / 2.0, y + arrowSize / 2.0 + arrowOffset);
    //   path.lineTo(x + size.width / 2.0 + arrowSize,
    //       y - arrowSize + arrowSize / 2.0 + arrowOffset);
    //   canvas.drawPath(
    //       path,
    //       Paint()
    //         ..color = Colors.white.withOpacity(opacity)
    //         ..style = PaintingStyle.stroke
    //         ..strokeWidth = 2.0);
    //   y += 15 + radius;
    //
    //   builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    //       textAlign: TextAlign.center,
    //       fontFamily: "Roboto",
    //       fontSize: 14.0,
    //       height: 1.3))
    //     ..pushStyle(ui.TextStyle(color: color));
    //
    //   double timeUntil = t.nextEntry!.start! - pageReference;
    //   double pages = timeUntil / pageSize;
    //   NumberFormat formatter = NumberFormat.compact();
    //   String pagesFormatted = formatter.format(pages);
    //   String until = "in " +
    //       TimelineEntry.formatYears(timeUntil).toLowerCase() +
    //       "\n($pagesFormatted page scrolls)";
    //   builder.addText(until);
    //   labelParagraph = builder.build();
    //   labelParagraph.layout(ui.ParagraphConstraints(width: size.width));
    //
    //   /// Draw the Paragraph beneath the circle.
    //   canvas.drawParagraph(labelParagraph, Offset(x, y));
    //   y += labelParagraph.height;
    //
    //   /// Add this to the list of *tappable* elements.
    //   _tapTargets.add(TapTarget()
    //     ..entry = t.nextEntry!
    //     ..rect = nextEntryRect
    //     ..zoom = true);
    // }
    //
    // /// Repeat the same procedure as above for the arrow pointing to the previous event on the timeline.
    // if (t.prevEntry != null && t.prevEntryOpacity > 0.0) {
    //   double x = offset.dx + t.gutterWidth - Timeline.GutterLeft;
    //   double opacity = t.prevEntryOpacity;
    //   Color color = Color.fromRGBO(69, 211, 197, opacity);
    //   double pageSize = (t.renderEnd - t.renderStart);
    //   double pageReference = t.renderEnd;
    //
    //   const double MaxLabelWidth = 1200.0;
    //   ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    //       textAlign: TextAlign.start, fontFamily: "Roboto", fontSize: 20.0))
    //     ..pushStyle(ui.TextStyle(color: color));
    //
    //   builder.addText(t.prevEntry!.label!);
    //   ui.Paragraph labelParagraph = builder.build();
    //   labelParagraph.layout(ui.ParagraphConstraints(width: MaxLabelWidth));
    //
    //   double y = offset.dy + topOverlap + 20.0;
    //   double labelX =
    //       x + size.width / 2.0 - labelParagraph.maxIntrinsicWidth / 2.0;
    //   canvas.drawParagraph(labelParagraph, Offset(labelX, y));
    //   y += labelParagraph.height;
    //
    //   Rect prevEntryRect = Rect.fromLTWH(labelX, y,
    //       labelParagraph.maxIntrinsicWidth, offset.dy + size.height - y);
    //
    //   const double radius = 25.0;
    //   labelX = x + size.width / 2.0;
    //   y += 15 + radius;
    //   canvas.drawCircle(
    //       Offset(labelX, y),
    //       radius,
    //       Paint()
    //         ..color = color
    //         ..style = PaintingStyle.fill);
    //   prevEntryRect.expandToInclude(Rect.fromLTWH(
    //       labelX - radius, y - radius, radius * 2.0, radius * 2.0));
    //   Path path = Path();
    //   double arrowSize = 6.0;
    //   double arrowOffset = 1.0;
    //   path.moveTo(
    //       x + size.width / 2.0 - arrowSize, y + arrowSize / 2.0 + arrowOffset);
    //   path.lineTo(x + size.width / 2.0, y - arrowSize / 2.0 + arrowOffset);
    //   path.lineTo(
    //       x + size.width / 2.0 + arrowSize, y + arrowSize / 2.0 + arrowOffset);
    //   canvas.drawPath(
    //       path,
    //       Paint()
    //         ..color = Colors.white.withOpacity(opacity)
    //         ..style = PaintingStyle.stroke
    //         ..strokeWidth = 2.0);
    //   y += 15 + radius;
    //
    //   builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    //       textAlign: TextAlign.center,
    //       fontFamily: "Roboto",
    //       fontSize: 14.0,
    //       height: 1.3))
    //     ..pushStyle(ui.TextStyle(color: color));
    //
    //   double timeUntil = t.prevEntry!.start! - pageReference;
    //   double pages = timeUntil / pageSize;
    //   NumberFormat formatter = NumberFormat.compact();
    //   String pagesFormatted = formatter.format(pages.abs());
    //   String until = TimelineEntry.formatYears(timeUntil).toLowerCase() +
    //       " ago\n($pagesFormatted page scrolls)";
    //   builder.addText(until);
    //   labelParagraph = builder.build();
    //   labelParagraph.layout(ui.ParagraphConstraints(width: size.width));
    //   canvas.drawParagraph(labelParagraph, Offset(x, y));
    //   y += labelParagraph.height;
    //
    //   _tapTargets.add(TapTarget()
    //     ..entry = t.prevEntry!
    //     ..rect = prevEntryRect
    //     ..zoom = true);
    // }

    /// When the user presses the heart outline/heart/close button on the bottom
    /// left corner of the timeline, a gutter on the left side shows up so that
    /// favorite or all history elements are quickly accessible.
    ///
    /// Here the gutter is drawn and elements are added as *tappable* targets.
    List<TimelineEntry> events = cTrkh.favorites;
    if (cTrkh.isGutterModeAll()) {
      events = cTrkh.allEvents;
    }

    if (!cTrkh.isGutterModeOff() && events.isNotEmpty) {
      Paint accentPaint = Paint()
        ..color = eventsGutterAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      Paint accentFill = Paint()
        ..color = eventsGutterAccent
        ..style = PaintingStyle.fill;
      Paint whitePaint = Paint()..color = Colors.white;
      double scale = t.computeScale(t.renderStart, t.renderEnd);
      double fullMargin = 50.0;
      double eventRadius = 26.0; //was 20
      double fullMarginOffset = fullMargin + eventRadius + 16.5; //was 11.0
      double x = offset.dx -
          fullMargin +
          (t.gutterWidth - Timeline.GutterLeft) /
              (Timeline.GutterLeftExpanded - Timeline.GutterLeft) *
              fullMarginOffset;

      double padEvents = 20.0;

      /// Order events by distance from mid.
      List<TimelineEntry> nearbyEvents = List<TimelineEntry>.from(events);
      double mid = t.renderStart + (t.renderEnd - t.renderStart) / 2.0;
      nearbyEvents.sort((TimelineEntry a, TimelineEntry b) {
        return (a.start - mid).abs().compareTo((b.start - mid).abs());
      });

      /// layout events.
      for (int i = 0; i < nearbyEvents.length; i++) {
        TimelineEntry event = nearbyEvents[i];
        double y = ((event.start - t.renderStart) * scale).clamp(
            offset.dy +
                eventRadius +
                padEvents +
                GutterPadTop, //was also + topOverlap
            offset.dy +
                size.height -
                eventRadius -
                padEvents -
                GutterPadBottom);
        event.gutterEventY = y;

        /// Check all closer events to see if this one is occluded by a previous closer one.
        /// Works because we sorted by distance.
        event.isGutterEventOccluded = false;
        for (int j = 0; j < i; j++) {
          TimelineEntry closer = nearbyEvents[j];
          if ((event.gutterEventY - closer.gutterEventY).abs() <= 1.0) {
            event.isGutterEventOccluded = true;
            break;
          }
        }
      }

      /// Iterate the list from the bottom.
      for (TimelineEntry event in nearbyEvents.reversed) {
        if (event.isGutterEventOccluded) {
          continue;
        }
        double y = event.gutterEventY;

        /// Draw the event circle in the gutter for this item.
        canvas.drawCircle(
            Offset(x, y),
            eventRadius,
            backgroundPaint ?? Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(x, y), eventRadius, accentPaint);
        canvas.drawCircle(Offset(x, y), eventRadius - 4.0, whitePaint);

        TimelineAsset asset = event.asset;
        double assetSize = 40.0 - 8.0;
        Size renderSize = Size(assetSize, assetSize);
        Offset renderOffset = Offset(x - assetSize / 2.0, y - assetSize / 2.0);

        Alignment alignment = Alignment.center;
        BoxFit fit = BoxFit.cover;

        /// Draw the assets statically within the circle.
        /// Calculations here are the same as seen in [paint()] for the assets.
        if (asset is TimelineNima) {
          nima.AABB bounds = asset.setupAABB;

          double contentHeight = bounds[3] - bounds[1];
          double contentWidth = bounds[2] - bounds[0];
          double x = -bounds[0] -
              contentWidth / 2.0 -
              (alignment.x * contentWidth / 2.0) +
              asset.offset;
          double y = -bounds[1] -
              contentHeight / 2.0 +
              (alignment.y * contentHeight / 2.0);

          double scaleX = 1.0, scaleY = 1.0;

          canvas.save();
          canvas.clipRRect(RRect.fromRectAndRadius(
              renderOffset & renderSize, Radius.circular(eventRadius)));

          switch (fit) {
            case BoxFit.fill:
              scaleX = renderSize.width / contentWidth;
              scaleY = renderSize.height / contentHeight;
              break;
            case BoxFit.contain:
              double minScale = min(renderSize.width / contentWidth,
                  renderSize.height / contentHeight);
              scaleX = scaleY = minScale;
              break;
            case BoxFit.cover:
              double maxScale = max(renderSize.width / contentWidth,
                  renderSize.height / contentHeight);
              scaleX = scaleY = maxScale;
              break;
            case BoxFit.fitHeight:
              double minScale = renderSize.height / contentHeight;
              scaleX = scaleY = minScale;
              break;
            case BoxFit.fitWidth:
              double minScale = renderSize.width / contentWidth;
              scaleX = scaleY = minScale;
              break;
            case BoxFit.none:
              scaleX = scaleY = 1.0;
              break;
            case BoxFit.scaleDown:
              double minScale = min(renderSize.width / contentWidth,
                  renderSize.height / contentHeight);
              scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
              break;
          }

          canvas.translate(
              renderOffset.dx +
                  renderSize.width / 2.0 +
                  (alignment.x * renderSize.width / 2.0),
              renderOffset.dy +
                  renderSize.height / 2.0 +
                  (alignment.y * renderSize.height / 2.0));
          canvas.scale(scaleX, -scaleY);
          canvas.translate(x, y);

          asset.actorStatic.draw(canvas);
          canvas.restore();
          _tapTargets.add(
              TapTarget(asset.entry, renderOffset & renderSize, zoom: true));
        } else if (asset is TimelineFlare) {
          flare.AABB bounds = asset.setupAABB;
          double contentWidth = bounds[2] - bounds[0];
          double contentHeight = bounds[3] - bounds[1];
          double x = -bounds[0] -
              contentWidth / 2.0 -
              (alignment.x * contentWidth / 2.0) +
              asset.offset;
          double y = -bounds[1] -
              contentHeight / 2.0 +
              (alignment.y * contentHeight / 2.0);

          double scaleX = 1.0, scaleY = 1.0;

          canvas.save();
          canvas.clipRRect(RRect.fromRectAndRadius(
              renderOffset & renderSize, Radius.circular(eventRadius)));

          switch (fit) {
            case BoxFit.fill:
              scaleX = renderSize.width / contentWidth;
              scaleY = renderSize.height / contentHeight;
              break;
            case BoxFit.contain:
              double minScale = min(renderSize.width / contentWidth,
                  renderSize.height / contentHeight);
              scaleX = scaleY = minScale;
              break;
            case BoxFit.cover:
              double maxScale = max(renderSize.width / contentWidth,
                  renderSize.height / contentHeight);
              scaleX = scaleY = maxScale;
              break;
            case BoxFit.fitHeight:
              double minScale = renderSize.height / contentHeight;
              scaleX = scaleY = minScale;
              break;
            case BoxFit.fitWidth:
              double minScale = renderSize.width / contentWidth;
              scaleX = scaleY = minScale;
              break;
            case BoxFit.none:
              scaleX = scaleY = 1.0;
              break;
            case BoxFit.scaleDown:
              double minScale = min(renderSize.width / contentWidth,
                  renderSize.height / contentHeight);
              scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
              break;
          }

          canvas.translate(
              renderOffset.dx +
                  renderSize.width / 2.0 +
                  (alignment.x * renderSize.width / 2.0),
              renderOffset.dy +
                  renderSize.height / 2.0 +
                  (alignment.y * renderSize.height / 2.0));
          canvas.scale(scaleX, scaleY);
          canvas.translate(x, y);

          asset.actorStatic.draw(canvas);
          canvas.restore();
          _tapTargets.add(
              TapTarget(asset.entry, renderOffset & renderSize, zoom: true));
        } else {
          _tapTargets.add(
              TapTarget(asset.entry, renderOffset & renderSize, zoom: true));
        }
      }

      /// If there are two or more events in the gutter, show a line connecting
      /// the two circles, with the time between those two events as a label
      /// within a bubble.
      ///
      /// Uses same [ui.ParagraphBuilder] logic as seen above.
      TimelineEntry? previous;
      for (TimelineEntry event in events) {
        if (event.isGutterEventOccluded) {
          continue;
        }
        if (previous != null) {
          double distance = (event.gutterEventY - previous.gutterEventY);
          if (distance > eventRadius * 2.0) {
            canvas.drawLine(Offset(x, previous.gutterEventY + eventRadius),
                Offset(x, event.gutterEventY - eventRadius), accentPaint);
            double labelY = previous.gutterEventY + distance / 2.0;
            double labelWidth = 37.0;
            double labelHeight = 8.5 * 2.0;
            if (distance - eventRadius * 2.0 > labelHeight) {
              ui.ParagraphBuilder builder = ui.ParagraphBuilder(
                  ui.ParagraphStyle(
                      textAlign: TextAlign.center,
                      fontFamily: "RobotoMedium",
                      fontSize: 10.0))
                ..pushStyle(ui.TextStyle(color: Colors.white));

              int value = (event.start - previous.start).round().abs();
              String label;
              if (value < 9000) {
                label = value.toStringAsFixed(0);
              } else {
                NumberFormat formatter = NumberFormat.compact();
                label = formatter.format(value);
              }

              builder.addText(label);
              ui.Paragraph distanceParagraph = builder.build();
              distanceParagraph
                  .layout(ui.ParagraphConstraints(width: labelWidth));

              canvas.drawRRect(
                  RRect.fromRectAndRadius(
                      Rect.fromLTWH(x - labelWidth / 2.0,
                          labelY - labelHeight / 2.0, labelWidth, labelHeight),
                      Radius.circular(labelHeight)),
                  accentFill);
              canvas.drawParagraph(
                  distanceParagraph,
                  Offset(x - labelWidth / 2.0,
                      labelY - distanceParagraph.height / 2.0));
            }
          }
        }
        previous = event;
      }
    }
  }

  /// Given a list of [entries], draw the label with its bubble beneath.
  /// Draw also the dots&lines on the left side of the timeline. These represent
  /// the starting/ending points for a given event and are meant to give the idea of
  /// the timespan encompassing that event, as well as putting the vent into context
  /// relative to the other events.
  void drawItems(PaintingContext context, Offset offset,
      List<TimelineEntry> entries, double x, double scale, int depth) {
    final Canvas canvas = context.canvas;

    for (TimelineEntry item in entries) {
      if (!item.isVisible ||
          item.y > size.height + Timeline.BubbleHeight ||
          item.endY < -Timeline.BubbleHeight) {
        /// Don't paint this item.
        continue;
      }

      double legOpacity = item.legOpacity * item.opacity;
      Offset entryOffset = Offset(x + Timeline.LineWidth / 2.0, item.y);

      /// Draw the small circle on the left side of the timeline.
      canvas.drawCircle(
          entryOffset,
          Timeline.EdgeRadius,
          Paint()
            ..color = (item.accent != null
                    ? item.accent!
                    : LineColors[depth % LineColors.length])
                .withOpacity(item.opacity));
      if (legOpacity > 0.0) {
        Paint legPaint = Paint()
          ..color = (item.accent != null
                  ? item.accent!
                  : LineColors[depth % LineColors.length])
              .withOpacity(legOpacity);

        /// Draw the line connecting the start&point of this item on the timeline.
        canvas.drawRect(
            Offset(x, item.y) & Size(Timeline.LineWidth, item.length),
            legPaint);
        canvas.drawCircle(
            Offset(x + Timeline.LineWidth / 2.0, item.y + item.length),
            Timeline.EdgeRadius,
            legPaint);
      }

      const double MaxLabelWidth = 1200.0;
      const double BubblePadding = 20.0;

      /// Let the timeline calculate the height for the current item's bubble.
      double bubbleHeight = t.bubbleHeight(item);

      /// Use [ui.ParagraphBuilder] to construct the label for canvas.
      ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.start, fontFamily: "Roboto", fontSize: 20.0))
        ..pushStyle(
            ui.TextStyle(color: const Color.fromRGBO(255, 255, 255, 1.0)));

      builder.addText(item.label);
      ui.Paragraph labelParagraph = builder.build();
      labelParagraph
          .layout(const ui.ParagraphConstraints(width: MaxLabelWidth));

      double textWidth =
          labelParagraph.maxIntrinsicWidth * item.opacity * item.labelOpacity;
      double bubbleX =
          t.renderLabelX - Timeline.DepthOffset * t.renderOffsetDepth;
      double bubbleY = item.labelY - bubbleHeight / 2.0;

      canvas.save();
      canvas.translate(bubbleX, bubbleY);

      /// Get the bubble's path based on its width&height, draw it, and then add the label on top.
      Path bubble =
          makeBubblePath(textWidth + BubblePadding * 2.0, bubbleHeight);

      canvas.drawPath(
          bubble,
          Paint()
            ..color = (item.accent != null
                    ? item.accent!
                    : LineColors[depth % LineColors.length])
                .withOpacity(item.opacity * item.labelOpacity));
      canvas
          .clipRect(Rect.fromLTWH(BubblePadding, 0.0, textWidth, bubbleHeight));
      _tapTargets.add(
        TapTarget(
          item,
          Rect.fromLTWH(
              bubbleX, bubbleY, textWidth + BubblePadding * 2.0, bubbleHeight),
        ),
      );

      canvas.drawParagraph(
          labelParagraph,
          Offset(
              BubblePadding, bubbleHeight / 2.0 - labelParagraph.height / 2.0));
      canvas.restore();
      if (item.children != null) {
        /// Draw the other elements in the hierarchy.
        drawItems(context, offset, item.children!, x + Timeline.DepthOffset,
            scale, depth + 1);
      }
    }
  }

  /// Given a width and a height, design a path for the bubble that lies behind events' labels
  /// on the timeline, and return it.
  Path makeBubblePath(double width, double height) {
    const double ArrowSize = 19.0;
    const double CornerRadius = 10.0;

    const double circularConstant = 0.55;
    const double icircularConstant = 1.0 - circularConstant;

    Path path = Path();

    path.moveTo(CornerRadius, 0.0);
    path.lineTo(width - CornerRadius, 0.0);
    path.cubicTo(width - CornerRadius + CornerRadius * circularConstant, 0.0,
        width, CornerRadius * icircularConstant, width, CornerRadius);
    path.lineTo(width, height - CornerRadius);
    path.cubicTo(
        width,
        height - CornerRadius + CornerRadius * circularConstant,
        width - CornerRadius * icircularConstant,
        height,
        width - CornerRadius,
        height);
    path.lineTo(CornerRadius, height);
    path.cubicTo(CornerRadius * icircularConstant, height, 0.0,
        height - CornerRadius * icircularConstant, 0.0, height - CornerRadius);

    path.lineTo(0.0, height / 2.0 + ArrowSize / 2.0);
    path.lineTo(-ArrowSize / 2.0, height / 2.0);
    path.lineTo(0.0, height / 2.0 - ArrowSize / 2.0);

    path.lineTo(0.0, CornerRadius);

    path.cubicTo(0.0, CornerRadius * icircularConstant,
        CornerRadius * icircularConstant, 0.0, CornerRadius, 0.0);

    path.close();

    return path;
  }
}
