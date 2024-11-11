//
//  KeyboardViewController.swift
//  NiceKeyboard
//
//  Created by Taylor Burgess on 2024/10/23.
//

import UIKit
import SwiftUI
import KeyboardKit
import Foundation
import QuantumSDK


class KeyboardViewController: KeyboardInputViewController, ObservableObject {
 
    //@StateObject private var scanner = Scanner()
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        services.actionHandler = CustomActionHandler(controller: self)
    
        setup(for: .keyboardKitTest)
        setupDemoServices(extraKey: .rocket)
       
    }
    override func viewWillSetupKeyboardView() {
            super.viewWillSetupKeyboardView()
            setupKeyboardView { [weak self] controller in // <-- Use weak or unknowned self!
                KeyboardView(
                    state: controller.state,
                    services: controller.services,
                    buttonContent: { $0.view },
                    buttonView: { $0.view },
                    emojiKeyboard: { $0.view },
                    toolbar: { _ in CustomToolbarView() }
                )
            }
        }
    
    class CustomActionHandler: KeyboardAction.StandardHandler {
        
    
        
        open override func handle(
            _ gesture: Keyboard.Gesture,
            on action: KeyboardAction
        ) {
            if gesture == .release && action == .rocket {
                print("jgvhgvhgv")
                keyboardContext.textDocumentProxy.insertText("jdfiusdf")
            }
            super.handle(gesture, on: action)
        }
    }

    
    class DemoLayoutService: KeyboardLayout.StandardService {
        
        init(extraKey: ExtraKey) {
            self.extraKey = extraKey
        }
        
        let extraKey: ExtraKey
        
        enum ExtraKey {
            case none
            case emojiIfNeeded
            case keyboardSwitcher
            case localeSwitcher
            case rocket
            case url(String)
        }
        
        /// Insert a locale switcher action or a rocket button.
        override func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
            let layout = super.keyboardLayout(for: context)
            switch extraKey {
            case .none: break
            case .emojiIfNeeded: layout.tryInsertEmojiButton()
            case .keyboardSwitcher: layout.tryInsert(.nextKeyboard)
            case .localeSwitcher: layout.tryInsert(.nextLocale)
            case .rocket: layout.tryInsert(.rocket)
            case .url(let string): layout.tryInsert(.url(.init(string: string), id: nil))
            }
            return layout
        }
    }
   
}
extension KeyboardAction {
    
    var isRocket: Bool {
        switch self {
        case .character(let char): char == "🚀"
        default: false
        }
    }
    
    var fontScaleFactor: Double {
        isRocket ? 1.8 : 1
    }
    
   var replacementAction: KeyboardAction? {
        isRocket ? .primary(.continue) : nil
    }
}



private extension KeyboardLayout {

    func tryInsert(_ action: KeyboardAction) {
        guard let item = tryCreateBottomRowItem(for: action) else { return }
        itemRows.insert(item, before: .space, atRow: bottomRowIndex)
    }

    func tryInsertEmojiButton() {
        guard let row = bottomRow else { return }
        let hasEmoji = row.contains(where: { $0.action == .keyboardType(.emojis) })
        if hasEmoji { return }
        guard let button = tryCreateBottomRowItem(for: .keyboardType(.emojis)) else { return }
        itemRows.insert(button, after: .space, atRow: bottomRowIndex)
    }
}



extension KeyboardApp {

    static var keyboardKitTest: Self {
        .init(
            name: "NiceKeyboard",
            bundleId: "",
            appGroupId: ""
        )
    }
}

extension KeyboardAction {
    // This changes what is shown on the button
    static let rocket = custom(named: "🚀")
}


extension KeyboardViewController {

    /// This is used by both keyboard controllers, to set up
    /// demo-specific keyboard services.
    ///
    /// You can play around with these services and register
    /// your own services to see how it affects the keyboard.
    func setupDemoServices(
        extraKey: DemoLayoutService.ExtraKey
    ) {

        /// 💡 Set up a demo-specific action handler.
     /*   services.actionHandler = DemoActionHandler(
            controller: self
        )    */

        /// 💡 Setup a demo-specific keyboard layout service
        /// that inserts an additional key into the keyboard.
        services.layoutService = DemoLayoutService(
            extraKey: extraKey
        )

        /// 💡 Setup a demo-specific keyboard style that can
        /// change the design of any keys in a keyboard view.
        services.styleService = DemoStyleService(
            keyboardContext: state.keyboardContext
        )
    }

