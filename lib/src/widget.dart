import 'package:flutter/material.dart';

import 'rendering.dart';

class SliverToNestedScrollBoxAdapter extends SingleChildRenderObjectWidget {
  /// Creates a sliver that contains a single nested scrollable box widget.
  const SliverToNestedScrollBoxAdapter({
    super.key,
    super.child,
    required this.childExtent,
    required this.onScrollOffsetChanged,
  });

  final double childExtent;
  final ScrollOffsetChanged onScrollOffsetChanged;

  @override
  RenderSliverToNestedScrollBoxAdapter createRenderObject(
    BuildContext context,
  ) => RenderSliverToNestedScrollBoxAdapter(
    childExtent: childExtent,
    onScrollOffsetChanged: onScrollOffsetChanged,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSliverToNestedScrollBoxAdapter renderObject,
  ) {
    renderObject.childExtent = childExtent;
    renderObject.onScrollOffsetChanged = onScrollOffsetChanged;
  }
}
