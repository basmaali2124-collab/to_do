part of 'voice_cubit.dart';

sealed class VoiceTaskState {
  const VoiceTaskState();
}

class VoiceIdle extends VoiceTaskState {
  const VoiceIdle();
}

class VoiceListening extends VoiceTaskState {
  const VoiceListening();
}

class VoiceProcessing extends VoiceTaskState {
  const VoiceProcessing();
}

class VoiceDone extends VoiceTaskState {
  final int count;
  const VoiceDone(this.count);
}

class VoiceError extends VoiceTaskState {
  final String message;
  const VoiceError(this.message);
}