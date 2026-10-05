import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ai_request_model.dart';
import '../models/ai_response_model.dart';
import 'ai_gateway.dart';
import 'ai_service_exception.dart';

class FirebaseAIGateway implements AIGateway {
  FirebaseAIGateway({
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
    }) : _auth = auth ?? FirebaseAuth.instance,
      _functions =
       functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  static const _functionName = 'generateAiResponse';
  static const _requestTimeout = Duration(seconds: 30);
  static const _maxPromptLength = 4000;

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  @override
  Future<AIResponseModel> generateResponse(AIRequestModel request) async {
    final normalizedPrompt = request.prompt.trim();
    if (normalizedPrompt.isEmpty) {
      throw const AIEmptyPromptException();
    }
    if (normalizedPrompt.length > _maxPromptLength) {
      throw const AIInvalidPromptException();
    }
    if (_auth.currentUser == null) {
      throw const AIAuthenticationException();
    }

    try {
      debugPrint('[FirebaseAIGateway] Calling generateAiResponse');
      final callable = _functions.httpsCallable(_functionName);
      final result = await callable
          .call<Map<String, dynamic>>({'prompt': normalizedPrompt})
          .timeout(_requestTimeout);

      return AIResponseModel.fromMap(result.data);
    } on AIServiceException {
      rethrow;
    } on TimeoutException {
      throw const AITimeoutException();
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        '[FirebaseAIGateway] FirebaseFunctionsException: '
        'code=${error.code}, message=${error.message}, details=${error.details}',
      );
      throw _mapFunctionsException(error);
    } catch (error) {
      debugPrint(
        '[FirebaseAIGateway] Unexpected exception: '
        '${error.runtimeType}: $error',
      );
      throw const AIUnavailableException();
    }
  }

  AIServiceException _mapFunctionsException(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'unauthenticated':
        return const AIAuthenticationException();
      case 'deadline-exceeded':
        return const AITimeoutException();
      case 'invalid-argument':
        return const AIInvalidPromptException();
      default:
        return const AIUnavailableException();
    }
  }
}