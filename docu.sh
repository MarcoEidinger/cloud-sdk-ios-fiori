chartDocs=$(sourcekitten doc --module-name FioriCharts -- -project FioriSwiftUI.xcodeproj)
integrationCardsDocs=$(sourcekitten doc --module-name FioriIntegrationCards -- -project FioriSwiftUI.xcodeproj)
echo ${chartDocs%?}', '${integrationCardsDocs:1} > cloud-sdk-ios-fiori.json
jazzy --sourcekitten-sourcefile cloud-sdk-ios-fiori.json
