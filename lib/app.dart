import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'viewmodels/auth/auth_viewmodel.dart';
import 'viewmodels/admin/admin_viewmodel.dart';
import 'viewmodels/teacher/teacher_viewmodel.dart';
import 'viewmodels/student/student_viewmodel.dart';
import 'viewmodels/theme/theme_viewmodel.dart';
import 'services/notification_service.dart';
import 'package:flutter_offline/flutter_offline.dart';
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
    
    _authVM.addListener(_onAuthChanged);
    // Run initial state check
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAuthChanged());
  }

  void _onAuthChanged() {
    final user = _authVM.currentUser;
    if (user != null) {
      if (user.role == 'student') {
        _studentVM.updateUser(user.id);
      } else if (user.role == 'teacher') {
        _teacherVM.updateUser(user.id);
      }
      NotificationService.startListeningForUser(user.id, user.role);
    } else {
      _studentVM.updateUser(null);
      _teacherVM.updateUser(null);
      NotificationService.stopListening();
    }
  }

  @override
  void dispose() {
    _authVM.removeListener(_onAuthChanged);
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
            title: 'schoolonly',
            debugShowCheckedModeBanner: false,
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode: themeVM.themeMode,
            routerConfig: _router,
            builder: (context, child) {
              return OfflineBuilder(
                connectivityBuilder: (
                  BuildContext context,
                  List<ConnectivityResult> connectivity,
                  Widget child,
                ) {
                  final bool connected = !connectivity.contains(ConnectivityResult.none);
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      child,
                      if (!connected)
                        Positioned(
                          top: MediaQuery.of(context).padding.top,
                          left: 0,
                          right: 0,
                          child: Material(
                            child: Container(
                              color: Colors.redAccent,
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'No Internet Connection. Working Offline.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                child: child ?? const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }
}
