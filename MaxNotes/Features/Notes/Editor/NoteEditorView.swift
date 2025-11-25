//
//  NoteEditorView.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: NoteEditorViewModel
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case title
        case body
    }
    
    var body: some View {
        Form {
            Section("Details") {
                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                    .tint(.blue)
                
                TextField("Title", text: $viewModel.title)
                    .font(.title3.weight(.semibold))
                    .focused($focusedField, equals: .title)
                    .submitLabel(.done)
            }
            
            Section("Body") {
                ZStack(alignment: .topLeading) {
                    if viewModel.content.isEmpty {
                        Text("Start writing your note…")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 180)
                        .focused($focusedField, equals: .body)
                        .scrollContentBackground(.hidden)
                }
            }
            
            if let error = viewModel.errorMessage {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
            
            if viewModel.canDelete {
                Section {
                    Button(role: .destructive) {
                        Task { await handleDelete() }
                    } label: {
                        HStack {
                            if viewModel.isDeleting {
                                ProgressView()
                            }
                            Text("Delete Note")
                        }
                    }
                    .disabled(viewModel.isDeleting || viewModel.isSaving)
                }
            }
        }
        .navigationTitle(viewModel.isNew ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await handleSave() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(viewModel.isSaveDisabled)
            }
        }
        .task {
            if viewModel.isNew {
                focusedField = .title
            }
        }
    }
    
    func handleSave() async {
        let success = await viewModel.save()
        if success {
            dismiss()
        }
    }
    
    func handleDelete() async {
        let success = await viewModel.delete()
        if success {
            dismiss()
        }
    }
}


#Preview {
    NavigationStack {
        NoteEditorView(
            viewModel: NoteEditorViewModel(
                noteRepo: MockNoteRepository(),
                locationService: MockLocationService()
            )
        )
    }
}
