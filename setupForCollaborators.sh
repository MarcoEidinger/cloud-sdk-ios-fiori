#!/usr/bin/env bash

set -eu

# install various git hooks
bash scripts/installGitHooks.sh

# generate xcoce project file
rm -f -r ./FioriSwiftUI.xcodeproj
swift package generate-xcodeproj

# clone/update snapshot reference images (DO NOT automatically do this in this script as this would generate modified files to be committed)
# if [ -d "./Apps/SnapshotTestApp/cloud-sdk-ios-fiori-snapshot-references" ]
# then
# 	git submodule update --init --recursive
# else
# 	bash scripts/snapshottesting/addSubmoduleSnapthshotReferences.sh
# fi
echo "INFO: if you want to run snapshot tests then please download snapshot reference images with shell script: scripts/snapshottesting/addSubmoduleSnapthshotReferences.sh"

# add run script to xcode project file (if python 3.7+ is available)
if ! hash python; then
    echo "WARNING: no run script was added to Xcode project file to execute SwiftLint check because python version of 3.7+ required"
    exit 0
fi

ver=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
if [ "$ver" -lt "37" ]; then
    echo "WARNING: no run script was added to Xcode project file to execute SwiftLint check because python version of 3.7+ required"
    exit 0
fi
python scripts/addSwiftLintRunScriptToXcodeProj.py
