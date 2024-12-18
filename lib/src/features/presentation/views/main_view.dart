import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/core/exceptions/context.dart';
import 'package:alex_k_test/src/core/exceptions/on_map_pin_bloc.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/state.dart';
import 'package:alex_k_test/src/features/presentation/screens/add_edit_pin_screen.dart';
import 'package:alex_k_test/src/features/presentation/views/error_view.dart';
import 'package:alex_k_test/src/features/presentation/views/menu_view.dart';
import 'package:alex_k_test/src/features/presentation/widgets/main_view_widget.dart';
import 'package:alex_k_test/src/features/presentation/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    context.mapPinBloc.init();
    super.initState();
  }

  void _handleMapTap(double lat, double lng) {
    context.pushNamed(AddEditPinScreen.routeLocation,
        args: {"latitude": lat, "longitude": lng});
  }

  void _handlePinTap(double? id) {
    context.pushNamed(AddEditPinScreen.routeLocation, args: {"pin_id": id});
  }

  @override
  Widget build(BuildContext context) {
    return BodyGradientFusion(
      primaryView: _getMapBody,
      secondaryView: const MenuView(),
      titles: [Texts.titles.menu, Texts.titles.home],
    );
  }

  //Getters for Bloc components
  Widget get _getMapBody =>
      BlocBuilder<MapPinBloc, MapPinState>(builder: _getMapBodyBuilder);

  //Builders
  Widget _getMapBodyBuilder(BuildContext context, MapPinState state) {
    if (state.generalScreenState is ErrorScreenState) {
      return ErrorView(
        message: (state.generalScreenState as ErrorScreenState).message,
        onGotIt: () {
          context.mapPinBloc.init();
        },
      );
    }
    return MapWidget(
      userLat: 37.7749,
      userLng: -122.4194,
      pins: state.pins,
      onPinTap: _handlePinTap,
      onMapTap: _handleMapTap,
    );
  }
}
