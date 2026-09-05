import '../../core/di/injection_container.dart';
import 'presentation/manager/dashboard_cubit.dart';

void initDashboard() {
  sl.registerFactory(DashboardCubit.new);
}
