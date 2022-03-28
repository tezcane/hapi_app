import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hapi/components/sticky_sliver/sticky_sliver.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

/// A sliver with a [RenderBox] as header and a [RenderSliver] as child.
///
/// The [header] stays pinned when it hits the start of the viewport until
/// the [child] scrolls off the viewport.
class RenderSliverStickyHeader extends RenderSliver with RenderSliverHelpers {
  RenderSliverStickyHeader({
    RenderObject? header,
    RenderSliver? child,
    bool overlapsContent = false,
    bool sticky = true,
    StickyHeaderController? controller,
  })  : _overlapsContent = overlapsContent,
        _sticky = sticky,
        _controller = controller {
    this.header = header as RenderBox?;
    this.child = child;
  }

  SliverStickyHeaderState? _oldState;
  double? _headerExtent;
  late bool _isPinned;

  bool get overlapsContent => _overlapsContent;
  bool _overlapsContent;

  set overlapsContent(bool value) {
    if (_overlapsContent == value) return;
    _overlapsContent = value;
    markNeedsLayout();
  }

  bool get sticky => _sticky;
  bool _sticky;

  set sticky(bool value) {
    if (_sticky == value) return;
    _sticky = value;
    markNeedsLayout();
  }

  StickyHeaderController? get controller => _controller;
  StickyHeaderController? _controller;

  set controller(StickyHeaderController? value) {
    if (_controller == value) return;
    if (_controller != null && value != null) {
      // We copy the state of the old controller.
      value.stickyHeaderScrollOffset = _controller!.stickyHeaderScrollOffset;
    }
    _controller = value;
  }

  /// The render object's header
  RenderBox? get header => _header;
  RenderBox? _header;

  set header(RenderBox? value) {
    if (_header != null) dropChild(_header!);
    _header = value;
    if (_header != null) adoptChild(_header!);
  }

  /// The render object's unique child
  RenderSliver? get child => _child;
  RenderSliver? _child;

