# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CPP_EXTENSION := .cpp .cc
LOCAL_CFLAGS += -Wall
LOCAL_CPPFLAGS += -std=c++11 -fno-rtti -fno-exceptions -Wall

LOCAL_MODULE   := gles3
LOCAL_SRC_FILES := gles3jni.cpp \
                       RendererES2.cpp \
                       RendererES3.cpp

ifeq ($(TARGET_ARCH_ABI),x86)
    LOCAL_CFLAGS += -ffast-math -mtune=atom -mssse3 -mfpmath=sse
endif

LOCAL_LDLIBS := -lGLESv3 -lEGL -landroid -llog  

include $(BUILD_SHARED_LIBRARY)