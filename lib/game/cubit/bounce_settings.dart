import 'package:bloc/bloc.dart';

class BounceSettingsCubit extends Cubit<int> {
  BounceSettingsCubit() : super(2400);

  void setTimeToBounce(int value) {
    emit(value);
  }
}