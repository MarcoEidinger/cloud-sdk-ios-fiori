#!/bin/bash
git submodule deinit -f -- Apps/SnapshotTestApp/cloud-sdk-ios-fiori-snapshot-references
rm -rf .git/modules/Apps/SnapshotTestApp/cloud-sdk-ios-fiori-snapshot-references/
git rm -f -r Apps/SnapshotTestApp/cloud-sdk-ios-fiori-snapshot-references
git reset .gitmodules
rm .gitmodules
