import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/core/exceptions/context.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/state.dart';
import 'package:alex_k_test/src/features/presentation/views/error_view.dart';
import 'package:alex_k_test/src/features/presentation/widgets/general_container.dart';
import 'package:alex_k_test/src/features/presentation/widgets/general_gradient_wrapper.dart';
import 'package:alex_k_test/src/features/presentation/widgets/text_field_with_confirm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alex_k_test/src/core/exceptions/on_map_pin_bloc.dart';
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
    context.mapPinBloc.clear();
    super.initState();
  }

  void _handleReceiveData() {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final double? latitude = arguments?['latitude'];
    final double? longitude = arguments?['longitude'];
    final double? id = arguments?['pin_id'];
    context.mapPinBloc.setPinInfo(latitude, longitude, id);
  }

  @override
  Widget build(BuildContext context) {
    _handleReceiveData();
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

  //Bloc components

  Widget get _getTitle => BlocBuilder<MapPinBloc, MapPinState>(
      buildWhen: _titleBuildWhen, builder: _getTitleBuilder);

  Widget get _getPinTitleField => BlocBuilder<MapPinBloc, MapPinState>(
      buildWhen: _pinLabelBuildWhen, builder: _getPinTitleBuilder);

  Widget get _getPinComments =>
      BlocBuilder<MapPinBloc, MapPinState>(builder: _getPinCommentsBuilder);

  Widget get _getSaveButton => BlocBuilder<MapPinBloc, MapPinState>(
      buildWhen: _saveButtonBuildWhen, builder: _getSaveButtonBuilder);

  //Builders

  Widget _getSaveButtonBuilder(BuildContext context, MapPinState state) {
    return TextButton(
        onPressed: () => context.mapPinBloc.addPressed(),
        child: Text(Texts.buttonTexts.save));
  }

  Widget _getTitleBuilder(BuildContext context, MapPinState state) {
    return Text(
        state.currentPin != null ? Texts.titles.editPin : Texts.titles.addPin);
  }

  Widget _getPinTitleBuilder(BuildContext context, MapPinState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: GeneralTextField(
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
            onSend: (String v) {
              context.mapPinBloc.addComment(v);
            },
          ),
          ...List.generate(
              state.pinComments.length,
              (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                context.mapPinBloc.allowEditComment(index),
                            child: GeneralTextField(
                              initialText: state.pinComments[index],
                              allowEdit: index == state.editingCommentPosition,
                              onChanged: (v) => context.mapPinBloc
                                  .editingCommentTextChanged(v, index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
        ],
      ),
    );
  }

  //UI Components
  Widget _getLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(text),
      );

  //control of conditions

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
