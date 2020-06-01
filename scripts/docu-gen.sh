# combine different modules in a single documentation json
chartDocs=$(sourcekitten doc --module-name FioriCharts -- -project FioriSwiftUI.xcodeproj)
integrationCardsDocs=$(sourcekitten doc --module-name FioriIntegrationCards -- -project FioriSwiftUI.xcodeproj)
echo ${chartDocs%?}', '${integrationCardsDocs:1} > cloud-sdk-ios-fiori.json
# use an optimized README for API documentation (swizzling)
mv README.md README_ORIGINAL.md
mv README_FOR_DOC.md README.md
# generate documentation
jazzy --sourcekitten-sourcefile cloud-sdk-ios-fiori.json
# revert swizzling
mv README.md README_FOR_DOC.md
mv README_ORIGINAL.md README.md
