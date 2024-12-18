import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/event.dart';

extension OnMapPinBloc on MapPinBloc {
  void clear() => add(const ClearCurrentPinData());

  void init() => add(const InitEvent());

  void restoreScreenState() => add(const RestoreScreenState());

  void setPinInfo(double? lat, double? lng, double? id) =>
      add(OnSetNewPin(id, lat, lng));

  void pinNameChanged(String name) => add(OnPinNameChanged(name));

  void addComment(String notes) => add(OnCommentAdded(notes));

  void allowEditComment(int position) => add(OnCommentEditRequired(position));

  void editingCommentTextChanged(String notes, int position) =>
      add(OnEditedCommentTextChanged(notes, position));

  void addPressed() => add(const OnSavePressed());
}
