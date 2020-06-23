import SwiftUI

struct NoDataView: View {
    var body: some View {
        Text("No Data", bundle: Bundle.module)
    }
}


struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView().environment(\.locale, .init(identifier: "de"))
    }
}
