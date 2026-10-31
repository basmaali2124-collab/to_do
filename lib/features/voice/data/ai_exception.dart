enum AiErrorKind {
  notConfigured,
  unauthorized,
  noCredits,
  rateLimited,
  offline,
  badReply,
  other,
}

class AiException implements Exception {
  final AiErrorKind kind;
  final String details;
  AiException(this.kind, this.details);

  String get userMessage {
    switch (kind) {
      case AiErrorKind.notConfigured:
        return 'AI is not configured';
      case AiErrorKind.unauthorized:
        return 'AI key is invalid (401)';
      case AiErrorKind.noCredits:
        return 'AI account is out of credits (402)';
      case AiErrorKind.rateLimited:
        return 'AI is busy (429), try again in a moment';
      case AiErrorKind.offline:
        return 'No internet connection';
      case AiErrorKind.badReply:
      case AiErrorKind.other:
        return 'Could not analyze the text, try again';
    }
  }

  @override
  String toString() => 'AiException(${kind.name}): $details';
}
