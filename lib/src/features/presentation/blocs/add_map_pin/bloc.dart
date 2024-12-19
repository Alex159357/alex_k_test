import 'dart:async';
import 'dart:convert';

import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/core/utils/mappers/map_pin_mapper.dart';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:alex_k_test/src/features/domain/usecases/pin_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/sync_queue_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/user_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';

import 'event.dart';
import 'state.dart';

class MapPinBloc extends Bloc<MapPinEvent, MapPinState> {
  MapPinBloc(
    this._pinUseCase,
    this._syncQueueUseCase,
    this._mapPinMapper,
    this._userUseCase,
  ) : super(const MapPinState().init()) {
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
  final SyncQueueUseCase _syncQueueUseCase;
  final MapPinMapper _mapPinMapper;
  final UserUseCase _userUseCase;

  StreamSubscription? _pinsSubscription;

  @override
  Future<void> close() {
    _pinsSubscription?.cancel();
    return super.close();
  }

  void _init(InitEvent event, Emitter<MapPinState> emit) async {
    _pinsSubscription?.cancel();
    _pinsSubscription = _pinUseCase.observeAllPins().listen((e) {
      e.fold(_handlePinLoadError, _pinLoadedSuccessfully);
    });
  }

  void _onClearCurrentPinData(
      ClearCurrentPinData event, Emitter<MapPinState> emit) {
    emit(state.copyWith(
      pinName: "",
      pinComments: const [],
      lat: 100,
      lng: 100,
      editingCommentPosition: -1,
      editedPinId: -1,
      generalScreenState: const InitialScreenState(),
    ));
  }

  void _onRestoreScreenState(
      RestoreScreenState event, Emitter<MapPinState> emit) {
    emit(state.copyWith(generalScreenState: const InitialScreenState()));
  }

  void _onError(OnError event, Emitter<MapPinState> emit) {
    emit(state.copyWith(
      generalScreenState: ErrorScreenState(event.message),
      isPinSaved: false,
    ));
  }

  void _handlePinLoadError(Failure error) => add(OnError(error.message));

  void _pinLoadedSuccessfully(List<MapPinEntity> pins) =>
      add(OnPinsLoadedSuccessFully(pins));

  void _onPinsLoadedSuccessFully(
      OnPinsLoadedSuccessFully event, Emitter<MapPinState> emit) async {
    try {
      emit(state.copyWith(
        pins: event.pins,
        generalScreenState: const InitialScreenState(),
      ));
    } catch (e) {
      add(OnError(e.toString()));
    }
  }

  Future<void> _onSetNewPin(
      OnSetNewPin event, Emitter<MapPinState> emit) async {
    try {
      final currentPin = event.id != null
          ? state.pins.firstWhereOrNull((pin) => pin.id == event.id)
          : null;

      emit(state.copyWith(
        lat: currentPin?.latitude ?? event.lat,
        lng: currentPin?.longitude ?? event.lng,
        editedPinId: event.id,
        generalScreenState: const InitialScreenState(),
        pinName: currentPin?.label,
        pinComments: currentPin?.comments
                ?.split(",")
                .where((e) => e.trim().isNotEmpty)
                .map((e) => e.trim())
                .toList() ??
            const [],
      ));
    } catch (e) {
      add(OnError(e.toString()));
    }
  }

  Future<void> _onPinNameSaved(
      OnPinNameChanged event, Emitter<MapPinState> emit) async {
    try {
      emit(state.copyWith(pinName: event.name));
    } catch (e) {
      add(OnError(e.toString()));
    }
  }

  Future<void> _onCommentAdded(
      OnCommentAdded event, Emitter<MapPinState> emit) async {
    if (event.notes.trim().isEmpty) return;

    try {
      final newComments = [event.notes, ...state.pinComments];
      emit(state.copyWith(
        pinComments: newComments,
        editingCommentPosition: -1,
      ));
    } catch (e) {
      add(OnError(e.toString()));
    }
  }

  Future<void> _onCommentEditRequired(
      OnCommentEditRequired event, Emitter<MapPinState> emit) async {
    try {
      if (event.position >= 0 && event.position < state.pinComments.length) {
        emit(state.copyWith(editingCommentPosition: event.position));
      }
    } catch (e) {
      add(OnError(e.toString()));
    }
  }

  Future<void> _onEditedCommentTextChanged(
      OnEditedCommentTextChanged event, Emitter<MapPinState> emit) async {
    try {
      if (event.position >= 0 && event.position < state.pinComments.length) {
        final newComments = List<String>.from(state.pinComments);
        newComments[event.position] = event.notes;
        emit(state.copyWith(pinComments: newComments));
      }
    } catch (e) {
      add(OnError(e.toString()));
    }
  }

  Future<void> _onSavePressed(
      OnSavePressed event, Emitter<MapPinState> emit) async {
    if (!state.formValid) return;

    try {
      // Get current user
      final userResult = await _userUseCase.getCurrentUser();
      final userId = userResult.fold(
        (failure) {
          add(const OnError("Failed to get current user"));
          return null;
        },
        (user) => user.id.toString(),
      );

      if (userId == null) {
        add(const OnError("No user logged in"));
        return;
      }

      final pinEntity = MapPinEntity(
        state.lat,
        state.lng,
        state.pinName,
        state.pinComments.where((c) => c.trim().isNotEmpty).join(', '),
        id: state.editedPinId != -1? state.editedPinId: state.pins.length +1,
        userId: state.currentPin?.userId ?? userId,
      );

      emit(state.copyWith(isPinSaved: true));

      if (state.currentPin != null) {
        await _pinUseCase.updatePin(pinEntity);
        await _syncQueueUseCase.addToQueue(SyncQueueEntity(
            type: "update",
            data: jsonEncode(_mapPinMapper.toModel(pinEntity).toJson())));
      } else {
        await _pinUseCase.savePin(pinEntity);
        await _syncQueueUseCase.addToQueue(SyncQueueEntity(
            type: "create",
            data: jsonEncode(_mapPinMapper.toModel(pinEntity).toJson())));
      }

      emit(state.copyWith(
        isPinSaved: false,
        pinName: "",
        pinComments: const [],
        editingCommentPosition: -1,
        editedPinId: null,
      ));
    } catch (e) {
      emit(state.copyWith(isPinSaved: false));
      add(OnError(e.toString()));
    }
  }
}
