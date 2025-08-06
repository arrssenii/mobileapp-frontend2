# Keep annotations used by libraries (e.g., Tink)
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }
-keep class javax.annotation.concurrent.** { *; }

# Prevent R8 from stripping crypto-related classes
-keep class com.google.crypto.tink.** { *; }

# General rules to prevent stripping annotations
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**
