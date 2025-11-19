# Keep annotations and generic type information used by Gson when
# (de)serializing notification payloads inside flutter_local_notifications.
-keepattributes Signature
-keepattributes *Annotation*

# Keep all classes from the flutter_local_notifications Android plugin.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Ensure Gson TypeToken subclasses retain their type parameters.
-keep class * extends com.google.gson.reflect.TypeToken { *; }

# Keep fields annotated for Gson serialization.
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
