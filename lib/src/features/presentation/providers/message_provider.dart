import 'package:flutter/material.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_message_usecase.dart';
import '../../../core/failure/failure.dart';

class MessageState {
  final bool isLoading;
  final String? message;
  final String? error;

  const MessageState({
    this.isLoading = false,
    this.message,
    this.error,
  });

  MessageState copyWith({
    bool? isLoading,
    String? message,
    String? error,
  }) {
    return MessageState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }
}

class MessageProvider extends ChangeNotifier {
  final GetMessageUseCase _messageUseCase;
  MessageState _state = const MessageState();

  MessageProvider(this._messageUseCase);

  MessageState get state => _state;

  Future<void> getMessage() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = _messageUseCase();

    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          error: failure.message,
          message: null,
        );
      },
      (message) {
        _state = _state.copyWith(
          isLoading: false,
          message: message.message,
          error: null,
        );
      },
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _state = const MessageState();
    super.dispose();
  }
}
