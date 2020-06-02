# combine different modules in a single documentation json
#chartDocs=$(sourcekitten doc --module-name FioriCharts -- -project FioriSwiftUI.xcodeproj)
#integrationCardsDocs=$(sourcekitten doc --module-name FioriIntegrationCards -- -project FioriSwiftUI.xcodeproj)
#echo ${chartDocs%?}', '${integrationCardsDocs:1} > cloud-sdk-ios-fiori.json
# use an optimized README for API documentation (swizzling)
#mv README.md README_ORIGINAL.md
#mv README_FOR_DOC.md README.md

# generate documentation
#jazzy --sourcekitten-sourcefile cloud-sdk-ios-fiori.json
jazzy --sourcekitten-sourcefile ./jazzy/empty.json --clean --readme=./jazzy/Overview_README.md --disable-search --hide-documentation-coverage
sourcekitten doc --module-name FioriCharts -- -project FioriSwiftUI.xcodeproj > charts.json
jazzy --sourcekitten-sourcefile charts.json --output docs/charts --readme=./jazzy/FioriCharts_README.md --module "FioriCharts"
sourcekitten doc --module-name FioriIntegrationCards -- -project FioriSwiftUI.xcodeproj > integrationCards.json
jazzy --sourcekitten-sourcefile integrationCards.json --output docs/integrationCards --readme=./jazzy/FioriIntegrationCards_README.md --module "FioriIntegrationCards"

#sourcekitten doc --module-name FioriIntegrationCards -- -project FioriSwiftUI.xcodeproj > integrationCards.json
#jazzy --sourcekitten-sourcefile integrationCards.json --output docs/integrationCards

# revert swizzling
#mv README.md README_FOR_DOC.md
#mv README_ORIGINAL.md README.md
