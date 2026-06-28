#include <jni.h>
#include <string>

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_{{ cookiecutter.__app_name_without_space_lower }}_{{ cookiecutter.main_activity }}_{{ cookiecutter.java_jni_method }}(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}