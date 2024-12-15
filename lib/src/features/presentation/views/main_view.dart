import 'package:alex_k_test/src/features/presentation/views/menu_view.dart';
import 'package:alex_k_test/src/features/presentation/widgets/general_container.dart';
import 'package:alex_k_test/src/features/presentation/widgets/main_view_widget.dart';
import 'package:alex_k_test/src/features/presentation/widgets/map_widget.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final List<MapPin> _pins = [
    MapPin(
      latitude: 37.7833,
      longitude: -122.4167,
      label: "Test Location",
    ),
  ];

  void _handleMapTap(double lat, double lng) {
    debugPrint('Map tapped at: $lat, $lng');
  }

  @override
  Widget build(BuildContext context) {
    return BodyGradientFusion(
      primaryView: _getMainBody,
      secondaryView: const MenuView(),
      titles: ["Menu", "Home"],
    );
  }

  //Getters for Bloc components
  Widget get _getMainBody => MapWidget(
        userLat: 37.7749,
        userLng: -122.4194,
        pins: _pins,
        onMapTap: _handleMapTap,
      );
}
