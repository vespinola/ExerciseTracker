//
//  EditorToolbarModifier.swift
//  ExerciseTracker
//
//  Created by Vladimir Espinola Lezcano on 2025-08-31.
//

import SwiftUI

struct EditorToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarRole(.editor)
    }
}

extension View {
    func editorToolbar() -> some View {
        self.modifier(EditorToolbarModifier())
    }
}
