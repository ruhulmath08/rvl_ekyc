import 'package:domain/repository/ekyc_repository.dart';
import 'package:hello_flutter/presentation/base/base_binding.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_view_model.dart';

class EkycBinding extends BaseBinding {
  @override
  Future<void> addDependencies() async {
    final ekycRepository = await diModule.resolve<EkycRepository>();
    return diModule.registerInstance(
      EkycViewModel(ekycRepository: ekycRepository),
    );
  }

  @override
  Future<void> removeDependencies() async {
    return diModule.unregister<EkycViewModel>();
  }
}
