sealed class AIServiceException implements Exception {
  const AIServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AIEmptyPromptException extends AIServiceException {
  const AIEmptyPromptException() : super('Please enter a message.');
}

class AIInvalidPromptException extends AIServiceException {
  const AIInvalidPromptException()
    : super('Please shorten your message and try again.');
}

class AITimeoutException extends AIServiceException {
  const AITimeoutException()
    : super('The assistant took too long to respond. Please try again.');
}

class AIAuthenticationException extends AIServiceException {
  const AIAuthenticationException()
    : super('Please sign in to use the assistant.');
}

class AIUnavailableException extends AIServiceException {
  const AIUnavailableException()
    : super('The assistant is temporarily unavailable. Please try again.');
}

class AIInvalidResponseException extends AIServiceException {
  const AIInvalidResponseException()
    : super('The assistant returned an invalid response. Please try again.');
}

class AIEmptyResponseException extends AIServiceException {
  const AIEmptyResponseException()
    : super('The assistant returned an empty response. Please try again.');
}