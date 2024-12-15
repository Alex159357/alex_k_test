import 'package:either_dart/either.dart';
import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';
import '../../../core/failure/failure.dart';

class GetMessageUseCase {
  final MessageRepository repository;

  GetMessageUseCase(this.repository);

  Either<Failure, MessageEntity> call() {
    return repository.getMessage();
  }
}
