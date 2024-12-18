import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class MapPinEvent {
  const MapPinEvent();
}

class InitEvent extends MapPinEvent {
  const InitEvent();
}

class ClearCurrentPinData extends MapPinEvent{

  const ClearCurrentPinData();
}

class RestoreScreenState extends MapPinEvent{

  const RestoreScreenState();
}


class OnError extends MapPinEvent{
  final String message;

  const OnError(this.message);
}

class OnPinsLoadedSuccessFully extends MapPinEvent{
  final List<MapPinEntity> pins;

  const OnPinsLoadedSuccessFully(this.pins);
}

class OnSetNewPin extends MapPinEvent {
  final double? id;
  final double? lat;
  final double? lng;

  const OnSetNewPin(this.id, this.lat, this.lng);
}

class OnPinNameChanged extends MapPinEvent {
  final String name;

  const OnPinNameChanged(this.name);
}

class OnCommentAdded extends MapPinEvent {
  final String notes;

  const OnCommentAdded(this.notes);
}

class OnCommentEditRequired extends MapPinEvent {
  final int position;

  const OnCommentEditRequired(this.position);
}

class OnEditedCommentTextChanged extends MapPinEvent {
  final String notes;
  final int position;

  const OnEditedCommentTextChanged(this.notes, this.position);
}

class OnSavePressed extends MapPinEvent {
  const OnSavePressed();
}
