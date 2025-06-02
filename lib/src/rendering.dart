// ignore_for_file: unnecessary_null_comparison

import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


typedef ScrollOffsetChanged = void Function(double offset);

class RenderSliverToNestedScrollBoxAdapter
    extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox].
  RenderSliverToNestedScrollBoxAdapter({
    RenderBox? child,
    required double childExtent,
    required this.onScrollOffsetChanged,
  })  : _childExtent = childExtent,
        super(child: child);

  double get childExtent => _childExtent;
  double _childExtent;
  set childExtent(double value) {
    assert(value != null);
    if (_childExtent == value) {
      return;
    }
    _childExtent = value;
    markNeedsLayout();
  }

  ScrollOffsetChanged onScrollOffsetChanged;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final double childLayoutExtent =
        min(childExtent, constraints.viewportMainAxisExtent);

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    //final double targetEndScrollOffset = scrollOffset + remainingExtent;

    if (!child!.hasSize || child!.size.height != childLayoutExtent) {
      final BoxConstraints childConstraints = constraints.asBoxConstraints(
        minExtent: childLayoutExtent,
        maxExtent: childLayoutExtent,
      );

      child!.layout(childConstraints, parentUsesSize: true);
    }

    // final double targetEndScrollOffsetForPaint =
    //     constraints.scrollOffset + constraints.remainingPaintExtent;

    const double leadingScrollOffset = 0;
    final double trailingScrollOffset = childExtent;

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );
    final double estimatedMaxScrollOffset = childExtent;
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: constraints.scrollOffset > 0.0,
    );

    setChildParentData(child!, constraints, geometry!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (childExtent > constraints.viewportMainAxisExtent) {
      // maybe overscroll in ios
      onScrollOffsetChanged(math.min(constraints.scrollOffset,
          childExtent - constraints.viewportMainAxisExtent));
    }
    super.paint(context, offset);
  }

  @override
  @protected
  void setChildParentData(RenderObject child, SliverConstraints constraints,
      SliverGeometry geometry) {
    final SliverPhysicalParentData childParentData =
        child.parentData! as SliverPhysicalParentData;
    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    assert(constraints.axisDirection != null);
    assert(constraints.growthDirection != null);
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        assert(false, 'not support for RenderSliverToScrollableBoxAdapter');
        // childParentData.paintOffset = Offset(
        //     0.0,
        //     -(geometry.scrollExtent -
        //         (geometry.paintExtent + constraints.scrollOffset)));
        break;
      case AxisDirection.right:
        assert(false, 'not support for RenderSliverToScrollableBoxAdapter');
        //childParentData.paintOffset = Offset(-constraints.scrollOffset, 0.0);
        break;
      case AxisDirection.down:
        //childParentData.paintOffset = Offset(0.0, -constraints.scrollOffset);
        // zmtzawqlp

        childParentData.paintOffset = Offset(
            0.0,
            childExtent <= constraints.viewportMainAxisExtent
                ? -constraints.scrollOffset
                : min(childExtent - targetEndScrollOffsetForPaint, 0));
        break;
      case AxisDirection.left:
        assert(false, 'not support for RenderSliverToScrollableBoxAdapter');
        // childParentData.paintOffset = Offset(
        //     -(geometry.scrollExtent -
        //         (geometry.paintExtent + constraints.scrollOffset)),
        //     0.0);
        break;
    }
    assert(childParentData.paintOffset != null);
  }

  @override
  bool hitTestBoxChild(BoxHitTestResult result, RenderBox child,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    final bool rightWayUp = _getRightWayUp(constraints);
    double delta = childMainAxisPosition(child);
    final double crossAxisDelta = childCrossAxisPosition(child);
    double absolutePosition = mainAxisPosition - delta;
    final double absoluteCrossAxisPosition = crossAxisPosition - crossAxisDelta;
    Offset paintOffset, transformedPosition;
    assert(constraints.axis != null);
    switch (constraints.axis) {
      case Axis.horizontal:
        assert(true, 'not support for RenderSliverToScrollableBoxAdapter');
        if (!rightWayUp) {
          absolutePosition = child.size.width - absolutePosition;
          delta = geometry!.paintExtent - child.size.width - delta;
        }
        paintOffset = Offset(delta, crossAxisDelta);
        transformedPosition =
            Offset(absolutePosition, absoluteCrossAxisPosition);
        break;
      case Axis.vertical:
        if (!rightWayUp) {
          absolutePosition = child.size.height - absolutePosition;
          delta = geometry!.paintExtent - child.size.height - delta;
        }
        paintOffset = Offset(crossAxisDelta, delta);
        transformedPosition =
            Offset(absoluteCrossAxisPosition, absolutePosition);
        break;
    }
    assert(paintOffset != null);
    assert(transformedPosition != null);
    return result.addWithOutOfBandPosition(
      paintOffset: paintOffset,
      hitTest: (BoxHitTestResult result) {
        // zmtzawqlp
        return child.hitTest(result,
            position: Offset(transformedPosition.dx,
                transformedPosition.dy - constraints.scrollOffset));
      },
    );
  }

  bool _getRightWayUp(SliverConstraints constraints) {
    assert(constraints != null);
    assert(constraints.axisDirection != null);
    bool rightWayUp;
    switch (constraints.axisDirection) {
      case AxisDirection.up:
      case AxisDirection.left:
        rightWayUp = false;
        break;
      case AxisDirection.down:
      case AxisDirection.right:
        rightWayUp = true;
        break;
    }
    assert(constraints.growthDirection != null);
    switch (constraints.growthDirection) {
      case GrowthDirection.forward:
        break;
      case GrowthDirection.reverse:
        rightWayUp = !rightWayUp;
        break;
    }
    assert(rightWayUp != null);
    return rightWayUp;
  }
}
