import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var task: String = ""
    @State private var isStar: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedItem: Item? = nil

    var sortedItems: [Item] {
        items.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.09, green: 0.08, blue: 0.11)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Dona")
                    .foregroundStyle(.white)
                    .font(.system(size: 21, weight: .semibold))
                    .padding(.leading)
                
                List {
                    ForEach(sortedItems, id: \.id) { item in
                        
                        HStack(alignment: .top) {
                                
                                Button(action: {
                                    withAnimation(.bouncy) {
                                        haptic()
                                        item.isCompleted.toggle()
                                    }
                                }) {
                                    if !item.isCompleted{
                                        CheckBoxView()
                                            .opacity(0.5)
                                            .frame(width: 14, height: 14)
                                            .padding(.leading, 10)
                                    } else {
                                        CheckBoxFilledView()
                                            .opacity(0.5)
                                            .frame(width: 14, height: 14)
                                            .padding(.leading, 10)
                                    }
                                    
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.leading,2)
                           
                                Text(item.title)
                                    .foregroundStyle(Color.white)
                                    .strikethrough(item.isCompleted)
                                    .font(.system(size: 13))
                                    .onTapGesture {
                                        haptic()
                                        task = item.title
                                        isStar = item.isStarred
                                        isTextFieldFocused = true
                                        selectedItem = item
                                    }
                            
                                Spacer()
                                
                                if item.isStarred {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(red: 0.93, green: 0.78, blue: 0.42))
                                        .padding(.trailing,10)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    withAnimation(.linear(duration: 0.2)) {
                                        deleteItem(item: item)
                                        
                                    }
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.warning)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .foregroundStyle(.red)
                                }
                            
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .contentMargins(.top, 1, for: .scrollContent)
                .animation(.smooth, value: sortedItems)
                .listStyle(PlainListStyle())
                .listRowSpacing(0)
                .scrollIndicators(.hidden)
            }
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.black.opacity(0.5))
                Rectangle()
                    .foregroundStyle(.ultraThinMaterial.opacity(0.5))
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(isTextFieldFocused ? 1.0 : 0)
                .animation(.smooth, value: isTextFieldFocused)
                .onTapGesture {
                    task = ""
                    isTextFieldFocused = false
                }
            
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    CheckBoxStrokeView()
                        .frame(width: 13, height: 13)
                        .scaleEffect(isTextFieldFocused ?  1.0 : 0)
                        .padding(.leading, isTextFieldFocused ?  12 : 0)
                    
                    TextField("Add a new task", text: $task)
                        .textFieldStyle(WhiteBorder(isActive: isTextFieldFocused))
                        .foregroundColor(.white)
                        .font(.system(size: 13))
                        .background(.clear)
                        .focused($isTextFieldFocused)
                        .onTapGesture {
                            haptic()
                        }
             
                    Group  {
                        Button(action: starItem) {
                            Image(systemName: isStar ? "star.fill" : "star.slash.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 15))
                                .padding(.horizontal, 12)
                                .foregroundColor(Color(red: 0.93, green: 0.78, blue: 0.42))
                        }.disabled(!isTextFieldFocused)
                            .opacity(isTextFieldFocused ? 1.0 : 0)
                        Button(action: addItem) {
                            Image(systemName: "plus")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 40-6, height: 40-6)
                                .background(
                                    Circle()
                                        .foregroundStyle(.linearGradient(colors: [Color(red: 0.45, green: 0.29, blue: 0.74), Color(red: 0.57, green: 0.3, blue: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                )
                                .padding(.trailing, 4)
                        }.disabled(!isTextFieldFocused)
                        .scaleEffect(isTextFieldFocused ? 1.0 : 0)
                    }
                }
                .background(
                    Capsule()
                        .foregroundStyle(isTextFieldFocused ? .tertiary : .secondary)
                        .background(
                            Capsule()
                                .stroke(.white.opacity(0.4), lineWidth: 0.2)
                        )
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .preferredColorScheme(.dark)
                .animation(.bouncy, value: isTextFieldFocused)
            }
            
        }
       
        
    }

    private func deleteItem(item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }

    private func addItem() {
        if let selectedItem = selectedItem {
            if task != ""{
                selectedItem.title = task
                selectedItem.isStarred = isStar
                try? modelContext.save()
}
        }
        else{
            let newItem = Item(title: task, isStarred: isStar)
            if !newItem.title.isEmpty {
                modelContext.insert(newItem)
                  }
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        resetInputFields()
    }

    private func starItem() {
        isStar.toggle()
    }

    private func resetInputFields() {
        task = ""
        isStar = false
        isTextFieldFocused = false
        selectedItem  = nil
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self])
}

struct WhiteBorder: TextFieldStyle {
    var isActive: Bool
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
    }
}

struct CheckBoxStrokeView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.checkBoxGray, lineWidth: 0.65)
        }
    }
}

struct CheckBoxView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color(red: 0.09, green: 0.08, blue: 0.11))
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.checkBoxGray, lineWidth: 0.65)
        }
    }
}

struct CheckBoxFilledView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.checkBoxGray)
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.checkBoxGray, lineWidth: 0.65)
        }
    }
}

extension Color {
    static let checkBoxGray = Color(red: 0.59, green: 0.59, blue: 0.59)
    static let pillGray = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let textGrayLight = Color(red: 0.65, green: 0.65, blue: 0.61)
    static let textGrayDark = Color(red: 0.32, green: 0.31, blue: 0.34)
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
  
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
func haptic(){
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
}
