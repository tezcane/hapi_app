import 'dart:math';
import 'dart:ui' as ui;

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_c.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/timeline/ticks.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';
import 'package:intl/intl.dart';
import 'package:nima/nima/math/aabb.dart' as nima;

import '../event/event_asset.dart';

/// These two callbacks are used to detect if a bubble or an event have been tapped.
/// If that's the case, [ArticlePage] will be pushed onto the [Navigator] stack.
typedef TouchBubbleCallback = Function(TapTarget? bubble);
typedef TouchEventCallback = Function(Event? event);

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
    required this.touchEvent,
    required this.needsRepaint,
  }) : super(key: key);

  final double topOverlap;
  final MenuItemData focusItem;
  final TouchBubbleCallback touchBubble;
  final TouchEventCallback touchEvent;

  /// Tez: Replaced old way of using timeline null checks
  final bool needsRepaint;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TimelineRenderObject()
      ..touchBubble = touchBubble
      ..touchEvent = touchEvent
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
      ..touchEvent = touchEvent
      ..topOverlap = topOverlap
      ..needsRepaint = needsRepaint;
  }

  @override
  didUnmountRenderObject(covariant TimelineRenderObject renderObject) {
    TarikhC.to.isActiveTimeline = false;
  }
}

/// A custom renderer is used for the the timeline object.
/// The [Timeline] serves as an abstraction layer for the positioning and advancing logic.
///
/// The core method of this object is [paint()]: this is where all the elements
/// are actually drawn to screen.
class TimelineRenderObject extends RenderBox {
  final TarikhC cTrkh = TarikhC.to;
  static final Timeline t = TarikhC.t;
  static final TimelineInitHandler tih = TarikhC.tih;

  static const List<Color> LineColors = [
    Color.fromARGB(255, 125, 195, 184),
    Color.fromARGB(255, 190, 224, 146),
    Color.fromARGB(255, 238, 155, 75),
    Color.fromARGB(255, 202, 79, 63),
    Color.fromARGB(255, 128, 28, 15)
  ];

  static const double MaxLabelWidth = 1200.0;
  static const double BubblePadding = 20.0;

  static const double fullMargin = 50.0;
  static const double eventRadius = 26.0; // was 20.0
  static const double padEvents = 25.0; // was 20.0

  static final Paint accentPaint = Paint()
    ..color = AppThemes.eventsGutterAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  static final Paint accentFill = Paint()
    ..color = AppThemes.eventsGutterAccent
    ..style = PaintingStyle.fill;
  static final Paint whitePaint = Paint()..color = Colors.white;

  double _topOverlap = 0.01; //.01 since check below, we use 0.0 by default now
  final Ticks _ticks = Ticks();
  MenuItemData? _focusItem;
  MenuItemData? _processedFocusItem;
  final List<TapTarget> _tapTargets = []; // was List<TapTarget>();
  TouchBubbleCallback? touchBubble;
  TouchEventCallback? touchEvent;

  bool _needsRepaint = false;

  // Adjust event top/bottom favorite gutter padding here:
  static const double GutterPadTop = 0.0; // set gutter all the way to top
  static const double GutterPadBottom = 60.0; // set gutter above fab

  @override
  bool get sizedByParent => true;

  double get topOverlap => _topOverlap;
  MenuItemData? get focusItem => _focusItem;

  set topOverlap(double value) {
    if (_topOverlap == value) return;
    _topOverlap = value;
    updateFocusItem();
    markNeedsPaint();
    markNeedsLayout();
  }

  /// Tez: was set timeline(Timeline? value) TODO search old code of any usage of this
  set needsRepaint(bool value) {
    if (_needsRepaint == value) return;
    _needsRepaint = value;
    updateFocusItem();
    t.onNeedPaint = markNeedsPaint;
    markNeedsPaint();
    markNeedsLayout();
  }

  set focusItem(MenuItemData? value) {
    if (_focusItem == value) return;
    _focusItem = value;
    _processedFocusItem = null;
    updateFocusItem();
  }

