import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/core/exceptions/context.dart';
import 'package:alex_k_test/src/core/exceptions/on_map_pin_bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/state.dart';
import 'package:alex_k_test/src/features/presentation/widgets/general_container.dart';
import 'package:alex_k_test/src/features/presentation/widgets/general_gradient_wrapper.dart';
import 'package:alex_k_test/src/features/presentation/widgets/text_field_with_confirm.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/general_text_field.dart';

class AddEditPinScreen extends StatefulWidget {
  const AddEditPinScreen({super.key});

  static const routeLocation = '/parcel_door_selection';

  @override
  State<AddEditPinScreen> createState() => _AddEditPinScreenState();
}

class _AddEditPinScreenState extends State<AddEditPinScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleReceiveData();
    });
  }

  void _handleReceiveData() {
    context.mapPinBloc.clear();
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final double? latitude = arguments?['latitude'];
    final double? longitude = arguments?['longitude'];
    final int? id = arguments?['pin_id'] != null
        ? (arguments!['pin_id'] as num).toInt()
        : null;
    context.mapPinBloc.setPinInfo(latitude, longitude, id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapPinBloc, MapPinState>(
      listenWhen: _listenWhenBlocEvent,
      listener: (context, state) {
        if (state.isPinSaved) context.pop();
      },
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            context.mapPinBloc.allowEditComment(-1);
          },
          child: GeneralGradientWrapper(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: _getTitle,
                actions: [_getSaveButton],
              ),
              body: SizedBox(
                height: double.infinity,
                child: GeneralContainer(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 26,
                        ),
                        _getLabel(Texts.labels.pinName),
                        _getPinTitleField,
                        const SizedBox(
                          height: 26,
                        ),
                        _getLabel(Texts.labels.comments),
                        _getPinComments
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget get _getTitle => BlocBuilder<MapPinBloc, MapPinState>(
      buildWhen: _titleBuildWhen, builder: _getTitleBuilder);

  Widget get _getPinTitleField => BlocBuilder<MapPinBloc, MapPinState>(
      buildWhen: _pinLabelBuildWhen, builder: _getPinTitleBuilder);

  Widget get _getPinComments => BlocBuilder<MapPinBloc, MapPinState>(
      buildWhen: (previous, current) =>
          !const ListEquality()
              .equals(previous.pinComments, current.pinComments) ||
          previous.editingCommentPosition != current.editingCommentPosition,
      builder: _getPinCommentsBuilder);

  Widget get _getSaveButton => BlocBuilder<MapPinBloc, MapPinState>(
      buildWhen: _saveButtonBuildWhen, builder: _getSaveButtonBuilder);

  Widget _getSaveButtonBuilder(BuildContext context, MapPinState state) {
    return TextButton(
        onPressed:
            state.formValid ? () => context.mapPinBloc.addPressed() : null,
        child: Text(Texts.buttonTexts.save));
  }

  Widget _getTitleBuilder(BuildContext context, MapPinState state) {
    return Text(
        state.currentPin != null ? Texts.titles.editPin : Texts.titles.addPin
    );
  }

  Widget _getPinTitleBuilder(BuildContext context, MapPinState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: GeneralTextField(
        key: ValueKey('pin_title_${state.editedPinId}'),
        initialText: state.pinName,
        onChanged: context.mapPinBloc.pinNameChanged,
      ),
    );
  }

  Widget _getPinCommentsBuilder(BuildContext context, MapPinState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldWithConfirm(
            key: const ValueKey('add_comment_field'),
            onSend: (String v) {
              if (v.trim().isNotEmpty) {
                context.mapPinBloc.addComment(v);
              }
            },
          ),
          ...state.pinComments
              .asMap()
              .entries
              .map(
                (entry) => Padding(
                  key: ValueKey('comment_${entry.key}'),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              context.mapPinBloc.allowEditComment(entry.key),
                          child: GeneralTextField(
                            key: ValueKey('comment_text_${entry.key}'),
                            initialText: entry.value,
                            allowEdit:
                                entry.key == state.editingCommentPosition,
                            onChanged: (v) => context.mapPinBloc
                                .editingCommentTextChanged(v, entry.key),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _getLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(text),
      );

  bool _listenWhenBlocEvent(MapPinState previous, MapPinState current) =>
      previous.isPinSaved != current.isPinSaved;

  bool _bodyBuildWhen(MapPinState previous, MapPinState current) =>
      previous.generalScreenState != current.generalScreenState;

  bool _titleBuildWhen(MapPinState previous, MapPinState current) =>
      previous.editedPinId != current.editedPinId;

  bool _pinLabelBuildWhen(MapPinState previous, MapPinState current) =>
      previous.pinName != current.pinName;

  bool _saveButtonBuildWhen(MapPinState previous, MapPinState current) =>
      previous.formValid != current.formValid;
}
