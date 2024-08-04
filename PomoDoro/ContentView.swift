//
//  ContentView.swift
//  PomoDoro
//
//  Created by Grégory Corin on 11/07/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var pomodoroManager: PomodoroManager
    @Binding var activeTab: DummyTab
    var offsetObserver = PageOffsetObserver()
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault

    init(modelContext: ModelContext, activeTab: Binding<DummyTab>) {
        _pomodoroManager = StateObject(wrappedValue: PomodoroManager(modelContext: modelContext))
        _activeTab = activeTab
    }
    
    var body: some View {
        VStack(spacing: 15){
            TabBar(.gray)
                .overlay{
                    if let collectViewBounds = offsetObserver.collectionView?.bounds {
                        GeometryReader {
                            let width = $0.size.width
                            let tabCount = CGFloat(DummyTab.allCases.count)
                            let capsuleWidth = width / tabCount
                            let progress = offsetObserver.offset / collectViewBounds.width
                            
                            Capsule()
                                .fill(.black)
                                .frame(width: capsuleWidth)
                                .offset(x: progress * capsuleWidth)
                            
                            TabBar(.white, .semibold)
                                .mask(alignment: .leading) {
                                    Capsule()
                                        .frame(width: capsuleWidth)
                                        .offset(x: progress * capsuleWidth)
                                }
                        }
                    }
                }
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
                .frame(height: 50)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                .shadow(color: .black.opacity(0.05), radius: 5, x: -5, y: -5)
                .padding([.horizontal, .top], 15)
            TabView(selection: $activeTab){
                PomoDoroView(modelContext: modelContext)
                    .environmentObject(pomodoroManager)
                    .tag(DummyTab.pomodoro)
                    .background{
                        if !offsetObserver.isObserving{
                            FindCollectionView{
                                offsetObserver.collectionView = $0
                                offsetObserver.observe()
                            }
                        }
                    }
                TasksView()
                    .tag(DummyTab.calendar)
                StatisticsView()
                    .tag(DummyTab.stats)
                SettingsView()
                    .tag(DummyTab.settings)
            }
            .environmentObject(pomodoroManager)
            .background{
                if !offsetObserver.isObserving{
                    FindCollectionView{
                        offsetObserver.collectionView = $0
                        offsetObserver.observe()
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .preferredColorScheme(userTheme.colorScheme)
    }
    @ViewBuilder
    func TabBar(_ tint: Color, _ weight: Font.Weight = .regular) -> some View {
        HStack(){
            ForEach(DummyTab.allCases, id: \.rawValue) { tab in
                Text(tab.rawValue)
                    .font(.callout)
                    .fontWeight(weight)
                    .foregroundStyle(tint)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)){
                            activeTab = tab
                        }
                    }
            }
        }
    }
}



@Observable
class PageOffsetObserver: NSObject {
    var collectionView: UICollectionView?
    var offset: CGFloat = 0
    private(set) var isObserving: Bool = false
    
    deinit{
        remove()
    }
    
    func observe() {
        // Safe Method
        guard !isObserving else {return}
        collectionView?.addObserver(self, forKeyPath: "contentOffset", context: nil)
        isObserving = true
    }
    
    func remove(){
        isObserving = false
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else {return}
        if let contentOffset = (object as? UICollectionView)?.contentOffset {
            offset = contentOffset.x
        }
    }
}

struct FindCollectionView: UIViewRepresentable {
    var result: (UICollectionView) -> ()
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let collectionView = view.collectionSuperView {
                result(collectionView)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}


extension UIView {
    // Finding the CollectionView by traversing the superview
    var collectionSuperView: UICollectionView? {
        if let collectionView = superview as? UICollectionView {
            return collectionView
        }
        return superview?.collectionSuperView
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PomoTask.self, Recent.self, PomodoroSession.self, Statistics.self, configurations: config)
    return ContentView(modelContext: container.mainContext, activeTab: .constant(.pomodoro))
        .modelContainer(container)
}
