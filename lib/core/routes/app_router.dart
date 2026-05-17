import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/admin/admin_dashboard.dart';
import '../../views/admin/teacher_list_screen.dart';
import '../../views/admin/add_teacher_screen.dart';
import '../../views/admin/class_assignment_screen.dart';
import '../../views/teacher/teacher_dashboard.dart';
import '../../views/teacher/attendance_screen.dart';
import '../../views/teacher/marks_entry_screen.dart';
import '../../views/teacher/homework_screen.dart';
import '../../views/student/student_dashboard.dart';
import '../../views/student/student_timetable_screen.dart';
import '../../views/student/student_results_screen.dart';
import '../../views/common/notifications_screen.dart';
import '../../views/admin/add_student_screen.dart';
import '../../views/admin/admin_attendance_screen.dart';
import '../../views/admin/send_timetable_screen.dart';
import '../../views/admin/manage_classes_screen.dart';
import '../../views/admin/manage_subjects_screen.dart';
import '../../views/admin/admin_profile_screen.dart';
import '../../views/admin/student_list_screen.dart';
import '../../views/teacher/teacher_students_screen.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: AppConstants.routeSplash,
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final isLoggedIn = authViewModel.isLoggedIn;
        final role = authViewModel.role;
        final loc = state.matchedLocation;
        if (loc == AppConstants.routeSplash) return null;
        if (!isLoggedIn && loc != AppConstants.routeLogin) {
          return AppConstants.routeLogin;
        }
        if (isLoggedIn && loc == AppConstants.routeLogin) {
          if (role == AppConstants.roleAdmin) return AppConstants.routeAdminDashboard;
          if (role == AppConstants.roleTeacher) return AppConstants.routeTeacherDashboard;
          return AppConstants.routeStudentDashboard;
        }
        return null;
      },
      routes: [
        GoRoute(path: AppConstants.routeSplash, builder: (_, __) => const SplashScreen()),
        GoRoute(path: AppConstants.routeLogin, builder: (_, __) => const LoginScreen()),
        GoRoute(path: AppConstants.routeAdminDashboard, builder: (_, __) => const AdminDashboard()),
        GoRoute(path: AppConstants.routeTeacherList, builder: (_, __) => const TeacherListScreen()),
        GoRoute(path: AppConstants.routeAddTeacher, builder: (_, __) => const AddTeacherScreen()),
        GoRoute(path: AppConstants.routeClassAssignment, builder: (_, __) => const ClassAssignmentScreen()),
        GoRoute(path: AppConstants.routeTeacherDashboard, builder: (_, __) => const TeacherDashboard()),
        GoRoute(path: AppConstants.routeTakeAttendance, builder: (_, __) => const AttendanceScreen()),
        GoRoute(path: AppConstants.routeMarksEntry, builder: (_, __) => const MarksEntryScreen()),
        GoRoute(path: AppConstants.routeHomeworkAdd, builder: (_, __) => const HomeworkScreen()),
        GoRoute(path: AppConstants.routeStudentDashboard, builder: (_, __) => const StudentDashboard()),
        GoRoute(path: AppConstants.routeStudentTimetable, builder: (_, __) => const StudentTimetableScreen()),
        GoRoute(path: AppConstants.routeStudentResults, builder: (_, __) => const StudentResultsScreen()),
        GoRoute(path: AppConstants.routeNotifications, builder: (_, __) => const NotificationsScreen()),
        GoRoute(path: AppConstants.routeAddStudent, builder: (_, __) => const AddStudentScreen()),
        GoRoute(path: AppConstants.routeClassAttendance, builder: (_, __) => const AdminAttendanceScreen()),
        GoRoute(path: AppConstants.routeSendTimetable, builder: (_, __) => const SendTimetableScreen()),
        GoRoute(path: AppConstants.routeManageClasses, builder: (_, __) => const ManageClassesScreen()),
        GoRoute(path: AppConstants.routeManageSubjects, builder: (_, __) => const ManageSubjectsScreen()),
        GoRoute(path: AppConstants.routeTeacherStudents, builder: (_, __) => const TeacherStudentsScreen()),
        GoRoute(path: AppConstants.routeAdminProfile, builder: (_, __) => const AdminProfileScreen()),
        GoRoute(path: AppConstants.routeStudentList, builder: (_, __) => const StudentListScreen()),
      ],
    );
  }
}
