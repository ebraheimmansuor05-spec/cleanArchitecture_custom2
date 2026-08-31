import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_consumer.dart';
import '../models/workshop_user_model.dart';

abstract class WorkshopUsersRolesRemoteDataSource {
  Future<List<WorkshopUserModel>> fetchWorkshopUsers();
}

class WorkshopUsersRolesRemoteDataSourceImpl
    implements WorkshopUsersRolesRemoteDataSource {
  final ApiConsumer _dio;

  WorkshopUsersRolesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<WorkshopUserModel>> fetchWorkshopUsers() async {
    // TODO: replace ApiEndpoints.products with the correct endpoint
    final response = await _dio.get(ApiEndpoints.products);
    return (response as List)
        .map((e) => WorkshopUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