  set child(RenderSliver? value) {
    if (_child != null) dropChild(_child!);
    _child = value;
    if (_child != null) adoptChild(_child!);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_header != null) _header!.attach(owner);
    if (_child != null) _child!.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (_header != null) _header!.detach();
    if (_child != null) _child!.detach();
  }

  @override
  void redepthChildren() {
    if (_header != null) redepthChild(_header!);
    if (_child != null) redepthChild(_child!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_header != null) visitor(_header!);
    if (_child != null) visitor(_child!);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    List<DiagnosticsNode> result = <DiagnosticsNode>[];
    if (header != null) {
      result.add(header!.toDiagnosticsNode(name: 'header'));
    }
    if (child != null) {
      result.add(child!.toDiagnosticsNode(name: 'child'));
    }
    return result;
  }

  double computeHeaderExtent() {
    if (header == null) return 0.0;
    assert(header!.hasSize);
    switch (constraints.axis) {
      case Axis.vertical:
        return header!.size.height;
      case Axis.horizontal:
        return header!.size.width;
    }
  }

  double? get headerLogicalExtent => overlapsContent ? 0.0 : _headerExtent;

  @override
  void performLayout() {
    if (header == null && child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    // One of them is not null.
    AxisDirection axisDirection = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection);

    if (header != null) {
      header!.layout(
        BoxValueConstraints<SliverStickyHeaderState>(
          value: _oldState ?? const SliverStickyHeaderState(0.0, false),
          constraints: constraints.asBoxConstraints(),
        ),
        parentUsesSize: true,
      );
      _headerExtent = computeHeaderExtent();
    }

    // Compute the header extent only one time.
    double headerExtent = headerLogicalExtent!;
    final double headerPaintExtent =
        calculatePaintOffset(constraints, from: 0.0, to: headerExtent);
    final double headerCacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: headerExtent);

    if (child == null) {
      geometry = SliverGeometry(
          scrollExtent: headerExtent,
          maxPaintExtent: headerExtent,
          paintExtent: headerPaintExtent,
          cacheExtent: headerCacheExtent,
          hitTestExtent: headerPaintExtent,
          hasVisualOverflow: headerExtent > constraints.remainingPaintExtent ||
              constraints.scrollOffset > 0.0);
    } else {
      child!.layout(
        constraints.copyWith(
          scrollOffset: math.max(0.0, constraints.scrollOffset - headerExtent),
          cacheOrigin: math.min(0.0, constraints.cacheOrigin + headerExtent),
          overlap: 0.0,
          remainingPaintExtent:
              constraints.remainingPaintExtent - headerPaintExtent,
          remainingCacheExtent:
              constraints.remainingCacheExtent - headerCacheExtent,
        ),
        parentUsesSize: true,
      );
      final SliverGeometry childLayoutGeometry = child!.geometry!;
      if (childLayoutGeometry.scrollOffsetCorrection != null) {
        geometry = SliverGeometry(
          scrollOffsetCorrection: childLayoutGeometry.scrollOffsetCorrection,
        );
        return;
      }

      final double paintExtent = math.min(
        headerPaintExtent +
            math.max(childLayoutGeometry.paintExtent,
                childLayoutGeometry.layoutExtent),
        constraints.remainingPaintExtent,
      );

      geometry = SliverGeometry(
        scrollExtent: headerExtent + childLayoutGeometry.scrollExtent,
        paintExtent: paintExtent,
        layoutExtent: math.min(
            headerPaintExtent + childLayoutGeometry.layoutExtent, paintExtent),
        cacheExtent: math.min(
            headerCacheExtent + childLayoutGeometry.cacheExtent,
            constraints.remainingCacheExtent),
        maxPaintExtent: headerExtent + childLayoutGeometry.maxPaintExtent,
        hitTestExtent: math.max(
            headerPaintExtent + childLayoutGeometry.paintExtent,
            headerPaintExtent + childLayoutGeometry.hitTestExtent),
        hasVisualOverflow: childLayoutGeometry.hasVisualOverflow,
      );

      final SliverPhysicalParentData? childParentData =
          child!.parentData as SliverPhysicalParentData?;
      switch (axisDirection) {
        case AxisDirection.up:
          childParentData!.paintOffset = Offset.zero;
          break;
        case AxisDirection.right:
          childParentData!.paintOffset = Offset(
              calculatePaintOffset(constraints, from: 0.0, to: headerExtent),
              0.0);
          break;
        case AxisDirection.down:
          childParentData!.paintOffset = Offset(0.0,
              calculatePaintOffset(constraints, from: 0.0, to: headerExtent));
          break;
        case AxisDirection.left:
          childParentData!.paintOffset = Offset.zero;
          break;
      }
    }

    if (header != null) {
      final SliverPhysicalParentData? headerParentData =
          header!.parentData as SliverPhysicalParentData?;
      final double childScrollExtent = child?.geometry?.scrollExtent ?? 0.0;
      final double headerPosition = sticky
          ? math.min(
              constraints.overlap,
              childScrollExtent -
                  constraints.scrollOffset -
                  (overlapsContent ? _headerExtent! : 0.0))
          : -constraints.scrollOffset;

      _isPinned = sticky &&
          ((constraints.scrollOffset + constraints.overlap) > 0.0 ||
              constraints.remainingPaintExtent ==
                  constraints.viewportMainAxisExtent);

      final double headerScrollRatio =
          ((headerPosition - constraints.overlap).abs() / _headerExtent!);
      if (_isPinned && headerScrollRatio <= 1) {
        controller?.stickyHeaderScrollOffset =
            constraints.precedingScrollExtent;
      }
      // second layout if scroll percentage changed and header is a
      // RenderStickyHeaderLayoutBuilder.
      if (header is RenderConstrainedLayoutBuilder<
          BoxValueConstraints<SliverStickyHeaderState>, RenderBox>) {
        double headerScrollRatioClamped = headerScrollRatio.clamp(0.0, 1.0);

        SliverStickyHeaderState state =
            SliverStickyHeaderState(headerScrollRatioClamped, _isPinned);
        if (_oldState != state) {
          _oldState = state;
          header!.layout(
            BoxValueConstraints<SliverStickyHeaderState>(
              value: _oldState!,
              constraints: constraints.asBoxConstraints(),
            ),
            parentUsesSize: true,
          );
        }
      }

      switch (axisDirection) {
        case AxisDirection.up:
          headerParentData!.paintOffset = Offset(
              0.0, geometry!.paintExtent - headerPosition - _headerExtent!);
          break;
        case AxisDirection.down:
          headerParentData!.paintOffset = Offset(0.0, headerPosition);
          break;
        case AxisDirection.left:
          headerParentData!.paintOffset = Offset(
              geometry!.paintExtent - headerPosition - _headerExtent!, 0.0);
          break;
        case AxisDirection.right:
          headerParentData!.paintOffset = Offset(headerPosition, 0.0);
          break;
      }
    }
  }

