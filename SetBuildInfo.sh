#!/bin/bash

#  SetBuildInfo.sh
#  koudaixiang
#
#  Created by Liu Yachen on 11/28/11.
#  Copyright (c) 2011 Suixing Tech. All rights reserved.

NEW_VERSION=`cat InfoPlist.h | awk '/#define BUILD_NUMBER/ { print $3 + 1 }'`
KDX_LAST_GIT_COMMIT_HASH=`git log -1 --pretty=oneline --abbrev-commit | cut -c1-7`

echo "#define BUILD_NUMBER $NEW_VERSION" > InfoPlist.h
echo "#define GE_LAST_GIT_COMMIT_HASH $KDX_LAST_GIT_COMMIT_HASH" >> InfoPlist.h

touch InfoPlist.h
touch GChat/GChat-Info.plist