    /// This is used by both keyboard controllers, to set up
    /// demo-specific keyboard state.
    ///
    /// You can play around with the various state types, to
    /// see how it affects the keyboard.
    func setupDemoState() {

        /// 💡 Set up which locale to use to present locales.
        state.keyboardContext.localePresentationLocale = .current

        /// 💡 Configure the space key's long press behavior.
        state.keyboardContext.spaceLongPressBehavior = .moveInputCursor
        // state.keyboardContext.spaceLongPressBehavior = .openLocaleContextMenu

        /// 💡 Disable autocorrection.
        // state.autocompleteContext.isAutocorrectEnabled = false

        /// 💡 Setup dictation. It will trigger the app, but
        /// data is not synced as the demo isn't code signed.
        
    }
}


class DemoActionHandler: KeyboardAction.StandardHandler {

    /// Trigger custom actions for `.image` keyboard actions.
    override func action(
        for gesture: Keyboard.Gesture,
        on action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        let standard = super.action(for: gesture, on: action)
        switch gesture {
        case .longPress: return longPressAction(for: action) ?? standard
        case .release: return releaseAction(for: action) ?? standard
        default: return standard
        }
    }
    
    /// Save an image to Photos when you long press it.
    func longPressAction(
        for action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        switch action {
        case .image(_, _, let imageName): { [weak self] _ in self?.saveImage(named: imageName) }
        default: nil
        }
    }

    /// Copy an image to the pasteboard when you tap it.
    func releaseAction(
        for action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        switch action {
        case .image(_, _, let imageName): { [weak self] _ in self?.copyImage(named: imageName) }
        default: nil
        }
    }
}

private extension DemoActionHandler {

    func alert(_ message: String) {
        print("Implement alert functionality if you want.")
    }

    func copyImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to copy images.") }
        guard image.copyToPasteboard() else { return alert("The image could not be copied.") }
        alert("Copied to pasteboard!")
    }
    func handleImageDidSave(withError error: Error?) {
        if error == nil { alert("Saved!") }
        else { alert("Failed!") }
    }

    func saveImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to save images.") }
        image.saveToPhotos(completion: handleImageDidSave)
        alert("Saved to photos!")
    }
}

private extension UIImage {
    
    func copyToPasteboard(_ pasteboard: UIPasteboard = .general) -> Bool {
        guard let data = pngData() else { return false }
        pasteboard.setData(data, forPasteboardType: "public.png")
        return true
    }
}

private extension UIImage {
    
    func saveToPhotos(completion: @escaping (Error?) -> Void) {
        ImageService.default.saveImageToPhotos(self, completion: completion)
    }
}


/// This class is used as target by the extension above.
private class ImageService: NSObject {
    
    public typealias Completion = (Error?) -> Void

    public static private(set) var `default` = ImageService()
    
    private var completions = [Completion]()
    
    public func saveImageToPhotos(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        completions.append(completion)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageToPhotosDidComplete), nil)
    }
    
    @objc func saveImageToPhotosDidComplete(_ image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        guard completions.count > 0 else { return }
        completions.removeFirst()(error)
    }
}

class DemoStyleService: KeyboardStyle.StandardService {

    override func buttonFontSize(
        for action: KeyboardAction
    ) -> CGFloat {
        let base = super.buttonFontSize(for: action)
        return action.fontScaleFactor * base
    }
    
    override func buttonStyle(
        for action: KeyboardAction,
        isPressed: Bool
    ) -> Keyboard.ButtonStyle {
       // let action = action.replacementAction ?? action
        return super.buttonStyle(for: action, isPressed: isPressed)
    }
    
//     override func buttonImage(for action: KeyboardAction) -> Image? {
//         switch action {
//         case .primary: Image.keyboardBrightnessUp
//         default: super.buttonImage(for: action)
//         }
//     }

//     override func buttonText(for action: KeyboardAction) -> String? {
//         switch action {
//         case .primary: "⏎"
//         case .space: "SpACe"
//         default: super.buttonText(for: action)
//         }
//     }

//    override var actionCalloutStyle: Callouts.ActionCalloutStyle {
//        var style = super.actionCalloutStyle
//        style.callout.backgroundColor = .red
//        return style
//    }

//    override var inputCalloutStyle: Callouts.InputCalloutStyle {
//        var style = super.inputCalloutStyle
//        style.callout.backgroundColor = .blue
//        style.callout.textColor = .yellow
//        return style
//    }
}



/*
 
 
 This is for the scanner class
 
 
 
 */

