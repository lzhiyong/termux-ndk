#include <jni.h>
#include <android/log.h>

#define LOG_TAG "CMAKE-EXAMPLE"

extern "C" {
    

JNIEXPORT jstring JNICALL 
Java_com_cmake_example_MainActivity_stringFromJNI(JNIEnv* env, jobject thiz) {
    
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "cmake-example");
    
    return env->NewStringUTF("Hello Android!");
    
}
    
} // extern "C"
