
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/voice/logic/voice_cubit.dart';

class VoiceMicButton extends StatefulWidget {
  const VoiceMicButton({super.key});

  @override
  State<VoiceMicButton> createState() => _VoiceMicButtonState();
}

class _VoiceMicButtonState extends State<VoiceMicButton> {
  late final VoiceTaskCubit _cubit =
      VoiceTaskCubit(tasksCubit: context.read<TasksCubit>());

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocConsumer<VoiceTaskCubit, VoiceTaskState>(
      bloc: _cubit,
      listenWhen: (_, curr) => curr is VoiceError,
      listener: (context, state) {
        final error = state as VoiceError;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      },
      buildWhen: (prev, curr) =>
          (prev is VoiceListening) != (curr is VoiceListening) ||
          (prev is VoiceProcessing) != (curr is VoiceProcessing),
      builder: (context, state) {
        if (state is VoiceProcessing) {
          return const SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final isListening = state is VoiceListening;
        return IconButton(
          style: IconButton.styleFrom(backgroundColor: c.textMain),
          onPressed: () {
            FocusScope.of(context).unfocus();
            _cubit.toggle();
          },
          tooltip: isListening ? 'Stop' : 'Add task by voice',
          icon: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 34,
            color: isListening ? AppColors.destructive : c.surface,
          ),
        );
      },
    );
  }
}