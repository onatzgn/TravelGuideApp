import SwiftUI

struct ExploreBottomPanel: View {
    
    @Binding var showRoutes: Bool
    @Binding var showSearch: Bool
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.bottomPanel))
                .shadow(radius: 5)
            
            // Two buttons in a vertical stack
                /*
                Button(action: {
                    showRoutes = true
                }) {
                    Image(systemName: "map.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(UIColor.main))
                }
*/
                Button(action: {
                    showSearch = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(UIColor.main))
                }


            .padding(5)
        }
        
        .frame(width: 60, height: 60)
    }
}
struct ExploreBottomPanel_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var showRoutes = false
        @State private var showSearch = false
        
        var body: some View {
            ExploreBottomPanel(showRoutes: $showRoutes, showSearch: $showSearch)
        }
    }

    static var previews: some View {
        Wrapper()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray.opacity(0.1))
    }
}
