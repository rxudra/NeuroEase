import '../models/ai_request_model.dart';
import '../models/ai_response_model.dart';

abstract interface class AIGateway {
  Future<AIResponseModel> generateResponse(AIRequestModel request);
}