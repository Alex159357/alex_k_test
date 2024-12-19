import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

@immutable
class MapPinState {
  final List<MapPinEntity> pins;
  final String userUuId;
  final double lat;
  final double lng;
  final int? editedPinId;
  final GeneralScreenState generalScreenState;
  final String pinName;
  final List<String> pinComments;
  final int editingCommentPosition;
  final bool isPinSaved;

  const MapPinState(
      {this.pins = const [],
        this.userUuId = "",
      this.editedPinId,
      this.lat = 100.0,
      this.lng = 100.0,
      this.generalScreenState = const LoadingScreenState(),
      this.pinName = "",
      this.pinComments = const [],
      this.editingCommentPosition = -1,
      this.isPinSaved = false});

  MapPinEntity? get currentPin =>
      pins.firstWhereOrNull((e) => e.id == editedPinId);

  bool get formValid => pinName.isNotEmpty;

  MapPinState init() {
    return const MapPinState();
  }

  MapPinState copyWith(
          {List<MapPinEntity>? pins,
            String? userUuId,
          int? editedPinId,
          double? lat,
          double? lng,
          GeneralScreenState? generalScreenState,
          String? pinName,
          List<String>? pinComments,
          int? editingCommentPosition,
          bool? isPinSaved}) =>
      MapPinState(
          pins: pins ?? List<MapPinEntity>.from(this.pins),
          userUuId : userUuId ?? this.userUuId,
          editedPinId: editedPinId ?? this.editedPinId,
          lat: lat ?? this.lat,
          lng: lng ?? this.lng,
          generalScreenState: generalScreenState ?? this.generalScreenState,
          pinName: pinName ?? this.pinName,
          pinComments: pinComments ?? List<String>.from(this.pinComments),
          editingCommentPosition:
              editingCommentPosition ?? this.editingCommentPosition,
          isPinSaved: isPinSaved ?? this.isPinSaved);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapPinState &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(pins, other.pins) &&
          lat == other.lat &&
          lng == other.lng &&
          editedPinId == other.editedPinId &&
          generalScreenState == other.generalScreenState &&
          pinName == other.pinName &&
          const ListEquality().equals(pinComments, other.pinComments) &&
          editingCommentPosition == other.editingCommentPosition &&
          isPinSaved == other.isPinSaved;

  @override
  int get hashCode =>
      pins.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      editedPinId.hashCode ^
      generalScreenState.hashCode ^
      pinName.hashCode ^
      pinComments.hashCode ^
      editingCommentPosition.hashCode ^
      isPinSaved.hashCode;
}
