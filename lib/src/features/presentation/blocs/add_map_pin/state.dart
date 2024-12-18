import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

@immutable
class MapPinState {
  final List<MapPinEntity> pins;
  final double lat;
  final double lng;
  final double editedPinId;
  final GeneralScreenState generalScreenState;
  final String pinName;
  final List<String> pinComments;
  final int editingCommentPosition;
  final bool isPinSaved;

  const MapPinState(
      {this.pins = const [],
      this.editedPinId = -1.0,
      this.lat = 100.0,
      this.lng = 100.0,
      this.generalScreenState = const LoadingScreenState(),
      this.pinName = "",
      this.pinComments = const [],
      this.editingCommentPosition = -1,
      this.isPinSaved = false});

  MapPinEntity? get currentPin =>
      pins.firstWhereOrNull((e) => e.id == editedPinId);

  bool get formValid => pinName.isEmpty;

  MapPinState init() {
    return const MapPinState();
  }

  MapPinState copyWith(
          {List<MapPinEntity>? pins,
          double? editedPinId,
          double? lat,
          double? lng,
          GeneralScreenState? generalScreenState,
          String? pinName,
          List<String>? pinComments,
          int? editingCommentPosition,
          bool? isPinSaved}) =>
      MapPinState(
          pins: pins ?? this.pins,
          editedPinId: editedPinId ?? this.editedPinId,
          lat: lat ?? this.lat,
          lng: lng ?? this.lng,
          generalScreenState: generalScreenState ?? this.generalScreenState,
          pinName: pinName ?? this.pinName,
          pinComments: pinComments ?? this.pinComments,
          editingCommentPosition:
              editingCommentPosition ?? this.editingCommentPosition,
          isPinSaved: isPinSaved ?? this.isPinSaved);
}
