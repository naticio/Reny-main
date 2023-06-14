//
//  PlaidView.swift
//  Reny
//
//  Created by Nat-Serrano on 12/3/21.
//

import Foundation
import LinkKit
import SwiftUI

struct PlaidViewPresenter: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    var configuration: LinkPublicKeyConfiguration

    var exitCallback: ((LinkExit) -> Void)?
    var successCallback: ((LinkSuccess) -> Void)?
    var eventCallback: ((LinkEvent) -> Void)?

    init(
        isPresented: Binding<Bool>,
        configuration: LinkPublicKeyConfiguration,
        onExit: ((LinkExit) -> Void)?,
        onSuccess: ((LinkSuccess) -> Void)?,
        onEvent: ((LinkEvent) -> Void)?
    ) {
        self._isPresented = isPresented
        self.configuration = configuration

        self.exitCallback = onExit
        self.successCallback = onSuccess
        self.eventCallback = onEvent

        self.configuration.onExit = self.onExit
        self.configuration.onEvent = self.onEvent
        self.configuration.onSuccess = self.onSuccess
    }

    func onExit(_ exit: LinkExit) {
        #if DEBUG
        print(exit.error.debugDescription)
        #endif
        exitCallback?(exit)
        isPresented = false
    }

    func onSuccess(_ success: LinkSuccess) {
        successCallback?(success)
        isPresented = false
    }

    func onEvent(_ event: LinkEvent) {
        eventCallback?(event)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.uiViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.parent = self
        context.coordinator.isPresented = isPresented
    }
}

extension PlaidViewPresenter {
    class Coordinator: NSObject {
        var uiViewController = UIViewController()
        var handler: Handler?

        var isPresented: Bool? {
            didSet(wasPresented) {
                if isPresented == true && wasPresented != isPresented {
                    openLink()
                }
            }
        }

        func openLink() {
            switch Plaid.create(parent.configuration) {
            case let .failure(error):
                print("Unable to create Plaid handler due to: \(error)")
            case let .success(handler):
                self.handler = handler
                self.handler?.open(presentUsing: .viewController(uiViewController))
            }
        }

        var parent: PlaidViewPresenter

        init(parent: PlaidViewPresenter) {
            self.parent = parent
        }
    }
}

struct PlaidViewPresentationModifier: ViewModifier {

    @Binding var isPresented: Bool

    var configuration: LinkPublicKeyConfiguration
    var onExit: ((LinkExit) -> Void)?
    var onSuccess: ((LinkSuccess) -> Void)?
    var onEvent: ((LinkEvent) -> Void)?

    func body(content: Content) -> some View {
        content.background(
            PlaidViewPresenter(
                isPresented: $isPresented,
                configuration: configuration,
                onExit: onExit,
                onSuccess: onSuccess,
                onEvent: onEvent
            )
        )
    }
}

extension View {
    func plaidView(
        isPresented: Binding<Bool>,
        configuration: LinkPublicKeyConfiguration,
        onExit: ((LinkExit) -> Void)? = nil,
        onSuccess: ((LinkSuccess) -> Void)? = nil,
        onEvent: ((LinkEvent) -> Void)? = nil
    ) -> some View {
        self.modifier(
            PlaidViewPresentationModifier(
                isPresented: isPresented,
                configuration: configuration,
                onExit: onExit,
                onSuccess: onSuccess,
                onEvent: onEvent
            )
        )
    }
}
