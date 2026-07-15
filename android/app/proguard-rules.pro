# Flutter local notifications rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Ignore missing androidx and platform-related classes
-dontwarn androidx.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**

# Support generic library warnings
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
