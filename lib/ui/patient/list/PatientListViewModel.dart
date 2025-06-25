import 'package:bloc/bloc.dart';
import 'package:pd_app/api/PatientService.dart';
import 'package:pd_app/model/Patient.dart';

class PatientListCubit extends Cubit<PatientListUiState> {
  PatientListCubit() : super(PatientListUiState());

  void fetch() async {
    print("fetch");
    state.patients = await PatientService.getPatientList();
    emit(state);
  }

  void deleteByName(String name) {
    final index = state.patients.indexWhere((patient) => patient.name == name);
    if (index != -1) {
      print("deleteByName");
      state.patients[index].deleted = true;
      emit(state);
    }
  }
}

class PatientListUiState {
  List<Patient> patients = [];
  // any state change would trigger builder of blocBuilder by doing this
  @override
  bool operator == (Object other) {
    return false;
  }
}