/*
  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final double maxExtent = this.maxExtent;
    final bool overlapsContent = constraints.overlap > 0.0;
    layoutChild(constraints.scrollOffset, maxExtent,
        overlapsContent: overlapsContent);
    final double effectiveRemainingPaintExtent =
    math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = (maxExtent - constraints.scrollOffset)
        .clamp(0.0, effectiveRemainingPaintExtent);
    final double stretchOffset =
    stretchConfiguration != null ? constraints.overlap.abs() : 0.0;
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: maxExtent + stretchOffset,
      maxScrollObstructionExtent: minExtent,
      cacheExtent: layoutExtent > 0.0
          ? -constraints.cacheOrigin + layoutExtent
          : layoutExtent,
      hasVisualOverflow:
      true, // Conservatively say we do have overflow to avoid complexity.
    );
  }
*/
  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    assert(geometry!.hitTestExtent > 0.0);
    if (header != null &&
        mainAxisPosition - constraints.overlap <= _headerExtent!) {
      return hitTestBoxChild(
            BoxHitTestResult.wrap(SliverHitTestResult.wrap(result)),
            header!,
            mainAxisPosition: mainAxisPosition - constraints.overlap,
            crossAxisPosition: crossAxisPosition,
          ) ||
          (_overlapsContent &&
              child != null &&
              child!.geometry!.hitTestExtent > 0.0 &&
              child!.hitTest(result,
                  mainAxisPosition:
                      mainAxisPosition - childMainAxisPosition(child),
                  crossAxisPosition: crossAxisPosition));
    } else if (child != null && child!.geometry!.hitTestExtent > 0.0) {
      return child!.hitTest(result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(child),
          crossAxisPosition: crossAxisPosition);
    }
    return false;
  }

/*
  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    assert(geometry!.hitTestExtent > 0.0);
    if (child != null)
      return hitTestBoxChild(BoxHitTestResult.wrap(result), child!,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition);
    return false;
  }
*/
  @override
  double childMainAxisPosition(RenderObject? child) {
    if (child == header) {
      return _isPinned
          ? 0.0
          : -(constraints.scrollOffset + constraints.overlap);
    }
    if (child == this.child) {
      return calculatePaintOffset(constraints,
          from: 0.0, to: headerLogicalExtent!);
    }
    return 0;
  }

/*
  /// Returns the distance from the leading _visible_ edge of the sliver to the
  /// side of the child closest to that edge, in the scroll axis direction.
  ///
  /// For example, if the [constraints] describe this sliver as having an axis
  /// direction of [AxisDirection.down], then this is the distance from the top
  /// of the visible portion of the sliver to the top of the child. If the child
  /// is scrolled partially off the top of the viewport, then this will be
  /// negative. On the other hand, if the [constraints] describe this sliver as
  /// having an axis direction of [AxisDirection.up], then this is the distance
  /// from the bottom of the visible portion of the sliver to the bottom of the
  /// child. In both cases, this is the direction of increasing
  /// [SliverConstraints.scrollOffset].
  ///
  /// Calling this when the child is not visible is not valid.
  ///
  /// The argument must be the value of the [child] property.
  ///
  /// This must be implemented by [RenderSliverPersistentHeader] subclasses.
  ///
  /// If there is no child, this should return 0.0.
  @override
  double childMainAxisPosition(covariant RenderObject child) => 0.0;
*/

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    if (child == this.child) {
      return _headerExtent;
    } else {
      return super.childScrollOffset(child);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final SliverPhysicalParentData childParentData =
        child.parentData as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

/*
  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child != null);
    assert(child == this.child);
    applyPaintTransformForBoxChild(child as RenderBox, transform);
  }
*/
  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      if (child != null && child!.geometry!.visible) {
        final SliverPhysicalParentData childParentData =
            child!.parentData as SliverPhysicalParentData;
        context.paintChild(child!, offset + childParentData.paintOffset);
      }

      // The header must be drawn over the sliver.
      if (header != null) {
        final SliverPhysicalParentData headerParentData =
            header!.parentData as SliverPhysicalParentData;
        context.paintChild(header!, offset + headerParentData.paintOffset);
      }
    }
  }
