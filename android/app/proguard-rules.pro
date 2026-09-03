# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase App Indexing
-keepclassmembers class * {
  @com.google.firebase.appindexing.Indexable *;
}

# Firebase Messaging
-keepclassmembers class com.google.firebase.messaging.FirebaseMessagingService {
  *;
}

# Google Sign-In
-keepclassmembers class * {
  @com.google.android.gms.common.annotation.KeepName *;
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# For using GSON @Expose annotation in the model
-keepattributes *Annotation*

# Gson specific classes
-keep class sun.misc.Unsafe { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.google.gson.Excluder
-keep class com.google.gson.annotations.Expose
-keep class com.google.gson.annotations.SerializedName
-keep class com.google.gson.FieldAttributes
-keep class com.google.gson.InstanceCreator

# Preserve JsonAdapter for Moshi
-keepclassmembers class * {
    @com.squareup.moshi.JsonQualifier *;
}
-keep class com.squareup.moshi.JsonAdapter
-keep class com.squareup.moshi.Moshi
-keepclassmembers class * {
    @com.squareup.moshi.FromJson *;
}
-keepclassmembers class * {
    @com.squareup.moshi.ToJson *;
}

# Kotlin
-keepclassmembers class * {
    @kotlin.Metadata *;
}
-keepclassmembers class * {
    @kotlin.jvm.JvmField *;
    @kotlin.jvm.JvmStatic *;
}

# Keep names - NativeConditionalMethods
-keepclasseswithmembernames class * {
    <methods>;
}

# Keep names of classes, methods and fields so they can be used reflectionally from Java
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Prevent obfuscation of methods called via JNI
-keepclasseswithmembernames class * {
    native <methods>;
}

# Prevent obfuscation of methods that may be called via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Suppress debug logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Firebase specific keeps
-keep class com.google.firebase.** { *; }
-keepclassmembers class com.google.firebase.** { *; }

# Google Sign-In keeps
-keep class com.google.android.gms.auth.api.signin.internal.** { *; }
-keepclassmembers class com.google.android.gms.auth.api.signin.internal.** { *; }

# Keep Firebase Entity types
-keepclassmembers class * {
    @com.google.firebase.database.PropertyName *;
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Support Library (deprecated but kept for compatibility)
-dontwarn android.support.**
-keep class android.support.v4.** { *; }
-keep interface android.support.v4.app.** { *; }
-keep class android.support.v7.** { *; }
-keep class * extends android.support.v4.Fragment
-keep class * extends android.support.v7.app.AppCompatActivity

# Google Play Services
-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}

# Play Core - Missing classes from R8
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task