  /// If [_focusItem] has been updated with a new value, update the current view.
  void updateFocusItem() {
    if (_processedFocusItem == _focusItem) return;
    // Tez: was also checking timeline == null:
    if (_focusItem == null || topOverlap == 0.0) return;

    /// Adjust the current timeline padding and consequently the viewport.
    if (_focusItem!.pad) {
      t.padding = EdgeInsets.only(
          top: topOverlap + _focusItem!.padTop + Timeline.Parallax,
          bottom: 0.0); //_focusItem!.padBottom);
      t.setViewport(
          start: _focusItem!.startMs,
          end: _focusItem!.endMs,
          animate: true,
          pad: true);
    } else {
      t.padding = EdgeInsets.zero;
      t.setViewport(
          start: _focusItem!.startMs, end: _focusItem!.endMs, animate: true);
    }
    _processedFocusItem = _focusItem;
  }

  /// Check if the current tap on the screen has hit a bubble.
  @override
  bool hitTestSelf(Offset screenOffset) {
    touchEvent!(null);
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
  void performResize() => size = constraints.biggest;

  /// Adjust the viewport when needed.
  @override
  void performLayout() => t.setViewport(height: size.height, animate: true);

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    // if (!_needsRepaint) { // THIS BROKE UI, white screen
    //   return;
    // }
    // _needsRepaint = false;

    /// Fetch the background colors from the [Timeline] and compute the fill.
    List<TimelineBackgroundColor> backgroundColors = tih.backgroundColors;
    ui.Paint? backgroundPaint;
    if (backgroundColors.isNotEmpty) {
      double rangeStart = backgroundColors.first.startMs;
      double range =
          backgroundColors.last.startMs - backgroundColors.first.startMs;
      List<ui.Color> colors = <ui.Color>[];
      List<double> stops = <double>[];
      for (TimelineBackgroundColor bg in backgroundColors) {
        colors.add(bg.color);
        stops.add((bg.startMs - rangeStart) / range);
      }
      double s = t.computeScale(t.renderStart, t.renderEnd);
      double y1 = (backgroundColors.first.startMs - t.renderStart) * s;
      double y2 = (backgroundColors.last.startMs - t.renderStart) * s;

      /// Fill Background.
      backgroundPaint = ui.Paint()
        ..shader = ui.Gradient.linear(
          ui.Offset(0.0, y1),
          ui.Offset(0.0, y2),
          colors,
          stops,
        )
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
      for (EventAsset asset in t.renderedAssets) {
        if (asset.opacity > 0) {
          double rs = 0.2 + asset.scale * 0.8;

          double w = asset.width * Timeline.AssetScreenScale;
          double h = asset.height * Timeline.AssetScreenScale;

          /// Draw the correct asset.
          if (asset is ImageAsset) {
            canvas.drawImageRect(
              asset.image,
              Rect.fromLTWH(0.0, 0.0, asset.width, asset.height),
              Rect.fromLTWH(
                  offset.dx + size.width - w, asset.y, w * rs, h * rs),
              Paint()
                ..isAntiAlias = true
                ..filterQuality = ui.FilterQuality.low
                ..color = Colors.white.withOpacity(asset.opacity),
            );
          } else if (asset is NimaAsset) {
            /// If we have a [TimelineNima] asset, set it up properly and paint it.
            ///
            /// 1. Calculate the bounds for the current object.
            /// An Axis-Aligned Bounding Box (AABB) is already set up when the asset is first loaded.
            /// We rely on this AABB to perform screen-space calculations.
            Alignment alignment = Alignment.center;
            // BoxFit fit = BoxFit.cover;

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
            // switch (fit) {
            //   case BoxFit.fill:
            //     scaleX = renderSize.width / contentWidth;
            //     scaleY = renderSize.height / contentHeight;
            //     break;
            //   case BoxFit.contain:
            //     double minScale = min(renderSize.width / contentWidth,
            //         renderSize.height / contentHeight);
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.cover:
            double maxScale = max(renderSize.width / contentWidth,
                renderSize.height / contentHeight);
            scaleX = scaleY = maxScale;
            //     break;
            //   case BoxFit.fitHeight:
            //     double minScale = renderSize.height / contentHeight;
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.fitWidth:
            //     double minScale = renderSize.width / contentWidth;
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.none:
            //     scaleX = scaleY = 1.0;
            //     break;
            //   case BoxFit.scaleDown:
            //     double minScale = min(renderSize.width / contentWidth,
            //         renderSize.height / contentHeight);
            //     scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
            //     break;
            // }

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
            _tapTargets.add(TapTarget(asset.event, renderOffset & renderSize));
          } else if (asset is FlareAsset) {
            /// If we have a [TimelineFlare] asset set it up properly and paint it.
            ///
            /// 1. Calculate the bounds for the current object.
            /// An Axis-Aligned Bounding Box (AABB) is already set up when the asset is first loaded.
            /// We rely on this AABB to perform screen-space calculations.
            Alignment alignment = Alignment.center;
            // BoxFit fit = BoxFit.cover;

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
            // switch (fit) {
            //   case BoxFit.fill:
            //     scaleX = renderSize.width / contentWidth;
            //     scaleY = renderSize.height / contentHeight;
            //     break;
            //   case BoxFit.contain:
            //     double minScale = min(renderSize.width / contentWidth,
            //         renderSize.height / contentHeight);
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.cover:
            double maxScale = max(renderSize.width / contentWidth,
                renderSize.height / contentHeight);
            scaleX = scaleY = maxScale;
            //     break;
            //   case BoxFit.fitHeight:
            //     double minScale = renderSize.height / contentHeight;
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.fitWidth:
            //     double minScale = renderSize.width / contentWidth;
            //     scaleX = scaleY = minScale;
            //     break;
            //   case BoxFit.none:
            //     scaleX = scaleY = 1.0;
            //     break;
            //   case BoxFit.scaleDown:
            //     double minScale = min(renderSize.width / contentWidth,
            //         renderSize.height / contentHeight);
            //     scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
            //     break;
            // }

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
            _tapTargets.add(TapTarget(asset.event, renderOffset & renderSize));
          }
        }
      }
      canvas.restore();
    }

    /// Paint the [Ticks] on the left side of the screen.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        offset.dx, offset.dy + topOverlap, size.width, size.height));
    _ticks.paint(context, offset, -renderStart * scale, scale, size.height);
    canvas.restore();

    /// And then draw the rest of the timeline.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(offset.dx + t.gutterWidth, offset.dy,
        size.width - t.gutterWidth, size.height));
    drawItems(
        context,
        offset,
        tih.rootEvents,
        t.gutterWidth +
            Timeline.LineSpacing -
            Timeline.DepthOffset * t.renderOffsetDepth,
        scale,
        0);
    canvas.restore();

    // Replace two commented out (very large) if statement logic with these two:
    if (t.nextEvent != null) {
      // && t.nextEventOpacity > 0.0) {
      cTrkh.updateEventBtn(cTrkh.timeBtnDn, t.nextEvent);
    } else {
      TimeBtn timeBtn = cTrkh.timeBtnDn;
      String timeUntil = timeBtn.trValTimeUntil;
      String pageScrolls = timeBtn.trValPageScrolls;
      String title = timeBtn.trValTitle;

      // don't update unless we have a new value
      if (timeBtn.trValTimeUntil != timeUntil ||
          timeBtn.trValPageScrolls != pageScrolls ||
          timeBtn.trValTitle != title) {
        cTrkh.updateTimeBtn(timeBtn, title, timeUntil, pageScrolls);
      }
    }

    if (t.prevEvent != null) {
      // && t.prevEventOpacity > 0.0) {
      cTrkh.updateEventBtn(cTrkh.timeBtnUp, t.prevEvent);
    } else {
      TimeBtn timeBtn = cTrkh.timeBtnUp;
      String timeUntil = timeBtn.trValTimeUntil;
      String pageScrolls = timeBtn.trValPageScrolls;
      String title = timeBtn.trValTitle;

      // don't update unless we have a new value
      if (timeBtn.trValTimeUntil != timeUntil ||
          timeBtn.trValPageScrolls != pageScrolls ||
          timeBtn.trValTitle != title) {
        cTrkh.updateTimeBtn(timeBtn, title, timeUntil, pageScrolls);
      }
    }

    // Fixes bug where if we drag the timeline beyond first or last event both
    // up and down buttons show the first/last event.
    if (cTrkh.timeBtnUp.event != null && cTrkh.timeBtnDn.event != null) {
      String upLabel = cTrkh.timeBtnUp.event!.trKeyTitle;
      if (upLabel == cTrkh.timeBtnDn.event!.trKeyTitle) {
        if (upLabel == TR_KEY_OLDEST) {
          l.d('***************** TOO HIGH FIXING ************************');
          cTrkh.updateEventBtn(cTrkh.timeBtnUp, null);
        } else {
          l.d('***************** TOO LOW FIXING ************************');
          cTrkh.updateEventBtn(cTrkh.timeBtnDn, null);
        }
      }
    }

    /// After a few moments of inaction on the timeline, if there's enough space,
    /// an arrow pointing to the next event on the timeline will appear on the
    /// bottom of the screen. Draw it, and add it as another [TapTarget].
    // if (t.nextEvent != null && t.nextEventOpacity > 0.0) {
    //   double x = offset.dx + t.gutterWidth - Timeline.GutterLeft;
    //   double opacity = t.nextEventOpacity;
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
    //       textAlign: TextAlign.start, fontFamily: 'Roboto', fontSize: 20.0))
    //     ..pushStyle(ui.TextStyle(color: color));
    //
    //   builder.addText(t.nextEvent!.label!);
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
    //   Rect nextEventRect = Rect.fromLTWH(labelX, y,
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
    //   nextEventRect.expandToInclude(Rect.fromLTWH(
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
    //       fontFamily: 'Roboto',
    //       fontSize: 14.0,
    //       height: 1.3))
    //     ..pushStyle(ui.TextStyle(color: color));
    //
    //   double timeUntil = t.nextEvent!.start! - pageReference;
    //   double pages = timeUntil / pageSize;
    //   NumberFormat formatter = NumberFormat.compact();
    //   String pagesFormatted = formatter.format(pages);
    //   String until = 'in ' +
    //       Event.formatYears(timeUntil).toLowerCase() +
    //       '\n($pagesFormatted page scrolls)';
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
    //     ..event = t.nextEvent!
    //     ..rect = nextEventRect
    //     ..zoom = true);
    // }
    //
    // /// Repeat the same procedure as above for the arrow pointing to the previous event on the timeline.
    // if (t.prevEvent != null && t.prevEventOpacity > 0.0) {
    //   double x = offset.dx + t.gutterWidth - Timeline.GutterLeft;
    //   double opacity = t.prevEventOpacity;
    //   Color color = Color.fromRGBO(69, 211, 197, opacity);
    //   double pageSize = (t.renderEnd - t.renderStart);
    //   double pageReference = t.renderEnd;
    //
    //   const double MaxLabelWidth = 1200.0;
    //   ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    //       textAlign: TextAlign.start, fontFamily: 'Roboto', fontSize: 20.0))
    //     ..pushStyle(ui.TextStyle(color: color));
    //
    //   builder.addText(t.prevEvent!.label!);
    //   ui.Paragraph labelParagraph = builder.build();
    //   labelParagraph.layout(ui.ParagraphConstraints(width: MaxLabelWidth));
    //
    //   double y = offset.dy + topOverlap + 20.0;
    //   double labelX =
    //       x + size.width / 2.0 - labelParagraph.maxIntrinsicWidth / 2.0;
    //   canvas.drawParagraph(labelParagraph, Offset(labelX, y));
    //   y += labelParagraph.height;
    //
    //   Rect prevEventRect = Rect.fromLTWH(labelX, y,
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
    //   prevEventRect.expandToInclude(Rect.fromLTWH(
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
    //       fontFamily: 'Roboto',
    //       fontSize: 14.0,
    //       height: 1.3))
    //     ..pushStyle(ui.TextStyle(color: color));
    //
    //   double timeUntil = t.prevEvent!.start! - pageReference;
    //   double pages = timeUntil / pageSize;
    //   NumberFormat formatter = NumberFormat.compact();
    //   String pagesFormatted = formatter.format(pages.abs());
    //   String until = Event.formatYears(timeUntil).toLowerCase() +
    //       ' ago\n($pagesFormatted page scrolls)';
    //   builder.addText(until);
    //   labelParagraph = builder.build();
    //   labelParagraph.layout(ui.ParagraphConstraints(width: size.width));
    //   canvas.drawParagraph(labelParagraph, Offset(x, y));
    //   y += labelParagraph.height;
    //
    //   _tapTargets.add(TapTarget()
    //     ..event = t.prevEvent!
    //     ..rect = prevEventRect
    //     ..zoom = true);
    // }

    /// When the user presses the heart outline/heart/close button on the bottom
    /// left corner of the timeline, a gutter on the left side shows up so that
    /// favorite or all history elements are quickly accessible.
    ///
    /// Here the gutter is drawn and elements are added as *tappable* targets.
    List<Event> events = cTrkh.isGutterModeAll
        ? EventC.to.getEventList(EVENT_TYPE.Incident)
        : EventC.to.getEventListFav(EVENT_TYPE.Incident);

    if (!cTrkh.isGutterModeOff && events.isNotEmpty) {
      double scale = t.computeScale(t.renderStart, t.renderEnd);
      double fullMarginOffset = fullMargin + eventRadius + 16.5; //was 11.0
      double x = offset.dx -
          fullMargin +
          (t.gutterWidth - Timeline.GutterLeft) /
              (Timeline.GutterLeftExpanded - Timeline.GutterLeft) *
              fullMarginOffset;

      /// Order events by distance from mid.
      List<Event> nearbyEvents = List<Event>.from(events);
      double mid = t.renderStart + (t.renderEnd - t.renderStart) / 2.0;
      nearbyEvents.sort((Event a, Event b) {
        return (a.startMs - mid).abs().compareTo((b.startMs - mid).abs());
      });

      /// layout events.
      for (int i = 0; i < nearbyEvents.length; i++) {
        Event event = nearbyEvents[i];
        double y = ((event.startMs - t.renderStart) * scale).clamp(
          offset.dy + eventRadius + padEvents + GutterPadTop, //had + topOverlap
          offset.dy + size.height - eventRadius - padEvents - GutterPadBottom,
        );
        event.gutterEventY = y;

        /// Check all closer events to see if this one is occluded by a previous
        /// closer one. Works because we sorted by distance.
        event.isGutterEventOccluded = false;
        for (int j = 0; j < i; j++) {
          Event closer = nearbyEvents[j];
          if ((event.gutterEventY - closer.gutterEventY).abs() <= 1.0) {
            event.isGutterEventOccluded = true;
            break;
          }
        }
      }

      /// Iterate the list from the bottom.
      for (Event event in nearbyEvents.reversed) {
        if (event.isGutterEventOccluded) continue;

        double y = event.gutterEventY;

        /// Draw the event circle in the gutter for this item.
        canvas.drawCircle(
          Offset(x, y),
          eventRadius,
          backgroundPaint ?? Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(Offset(x, y), eventRadius, accentPaint);
        canvas.drawCircle(
          Offset(x, y),
          eventRadius - 1.0, // was -4.0
          whitePaint,
        );

        EventAsset asset = event.asset;
        double assetSize = 50.0; // was 40.0 -8.0
        Size renderSize = Size(assetSize, assetSize);
        Offset renderOffset = Offset(x - assetSize / 2.0, y - assetSize / 2.0);

        Alignment alignment = Alignment.center;
        // BoxFit fit = BoxFit.cover;

        /// Draw the assets statically within the circle.
        /// Calculations here are the same as seen in [paint()] for the assets.
        if (asset is ImageAsset) {
          canvas.drawImageRect(
            asset.image,
            Rect.fromLTWH(0.0, 0.0, asset.width, asset.height),
            Rect.fromLTWH(
              renderOffset.dx +
                  // renderSize.width / 2.0 +
                  (alignment.x * renderSize.width / 2.0),
              renderOffset.dy +
                  // renderSize.height / 2.0 +
                  (alignment.y * renderSize.height / 2.0) -
                  .3, // added this, TODO find math solution instead of customizing for Adam.
              51.5, // was 32
              51.5, // was 32
            ),
            Paint()
              ..isAntiAlias = true
              ..filterQuality = ui.FilterQuality.low
              ..color = Colors.white.withOpacity(asset.opacity),
          );
          _tapTargets.add(
            TapTarget(asset.event, renderOffset & renderSize, zoom: true),
          );
        } else if (asset is NimaAsset) {
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
          canvas.clipRRect(
            RRect.fromRectAndRadius(
              renderOffset & renderSize,
              const Radius.circular(eventRadius),
            ),
          );

          // switch (fit) {
          //   case BoxFit.fill:
          //     scaleX = renderSize.width / contentWidth;
          //     scaleY = renderSize.height / contentHeight;
          //     break;
          //   case BoxFit.contain:
          //     double minScale = min(renderSize.width / contentWidth,
          //         renderSize.height / contentHeight);
          //     scaleX = scaleY = minScale;
          //     break;
          //   case BoxFit.cover:
          double maxScale = max(renderSize.width / contentWidth,
              renderSize.height / contentHeight);
          scaleX = scaleY = maxScale;
          //     break;
          //   case BoxFit.fitHeight:
          //     double minScale = renderSize.height / contentHeight;
          //     scaleX = scaleY = minScale;
          //     break;
          //   case BoxFit.fitWidth:
          //     double minScale = renderSize.width / contentWidth;
          //     scaleX = scaleY = minScale;
          //     break;
          //   case BoxFit.none:
          //     scaleX = scaleY = 1.0;
          //     break;
          //   case BoxFit.scaleDown:
          //     double minScale = min(renderSize.width / contentWidth,
          //         renderSize.height / contentHeight);
          //     scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
          //     break;
          // }

          canvas.translate(
            renderOffset.dx +
                renderSize.width / 2.0 +
                (alignment.x * renderSize.width / 2.0),
            renderOffset.dy +
                renderSize.height / 2.0 +
                (alignment.y * renderSize.height / 2.0),
          );
          canvas.scale(scaleX, -scaleY);
          canvas.translate(x, y);

          asset.actorStatic.draw(canvas);
          canvas.restore();
          _tapTargets.add(
            TapTarget(asset.event, renderOffset & renderSize, zoom: true),
          );
        } else if (asset is FlareAsset) {
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
          canvas.clipRRect(
            RRect.fromRectAndRadius(
              renderOffset & renderSize,
              const Radius.circular(eventRadius),
            ),
          );

          // switch (fit) {
          //   case BoxFit.fill:
          //     scaleX = renderSize.width / contentWidth;
          //     scaleY = renderSize.height / contentHeight;
          //     break;
          //   case BoxFit.contain:
          //     double minScale = min(renderSize.width / contentWidth,
          //         renderSize.height / contentHeight);
          //     scaleX = scaleY = minScale;
          //     break;
          //   case BoxFit.cover:
          double maxScale = max(
            renderSize.width / contentWidth,
            renderSize.height / contentHeight,
          );
          scaleX = scaleY = maxScale;
          //     break;
          //   case BoxFit.fitHeight:
          //     double minScale = renderSize.height / contentHeight;
          //     scaleX = scaleY = minScale;
          //     break;
          //   case BoxFit.fitWidth:
          //     double minScale = renderSize.width / contentWidth;
          //     scaleX = scaleY = minScale;
          //     break;
          //   case BoxFit.none:
          //     scaleX = scaleY = 1.0;
          //     break;
          //   case BoxFit.scaleDown:
          //     double minScale = min(renderSize.width / contentWidth,
          //         renderSize.height / contentHeight);
          //     scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
          //     break;
          // }

          canvas.translate(
            renderOffset.dx +
                renderSize.width / 2.0 +
                (alignment.x * renderSize.width / 2.0),
            renderOffset.dy +
                renderSize.height / 2.0 +
                (alignment.y * renderSize.height / 2.0),
          );
          canvas.scale(scaleX, scaleY);
          canvas.translate(x, y);

          asset.actorStatic.draw(canvas);
          canvas.restore();
          _tapTargets.add(
            TapTarget(asset.event, renderOffset & renderSize, zoom: true),
          );
        }
      }

      /// If there are two or more events in the gutter, show a line connecting
      /// the two circles, with the time between those two events as a label
      /// within a bubble.
      ///
      /// Uses same [ui.ParagraphBuilder] logic as seen above.
      Event? previous;
      for (Event event in events) {
        if (event.isGutterEventOccluded) continue;

        if (previous != null) {
          double distance = (event.gutterEventY - previous.gutterEventY);
          if (distance > eventRadius * 2.0) {
            canvas.drawLine(
              Offset(x, previous.gutterEventY + eventRadius),
              Offset(x, event.gutterEventY - eventRadius),
              accentPaint,
            );
            double labelY = previous.gutterEventY + distance / 2.0;
            double labelWidth = 37.0;
            double labelHeight = 8.5 * 2.0;
            if (distance - eventRadius * 2.0 > labelHeight) {
              ui.ParagraphBuilder builder = ui.ParagraphBuilder(
                ui.ParagraphStyle(
                  textAlign: TextAlign.center,
                  fontFamily: 'Roboto',
                  fontSize: 10.0,
                ),
              )..pushStyle(ui.TextStyle(color: Colors.white));

              int value = (event.startMs - previous.startMs).round().abs();
              String label;
              if (value < 10000) {
                label = value.toStringAsFixed(0);
              } else {
                NumberFormat formatter = LanguageC.numCompactFormatter;
                label = formatter.format(value);
              }

              // This is the text in the pink circle between gutter events
              builder.addText(cns(label));
              ui.Paragraph distanceParagraph = builder.build();
              distanceParagraph.layout(
                ui.ParagraphConstraints(width: labelWidth),
              );

              canvas.drawRRect(
                RRect.fromRectAndRadius(
                  Rect.fromLTWH(
                    x - labelWidth / 2.0,
                    labelY - labelHeight / 2.0,
                    labelWidth,
                    labelHeight,
                  ),
                  Radius.circular(labelHeight),
                ),
                accentFill,
              );
              canvas.drawParagraph(
                distanceParagraph,
                Offset(
                  x - labelWidth / 2.0,
                  labelY - distanceParagraph.height / 2.0,
                ),
              );
            }
          }
        }
        previous = event;
      }
    }
  }

  /// Given a list of [events], draw the label with its bubble beneath.
  /// Draw also the dots&lines on the left side of the timeline. These represent
  /// the starting/ending points for a given event and are meant to give the
  /// idea of the time span encompassing that event, as well as putting the vent
  /// into context relative to the other events.
  void drawItems(
    PaintingContext context,
    Offset offset,
    List<Event> events,
    double x,
    double scale,
    int depth,
  ) {
    final Canvas canvas = context.canvas;

    // TODO rename item->event
    for (Event item in events) {
      /// Don't paint this item if:
      if (!item.isVisible ||
          item.y > size.height + Timeline.BubbleHeight ||
          item.endY < -Timeline.BubbleHeight) continue;

      double legOpacity = item.legOpacity * item.opacity;
      Offset eventOffset = Offset(x + Timeline.LineWidth / 2.0, item.y);

      /// Draw the small circle on the left side of the timeline.
      canvas.drawCircle(
          eventOffset,
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
          legPaint,
        );
        canvas.drawCircle(
          Offset(x + Timeline.LineWidth / 2.0, item.y + item.length),
          Timeline.EdgeRadius,
          legPaint,
        );
      }

      /// Let the timeline calculate the height for the current item's bubble.
      double bubbleHeight = t.bubbleHeight(item);

      /// Use [ui.ParagraphBuilder] to construct the label for canvas.
      ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(textAlign: TextAlign.start, fontSize: 20.0),
      )..pushStyle(
          ui.TextStyle(
            color: const Color.fromRGBO(255, 255, 255, 1.0),
          ),
        );

      /// Write bubble text here:
      builder.addText(item.tvBubbleText);
      ui.Paragraph labelParagraph = builder.build();
      labelParagraph.layout(
        const ui.ParagraphConstraints(width: MaxLabelWidth),
      );

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
              .withOpacity(item.opacity * item.labelOpacity),
      );
      canvas.clipRect(
        Rect.fromLTWH(BubblePadding, 0.0, textWidth, bubbleHeight),
      );
      _tapTargets.add(
        TapTarget(
          item,
          Rect.fromLTWH(
            bubbleX,
            bubbleY,
            textWidth + BubblePadding * 2.0,
            bubbleHeight,
          ),
        ),
      );

      canvas.drawParagraph(
        labelParagraph,
        Offset(BubblePadding, bubbleHeight / 2.0 - labelParagraph.height / 2.0),
      );
      canvas.restore();
      if (item.children != null) {
        /// Draw the other elements in the hierarchy.
        drawItems(
          context,
          offset,
          item.children!,
          x + Timeline.DepthOffset,
          scale,
          depth + 1,
        );
      }
    }
  }

  /// Given a width and a height, design a path for the bubble that lies behind events' labels
  /// on the timeline, and return it.
  Path makeBubblePath(double width, double height) {
    const double ArrowSize = 19.0;
    const double CornerRadius = 10.0;

    const double circularConstant = 0.55;
    const double iCircularConstant = 1.0 - circularConstant;

    Path path = Path();

    path.moveTo(CornerRadius, 0.0);
    path.lineTo(width - CornerRadius, 0.0);
    path.cubicTo(
      width - CornerRadius + CornerRadius * circularConstant,
      0.0,
      width,
      CornerRadius * iCircularConstant,
      width,
      CornerRadius,
    );
    path.lineTo(width, height - CornerRadius);
    path.cubicTo(
      width,
      height - CornerRadius + CornerRadius * circularConstant,
      width - CornerRadius * iCircularConstant,
      height,
      width - CornerRadius,
      height,
    );
    path.lineTo(CornerRadius, height);
    path.cubicTo(
      CornerRadius * iCircularConstant,
      height,
      0.0,
      height - CornerRadius * iCircularConstant,
      0.0,
      height - CornerRadius,
    );

    path.lineTo(0.0, height / 2.0 + ArrowSize / 2.0);
    path.lineTo(-ArrowSize / 2.0, height / 2.0);
    path.lineTo(0.0, height / 2.0 - ArrowSize / 2.0);

    path.lineTo(0.0, CornerRadius);

    path.cubicTo(
      0.0,
      CornerRadius * iCircularConstant,
      CornerRadius * iCircularConstant,
      0.0,
      CornerRadius,
      0.0,
    );

    path.close();

    return path;
  }
}
