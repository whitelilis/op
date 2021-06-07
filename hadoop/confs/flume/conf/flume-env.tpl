# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# If this file is placed at FLUME_CONF_DIR/flume-env.sh, it will be sourced
# during Flume startup.

# Enviroment variables can be set here.

export JAVA_HOME=JH_HOLDER

MAX_HEAP_G=2

# Give Flume more memory and pre-allocate
G1_OPTS=" -XX:+UseG1GC -XX:MaxGCPauseMillis=200 "
JVM_OPTS=" -Xmx${MAX_HEAP_G}g $G1_OPTS"

export JAVA_OPTS=" $JVM_OPTS "

# Note that the Flume conf directory is always included in the classpath.
#FLUME_CLASSPATH=""
