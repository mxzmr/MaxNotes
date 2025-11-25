//
//  NoteListView.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import SwiftUI

struct NoteListView: View {
    @Bindable var viewModel: ListViewModel
    
    private let onSelect: (Note) -> Void
    private let onLogout: () -> Void
    
    init(
        viewModel: ListViewModel,
        onSelect: @escaping (Note) -> Void,
        onLogout: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onSelect = onSelect
        self.onLogout = onLogout
    }
    
    var body: some View {
        List {
            listContent
        }
        .listStyle(.insetGrouped)
        .task { await viewModel.observeNotes() }
    }
}

private extension NoteListView {
    
    @ViewBuilder
    var listContent: some View {
        if let error = viewModel.errorMessage {
            statusRow(text: error, icon: "exclamationmark.triangle.fill", tint: .red)
        } else if viewModel.isLoading && viewModel.notes.isEmpty {
            statusRow(text: "Loading your notes…", icon: "hourglass")
        } else if viewModel.notes.isEmpty {
            statusRow(text: "Start adding notes to see them here.", icon: "square.and.pencil")
        } else {
            ForEach(viewModel.notes) { note in
                Button {
                    onSelect(note)
                } label: {
                    noteRow(note)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    func noteRow(_ note: Note) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            if !note.content.trimmed.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    func statusRow(text: String, icon: String, tint: Color = .secondary) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(text)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        NoteListView(
            viewModel: ListViewModel(noteRepo: MockNoteRepository()),
            onSelect: { _ in },
            onLogout: {}
        )
    }
}
