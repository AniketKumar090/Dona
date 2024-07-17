import SwiftUI
import SwiftData

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
            
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.96)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("A-nod")
                    .font(.largeTitle)
                    .padding(.leading)
                
                HStack(spacing: 0) {
                    CheckBoxView()
                        .frame(width: isTextFieldFocused ? 13 : 0, height: 13)
                        .padding(.leading, 12)
                    
                    
                    TextField("Write a new task", text: $task)
                        .textFieldStyle(WhiteBorder())
                        .font(.system(size: 13))
                        .background(.clear)
                        .focused($isTextFieldFocused)
                        
                    Group  {
                        Button(action: starItem) {
                            Image(systemName: isStar ? "star.fill" : "star")
                                .font(.system(size: 15))
                                .padding(.horizontal, 12)
                                .foregroundColor(Color(red: 0.93, green: 0.78, blue: 0.42))
                        }.disabled(!isTextFieldFocused)
                            .opacity(isTextFieldFocused ? 1.0 : 0)
                        Button(action: addItem) {
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 38)
                                .background(
                                    RoundedRectangle(cornerRadius: 0)
                                        .foregroundStyle(Color(red: 0.85, green: 0.85, blue: 0.85))
                                        .cornerRadius(10, corners: [.topRight,.bottomRight])
                                        .cornerRadius(2, corners: [.topLeft,.bottomLeft])
                                    
                                )
                                .padding(.trailing, 2)
                        }.disabled(!isTextFieldFocused)
                            .opacity(isTextFieldFocused ? 1.0 : 0)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(isTextFieldFocused ? Color.white : Color.pillGray)
                )
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .animation(.smooth, value: isTextFieldFocused)
                
                List {
                    ForEach(sortedItems, id: \.id) { item in
                        
                            HStack {
                                
                                Button(action: {
                                    withAnimation(.bouncy) {
                                        item.isCompleted.toggle()
                                    }
                                }) {
                                    if !item.isCompleted{
                                        CheckBoxView()
                                            .frame(width: 13, height: 13)
                                            .padding(.leading, 10)
                                    }else{
                                        Image(systemName: "checkmark")
                                            .resizable()
                                            .frame(width: 13,height: 13)
                                            .background(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .foregroundStyle(.black)
                                            )
                                            .foregroundStyle(.white)
                                            .padding(.leading,10)
                                    }
                                    
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.leading,2)
                                Text(item.title)
                                    .foregroundStyle(Color.textBlack)
                                    .strikethrough(item.isCompleted)
                                    .font(.system(size: 13))
                                    .onTapGesture {
                                        task = item.title
                                        selectedItem = item
                                        isTextFieldFocused = true
                                    }
                                Spacer()
                                
                                if item.isStarred {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(red: 0.93, green: 0.78, blue: 0.42))
                                        .padding(.trailing,10)
                                }
                            }
                            .frame(height: 40)
                            
                            .listRowInsets(EdgeInsets())
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(Color.white)
                            )
                            .padding(.horizontal, 10)
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
                .animation(.smooth, value: sortedItems)
                .listStyle(PlainListStyle())
                .listRowSpacing(10)
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
            selectedItem.title = task
            selectedItem.isStarred = isStar
            try? modelContext.save()
        } else {
            let newItem = Item(title: task, isStarred: isStar)
            if !newItem.title.isEmpty {
                modelContext.insert(newItem)
            }
        }
        resetInputFields()
    }

    private func starItem() {
        isStar.toggle()
    }

    private func resetInputFields() {
        task = ""
        isStar = false
        isTextFieldFocused = false
        selectedItem = nil
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self])
}

struct WhiteBorder: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
    }
}

struct CheckBoxView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(Color.checkBoxGray)
    }
}

extension Color {
    static let checkBoxGray = Color(red: 0.9, green: 0.9, blue: 0.9)
    static let pillGray = Color(red: 0.87, green: 0.88, blue: 0.9)
    static let textBlack = Color(red: 0.15, green: 0.15, blue: 0.15)
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
