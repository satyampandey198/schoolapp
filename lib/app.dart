import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'viewmodels/auth/auth_viewmodel.dart';
import 'viewmodels/admin/admin_viewmodel.dart';
import 'viewmodels/teacher/teacher_viewmodel.dart';
import 'viewmodels/student/student_viewmodel.dart';
import 'viewmodels/theme/theme_viewmodel.dart';
import 'core/routes/app_router.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthViewModel _authVM;
  late final ThemeViewModel _themeVM;
  late final AdminViewModel _adminVM;
  late final TeacherViewModel _teacherVM;
  late final StudentViewModel _studentVM;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authVM = AuthViewModel();
    _themeVM = ThemeViewModel();
    _adminVM = AdminViewModel();
    _teacherVM = TeacherViewModel();
    _studentVM = StudentViewModel();
    _router = AppRouter.createRouter(_authVM);
  }

  @override
  void dispose() {
    _authVM.dispose();
    _themeVM.dispose();
    _adminVM.dispose();
    _teacherVM.dispose();
    _studentVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authVM),
        ChangeNotifierProvider.value(value: _themeVM),
        ChangeNotifierProvider.value(value: _adminVM),
        ChangeNotifierProvider.value(value: _teacherVM),
        ChangeNotifierProvider.value(value: _studentVM),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (_, themeVM, __) {
          return MaterialApp.router(
            title: 'EduManage Pro',
            debugShowCheckedModeBanner: false,
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode: themeVM.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
