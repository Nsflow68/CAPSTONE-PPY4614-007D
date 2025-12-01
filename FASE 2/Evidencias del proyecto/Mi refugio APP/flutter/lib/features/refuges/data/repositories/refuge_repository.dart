import 'package:mi_refugio_app/core/services/api_service.dart';
import 'package:mi_refugio_app/core/types/result.dart';
import 'package:mi_refugio_app/features/refuges/data/models/refuge_model.dart';
import 'package:mi_refugio_app/features/refuges/data/models/refuge_failure.dart';

class RefugeRepository {
  final ApiService _api;

  RefugeRepository([ApiService? apiService]) : _api = apiService ?? ApiService.instance;

  Future<Result<List<RefugeModel>, RefugeFailure>> getRefuges({
    String? region,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (region != null) queryParams['region'] = region;
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final uri = _api.buildUri('refuges', queryParams.isEmpty ? null : queryParams);
      final response = await _api.get(uri);

      final refuges = (response as List)
          .map((json) => RefugeModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(refuges);
    } catch (e) {
      return Result.failure(RefugeNetworkFailure(e.toString()));
    }
  }

  Future<Result<RefugeModel, RefugeFailure>> getRefuge(String id) async {
    try {
      final uri = _api.buildUri('refuges/$id');
      final response = await _api.get(uri);
      final refuge = RefugeModel.fromJson(response as Map<String, dynamic>);
      return Result.success(refuge);
    } catch (e) {
      if (e.toString().contains('404')) {
        return Result.failure(RefugeNotFoundFailure(id));
      }
      return Result.failure(RefugeNetworkFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>, RefugeFailure>> getRefugeStatistics(String id) async {
    try {
      final uri = _api.buildUri('refuges/$id/statistics');
      final response = await _api.get(uri);
      return Result.success(response as Map<String, dynamic>);
    } catch (e) {
      return Result.failure(RefugeNetworkFailure(e.toString()));
    }
  }
}
