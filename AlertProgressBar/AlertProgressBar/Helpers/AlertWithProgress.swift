//
//  AlertWithProgress.swift
//  AlertProgressBar
//
//  Created by Séamus on 2025/10/27.
//

import SwiftUI

struct ProgressAlertConfig {
    var tint: Color = .blue
    var title: String
    var message: String
    var fallbackOffset: CGFloat = 76
    var forceFallback: Bool = true
}

extension View {
    @ViewBuilder
    func progressAlert<Actions: View>(
        config: ProgressAlertConfig,
        isPresented: Binding<Bool>,
        progress: Binding<CGFloat>,
        @ViewBuilder actions: @escaping () -> Actions ) -> some View {
            self
                .alert(config.title, isPresented: isPresented) {
                    actions()
                } message: {
                    Text("\(config.message)\(config.forceFallback ? "" : "\n")")
                }
                .background {
                    if isPresented.wrappedValue {
                        AttachProgressBarToAlert(config: config, progress: progress)
                    }
                }
        }
}

fileprivate struct AttachProgressBarToAlert: UIViewRepresentable {
    var config: ProgressAlertConfig
    @Binding var progress: CGFloat
    /// View properties
    @State private var progressBar: UIProgressView?
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let currentController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.rootViewController,
               let alertController = currentController.presentedViewController as? UIAlertController {
                addProgressBar(alertController)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let progressBar {
            progressBar.progress = Float(progress)
            progressBar.tintColor = UIColor(config.tint)
        }
    }
    
    private func addProgressBar(_ controller: UIAlertController) {
        let progressView = UIProgressView()
        progressView.tintColor = UIColor(config.tint)
        progressView.progress = Float(progress)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = isiOS26 ? 30 : 15
        
        controller.view.addSubview(progressView)
        
        /// Constraints
        progressView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor, constant: padding).isActive = true
        progressView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor, constant: -padding).isActive = true
        
        /// Offset
        var offset = config.fallbackOffset
        if !config.forceFallback {
            if let contentView = controller.view.allSubviews().first(where: {
                String(describing: type(of: $0)).contains("GroupHeaderScrollView")
            }) {
                offset = contentView.frame.height - (isiOS26 ? 8 : 20)
            }
        }
        
        progressView.topAnchor.constraint(equalTo: controller.view.topAnchor, constant: offset).isActive = true
        
        self.progressBar = progressView
    }
    
    var isiOS26: Bool {
        if #available(iOS 26, *) {
            return true
        }
        return false
    }
}

/// Exctract all the subview form the given UIView
extension UIView {
    func allSubviews() -> [UIView] {
        var result = self.subviews.compactMap { $0 }
        for sub in self.subviews {
            result.append(contentsOf: sub.allSubviews())
        }
        return result
    }
}

#Preview {
    ContentView()
}
