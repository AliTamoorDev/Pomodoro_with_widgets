//
//  TimePicker.swift
//  PomoDoro
//
//  Created by Grégory Corin on 12/07/2024.
//

import SwiftUI

struct TimePicker: View {
    @Environment(\.colorScheme) private var colorScheme
    var style: AnyShapeStyle = .init(.bar)
    @Binding var hour: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            CustomView("hours", 0...24, $hour)
            CustomView("mins", 0...60, $minutes)
            CustomView("secs", 0...60, $seconds)
        }
        .shadow(radius: 100)
        .offset(x: -25)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundStyle)
                .frame(height: 35)
        }
    }
    
    @ViewBuilder
    private func CustomView(
        _ title: String,
        _ range: ClosedRange<Int>,
        _ selection: Binding<Int>
    ) -> some View {
        PickerViewWithoutIndicator(selection: selection) {
            ForEach(range, id: \.self) { value in
                Text("\(value)")
                    .tag(value)
                    .foregroundColor(textColor)
            }
        }
        .overlay {
            Text(title)
                .font(.callout)
                .frame(width: 50, alignment: .leading)
                .lineLimit(1)
                .offset(x: 50)
                .foregroundColor(textColor)
        }
    }
    
    private var backgroundStyle: AnyShapeStyle {
        colorScheme == .dark ? AnyShapeStyle(.black) : style
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

#Preview {
    @State var hour = 12
    @State var minutes = 24
    @State var seconds = 35
    return TimePicker(hour: $hour, minutes: $minutes, seconds: $seconds)
}

// ... Le reste du code reste inchangé ...
/// Helpers
struct PickerViewWithoutIndicator<Content: View, Selection: Hashable>: View {
    @Binding var selection: Selection
    @ViewBuilder var content: Content
    @State private var ishidden: Bool = false
    var body: some View {
        Picker("", selection: $selection){
            if !ishidden {
                RemovePickerIndication{
                    ishidden = true                }
            } else {
                content
            }
        }
        .pickerStyle(.wheel)
    }
}

fileprivate
struct RemovePickerIndication: UIViewRepresentable {
    var result: () -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async{
            if let pickerView = view.pickerView{
                if pickerView.subviews.count >= 2 {
                    pickerView.subviews[1].backgroundColor = .clear
                }
                result()
            }
        }
        
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

fileprivate
extension UIView {
    var pickerView: UIPickerView? {
        if let view = superview as? UIPickerView {
            return view
        }
        return superview?.pickerView
    }
}
