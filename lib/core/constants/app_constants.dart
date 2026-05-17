class AppConstants {
  // App Info
  static const String appName = 'EduManage Pro';
  static const String appVersion = '1.0.0';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';

  // Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeAdminDashboard = '/admin/dashboard';
  static const String routeTeacherDashboard = '/teacher/dashboard';
  static const String routeStudentDashboard = '/student/dashboard';
  static const String routeTeacherList = '/admin/teachers';
  static const String routeAddTeacher = '/admin/teachers/add';
  static const String routeEditTeacher = '/admin/teachers/edit';
  static const String routeClassAssignment = '/admin/class-assignment';
  static const String routeManageTimetable = '/admin/timetable';
  static const String routeSendNotification = '/admin/notifications/send';
  static const String routeTakeAttendance = '/teacher/attendance';
  static const String routeMarksEntry = '/teacher/marks';
  static const String routeHomeworkAdd = '/teacher/homework';
  static const String routeStudentTimetable = '/student/timetable';
  static const String routeStudentResults = '/student/results';
  static const String routeStudentAttendance = '/student/attendance';
  static const String routeNotifications = '/notifications';
  static const String routeAddStudent = '/admin/students/add';
  static const String routeClassAttendance = '/admin/attendance';
  static const String routeSendTimetable = '/admin/timetable/send';
  static const String routeManageClasses = '/admin/classes/manage';
  static const String routeManageSubjects = '/admin/subjects/manage';
  static const String routeTeacherStudents = '/teacher/students';
  static const String routeAdminProfile = '/admin/profile';
  static const String routeStudentList = '/admin/students';

  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Animation Durations
  static const Duration animShort = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animLong = Duration(milliseconds: 700);
}
