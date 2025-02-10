import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: SliverOverlapAbsorberHandle(),
      sliver: SliverSafeArea(
        sliver: SliverAppBar(
            backgroundColor: Colors.transparent,
            title: Text('aaa'),
            expandedHeight: 200,
            collapsedHeight: 56,
            pinned: true,

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Image.asset(
                'assets/images/titleimage.png',
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }
}