/* from pinned:
  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      assert(constraints.axisDirection != null);
      switch (applyGrowthDirectionToAxisDirection(
          constraints.axisDirection, constraints.growthDirection)) {
        case AxisDirection.up:
          offset += Offset(
              0.0,
              geometry!.paintExtent -
                  childMainAxisPosition(child!) -
                  childExtent);
          break;
        case AxisDirection.down:
          offset += Offset(0.0, childMainAxisPosition(child!));
          break;
        case AxisDirection.left:
          offset += Offset(
              geometry!.paintExtent -
                  childMainAxisPosition(child!) -
                  childExtent,
              0.0);
          break;
        case AxisDirection.right:
          offset += Offset(childMainAxisPosition(child!), 0.0);
          break;
      }
      context.paintChild(child!, offset);
    }
  }
*/
  // @override
  // void paint(PaintingContext context, Offset offset) {
  //   if (geometry!.visible) {
  //     // if (child != null && child!.geometry!.visible) {
  //     //   final SliverPhysicalParentData childParentData =
  //     //       child!.parentData as SliverPhysicalParentData;
  //     //   context.paintChild(child!, offset + childParentData.paintOffset);
  //     // }
  //
  //     // The header must be drawn over the sliver.
  //     if (header != null) {
  //       final SliverPhysicalParentData headerParentData =
  //           header!.parentData as SliverPhysicalParentData;
  //
  //       Offset offsets = offset + headerParentData.paintOffset;
  //
  //       var headerSize = const Size(0, 120);
  //       if (offsets.dy >= headerSize.height) {
  //         context.paintChild(header!, offsets);
  //         double dy = offset.dy;
  //         l.v('${headerSize.height}: > $dy ${offset.dy}');
  //       } else {
  //         double adjust = math.min(headerSize.height - offsets.dy, 32);
  //         Offset offsets2 = Offset(offsets.dx, headerSize.height - adjust);
  //         double dy = (offsets).dy;
  //         l.v('${headerSize.height}: <= $dy ${offsets2.dy}');
  //         context.paintChild(header!, offsets2);
  //       }
  //     }
  //   }
  // }
