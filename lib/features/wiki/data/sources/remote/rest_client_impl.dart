import 'package:dio/dio.dart';
import 'package:grimoire/features/wiki/data/sources/remote/gitlab_api_service.dart';
import 'package:grimoire/features/wiki/data/sources/remote/rest_client.dart';

import '../../../../../core/api/interceptor.dart';

class RestClientImpl extends RestClient {
  RestClientImpl() {
    final dio = Dio()..interceptors.add(CustomInterceptors());
    //dio.addSentry(captureFailedRequests: true);
    service = GitlabApiService(dio);
  }
}