import 'package:either_dart/either.dart';
import '../entities/message_entity.dart';
import '../../../core/failure/failure.dart';

abstract class MessageRepository {
  Either<Failure, MessageEntity> getMessage();
}
