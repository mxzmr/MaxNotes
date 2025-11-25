//
//  NoteListView.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import SwiftUI

struct NoteListView: View {
    @State private var viewModel: ListViewModel
    
    private let onSelect: (Note) -> Void
    
    init(
        viewModel: ListViewModel,
        onSelect: @escaping (Note) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSelect = onSelect
    }
    
    var body: some View {
        NavigationStack {
            List {
                welcomeMessage
                    .listRowInsets(.init(top: 12, leading: 0, bottom: 6, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                
                listContent
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Notes")
        }
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
    
    var welcomeMessage: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome to MaxNotes")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
            
            Text("Capture your thoughts and keep everything in sync.")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.18), Color.cyan.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
            onSelect: { _ in }
        )
    }
}