/*
  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      if (child != null) {
        final SliverPhysicalParentData childParentData =
        child!.parentData as SliverPhysicalParentData;

        Offset offsets = offset + childParentData.paintOffset;
        if (offsets.dy >= headerSize.height) {
          context.paintChild(child!, offsets);
          double dy = offset.dy;
          l.v('${headerSize.height}: > $dy ${offset.dy}');
        } else {
          double adjust = min(headerSize.height - offsets.dy, 32);
          Offset offsets2 = Offset(offsets.dx, headerSize.height - adjust);
          double dy = (offsets).dy;
          l.v('${headerSize.height}: <= $dy ${offsets2.dy}');
          context.paintChild(child!, offsets2); // childParentData.paintOffset);
        }
      }
    }
    //super.paint(context, offset);
  }
 */

  /// Specifies the persistent header's behavior when `showOnScreen` is called.
  ///
  /// If set to null, the persistent header will delegate the `showOnScreen` call
  /// to it's parent [RenderObject].
  PersistentHeaderShowOnScreenConfiguration? showOnScreenConfiguration;

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    final Rect? localBounds = descendant != null
        ? MatrixUtils.transformRect(
            descendant.getTransformTo(this), rect ?? descendant.paintBounds)
        : rect;

    Rect? newRect;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        newRect = _trim(localBounds, bottom: childExtent);
        break;
      case AxisDirection.right:
        newRect = _trim(localBounds, left: 0);
        break;
      case AxisDirection.down:
        newRect = _trim(localBounds, top: 0);
        break;
      case AxisDirection.left:
        newRect = _trim(localBounds, right: childExtent);
        break;
    }

    super.showOnScreen(
      descendant: this,
      rect: newRect,
      duration: duration,
      curve: curve,
    );
  }

  late double _lastStretchOffset;

  /// The biggest that this render object can become, in the main axis direction.
  ///
  /// This value should not be based on the child. If it changes, call
  /// [markNeedsLayout].
  double maxExtent = 32;

  /// The smallest that this render object can become, in the main axis direction.
  ///
  /// If this is based on the intrinsic dimensions of the child, the child
  /// should be measured during [updateChild] and the value cached and returned
  /// here. The [updateChild] method will automatically be invoked any time the
  /// child changes its intrinsic dimensions.
  double minExtent = 32;

  /// The dimension of the child in the main axis.
  @protected
  double get childExtent {
    if (header == null) return 0.0;
    assert(header!.hasSize);
    assert(constraints.axis != null);
    switch (constraints.axis) {
      case Axis.vertical:
        return header!.size.height;
      case Axis.horizontal:
        return header!.size.width;
    }
  }

  bool _needsUpdateChild = true;
  double _lastShrinkOffset = 0.0;
  bool _lastOverlapsContent = false;

  /// Defines the parameters used to execute an [AsyncCallback] when a
  /// stretching header over-scrolls.
  ///
  /// If [stretchConfiguration] is null then callback is not triggered.
  ///
  /// See also:
  ///
  ///  * [SliverAppBar], which creates a header that can stretched into an
  ///    overscroll area and trigger a callback function.
  OverScrollHeaderStretchConfiguration? stretchConfiguration;

  /// Update the child render object if necessary.
  ///
  /// Called before the first layout, any time [markNeedsLayout] is called, and
  /// any time the scroll offset changes. The `shrinkOffset` is the difference
  /// between the [maxExtent] and the current size. Zero means the header is
  /// fully expanded, any greater number up to [maxExtent] means that the header
  /// has been scrolled by that much. The `overlapsContent` argument is true if
  /// the sliver's leading edge is beyond its normal place in the viewport
  /// contents, and false otherwise. It may still paint beyond its normal place
  /// if the [minExtent] after this call is greater than the amount of space that
  /// would normally be left.
  ///
  /// The render object will size itself to the larger of (a) the [maxExtent]
  /// minus the child's intrinsic height and (b) the [maxExtent] minus the
  /// shrink offset.
  ///
  /// When this method is called by [layoutChild], the [child] can be set,
  /// mutated, or replaced. (It should not be called outside [layoutChild].)
  ///
  /// Any time this method would mutate the child, call [markNeedsLayout].
  @protected
  void updateChild(double shrinkOffset, bool overlapsContent) {}

  @override
  void markNeedsLayout() {
    // This is automatically called whenever the child's intrinsic dimensions
    // change, at which point we should remeasure them during the next layout.
    _needsUpdateChild = true;
    super.markNeedsLayout();
  }

  /// Lays out the [child].
  ///
  /// This is called by [performLayout]. It applies the given `scrollOffset`
  /// (which need not match the offset given by the [constraints]) and the
  /// `maxExtent` (which need not match the value returned by the [maxExtent]
  /// getter).
  ///
  /// The `overlapsContent` argument is passed to [updateChild].
  @protected
  void layoutChild(double scrollOffset, double maxExtent,
      {bool overlapsContent = false}) {
    assert(maxExtent != null);
    final double shrinkOffset = math.min(scrollOffset, maxExtent);
    if (_needsUpdateChild ||
        _lastShrinkOffset != shrinkOffset ||
        _lastOverlapsContent != overlapsContent) {
      invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
        assert(constraints == this.constraints);
        updateChild(shrinkOffset, overlapsContent);
      });
      _lastShrinkOffset = shrinkOffset;
      _lastOverlapsContent = overlapsContent;
      _needsUpdateChild = false;
    }
    assert(minExtent != null);
    assert(() {
      if (minExtent <= maxExtent) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
            'The maxExtent for this $runtimeType is less than its minExtent.'),
        DoubleProperty('The specified maxExtent was', maxExtent),
        DoubleProperty('The specified minExtent was', minExtent),
      ]);
    }());
    double stretchOffset = 0.0;
    if (stretchConfiguration != null && constraints.scrollOffset == 0.0) {
      stretchOffset += constraints.overlap.abs();
    }

    child?.layout(
      constraints.asBoxConstraints(
        maxExtent:
            math.max(minExtent, maxExtent - shrinkOffset) + stretchOffset,
      ),
      parentUsesSize: true,
    );

    if (stretchConfiguration != null &&
        stretchConfiguration!.onStretchTrigger != null &&
        stretchOffset >= stretchConfiguration!.stretchTriggerOffset &&
        _lastStretchOffset <= stretchConfiguration!.stretchTriggerOffset) {
      stretchConfiguration!.onStretchTrigger!();
    }
    _lastStretchOffset = stretchOffset;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.addTagForChildren(RenderViewport.excludeFromScrolling);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty.lazy('maxExtent', () => maxExtent));
    properties.add(DoubleProperty.lazy(
        'child position', () => childMainAxisPosition(child!)));
  }
}

// Trims the specified edges of the given `Rect` [original], so that they do not
// exceed the given values.
Rect? _trim(
  Rect? original, {
  double top = -double.infinity,
  double right = double.infinity,
  double bottom = double.infinity,
  double left = -double.infinity,
}) =>
    original?.intersect(Rect.fromLTRB(left, top, right, bottom));
