import 'dart:async';

import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:alex_k_test/src/features/domain/usecases/pin_usecase.dart';
import 'package:bloc/bloc.dart';

import 'event.dart';
import 'state.dart';

class MapPinBloc extends Bloc<MapPinEvent, MapPinState> {
  MapPinBloc(this._pinUseCase) : super(const MapPinState().init()) {
    on<InitEvent>(_init);
    on<ClearCurrentPinData>(_onClearCurrentPinData);
    on<OnError>(_onError);
    on<RestoreScreenState>(_onRestoreScreenState);
    on<OnPinsLoadedSuccessFully>(_onPinsLoadedSuccessFully);
    on<OnSetNewPin>(_onSetNewPin);
    on<OnPinNameChanged>(_onPinNameSaved);
    on<OnCommentAdded>(_onCommentAdded);
    on<OnCommentEditRequired>(_onCommentEditRequired);
    on<OnEditedCommentTextChanged>(_onEditedCommentTextChanged);
    on<OnSavePressed>(_onSavePressed);
  }

  final PinUseCase _pinUseCase;

  void _init(InitEvent event, Emitter<MapPinState> emit) async {
    _pinUseCase.observeAllPins().listen((e) {
      e.fold(_handlePinLoadError, _pinLoadedSuccessfully);
    });
  }

  void _onClearCurrentPinData(
      ClearCurrentPinData event, Emitter<MapPinState> emit) {
    emit(state.copyWith(pinName: "", pinComments: [], lat: 100, lng: 100));
  }

  void _onRestoreScreenState(
      RestoreScreenState event, Emitter<MapPinState> emit) {
    emit(state.copyWith(generalScreenState: const InitialScreenState()));
  }

  void _onError(OnError event, Emitter<MapPinState> emit) {
    emit(state.copyWith(generalScreenState: ErrorScreenState(event.message)));
  }

  _handlePinLoadError(Failure error) => add(OnError(error.message));

  _pinLoadedSuccessfully(List<MapPinEntity> pins) =>
      add(OnPinsLoadedSuccessFully(pins));

  void _onPinsLoadedSuccessFully(
      OnPinsLoadedSuccessFully event, Emitter<MapPinState> emit) async {
    event.pins.forEach((e) => print("LoadedPins -> ${e}"));
    emit(state.copyWith(pins: event.pins));
  }

  void _onSetNewPin(OnSetNewPin event, Emitter<MapPinState> emit) async {
    emit(state.copyWith(
      lat: event.lat,
      lng: event.lng,
      editedPinId: event.id,
      generalScreenState: const InitialScreenState(),
    ));
    //Fill pin values
    emit(state.copyWith(
        lat: state.currentPin?.latitude ?? 100,
        lng: state.currentPin?.longitude ?? 100,
        pinName: state.currentPin?.label ?? "",
        pinComments: state.currentPin?.comments
                ?.split(",")
                .map((e) => e.trim())
                .toList() ??
            []));
  }

  FutureOr<void> _onPinNameSaved(
      OnPinNameChanged event, Emitter<MapPinState> emit) {
    emit(state.copyWith(pinName: event.name));
  }

  FutureOr<void> _onCommentAdded(
      OnCommentAdded event, Emitter<MapPinState> emit) {
    emit(state.copyWith(pinComments: [event.notes, ...state.pinComments]));
  }

  FutureOr<void> _onCommentEditRequired(
      OnCommentEditRequired event, Emitter<MapPinState> emit) {
    emit(state.copyWith(editingCommentPosition: event.position));
  }

  FutureOr<void> _onEditedCommentTextChanged(
      OnEditedCommentTextChanged event, Emitter<MapPinState> emit) {
    emit(state.copyWith(
        pinComments: state.pinComments..[event.position] = event.notes));
  }

  FutureOr<void> _onSavePressed(
      OnSavePressed event, Emitter<MapPinState> emit) async {
    emit(state.copyWith(isPinSaved: true, pinName: "", pinComments: []));
    await _pinUseCase.savePin(MapPinEntity(
        state.lat, state.lng, state.pinName, state.pinComments.join(', ')));
    emit(state.copyWith(
      isPinSaved: false,
    ));
  }
}
