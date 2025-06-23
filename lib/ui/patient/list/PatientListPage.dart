import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd_app/model/Patient.dart';
import 'package:pd_app/api/PatientService.dart';

import 'package:pd_app/ui/patient/list/PatientListViewModel.dart';
import 'package:pd_app/ui/patient/list/StartPageForMedical.dart';
import 'package:pd_app/ui/patient/list/CreateNewPatientPage.dart';
import 'package:pd_app/ui/login/LoginPage.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PatientListPageState();
  }
}

class _PatientListPageState extends State<PatientListPage> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PatientListCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientListCubit, PatientListUiState>(
      builder: (_, state) {
        List<Widget> children = [
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                gotoLoginPage();
              },
              child: Container(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text(
                  "Log off",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: '請輸入名字或流水號搜尋',
              ),
              onChanged: (text) => setState(() {}),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                gotoCreatePage();
              },
              child: Container(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text(
                  "新增資料",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
        ];

        // Reverse the list of patients
        List<Patient> reversedPatients = state.patients
            .where((patient) => (patient.name ?? "").contains(searchController.text))
            .toList()
            .reversed
            .toList();

        children.addAll(reversedPatients.map((patient) => getPatientComponent(patient)));

        return Scaffold(
          appBar: AppBar(title: const Text("選擇病人")),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<PatientListCubit>().fetch();
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/wallpaper.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView(
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getPatientComponent(Patient patient) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
      width: double.infinity,
      height: 80.0,
      child: GestureDetector(
        onLongPressStart: (details) async {
          final offset = details.globalPosition;
          final RenderBox button = context.findRenderObject() as RenderBox;
          final Offset position = button.localToGlobal(Offset.zero); // 按鈕位置
          print(offset);

          final selected = await showMenu<String>(
            context: context,
            position: RelativeRect.fromLTRB(
              offset.dx,
              offset.dy,
              MediaQuery.of(context).size.width - offset.dx,
              MediaQuery.of(context).size.height - offset.dy,
              // position.dx,
              // position.dy,
              // position.dx + button.size.width,
              // position.dy + button.size.height,
            ),
            items: [
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  '刪除該筆資料',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              )
            ],
          );

          if (selected == 'delete') {
            print('delete selected.');
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text('是否刪除 ${patient.name} 的紀錄？'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () {
                          PatientService.deletePatientData(patient.name ?? "");
                          Navigator.of(context).pop();
                        },
                        child: Text('是'),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('否'),
                      ),
                    ],
                  );
                }
            );
          }
        },
        child: ElevatedButton(
        onPressed: () {
          gotoStartPageForMedical(patient);
        },
        // onLongPress: () {
        //   showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return SimpleDialog(
        //         title: Text('是否刪除 ${patient.name} 的紀錄？'),
        //         children: [
        //           SimpleDialogOption(
        //             onPressed: () {
        //               PatientService.deletePatientData(patient.name ?? "");
        //               Navigator.of(context).pop();
        //             },
        //             child: Text('是'),
        //           ),
        //           SimpleDialogOption(
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //             },
        //             child: Text('否'),
        //           ),
        //         ],
        //       );
        //     }
        //   );
        // },
        child: Container(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Text(
            '姓名：${patient.name ?? ""} 歲數：${patient.age ?? ""} 性別：${patient.gender}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    ));
  }

  void gotoStartPageForMedical(Patient patient) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => StartPageForMedical(patient: patient)));
  }

  void gotoCreatePage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateNewPatientPage()));
  }

  void gotoLoginPage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage(title: "NTU PD")));
  }
}