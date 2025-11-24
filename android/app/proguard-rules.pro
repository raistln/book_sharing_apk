# Preserve annotations and generic signatures for Gson.
-keepattributes Signature
-keepattributes *Annotation*

# Keep all flutter_local_notifications classes and members used by the plugin.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Prevent R8 from stripping the Gson classes used to cache notification details.
-keep class com.google.gson.Gson { *; }
-keep class com.google.gson.GsonBuilder { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class com.google.gson.reflect.TypeToken$* { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }
-keep class com.google.gson.stream.** { *; }

# Keep fields annotated for Gson serialization.
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
