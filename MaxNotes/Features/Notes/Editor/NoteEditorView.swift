//
//  NoteEditorView.swift
//  MaxNotes
//
//  Created by Max zam on 25/11/2025.
//

import PhotosUI
import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: NoteEditorViewModel
    @FocusState private var focusedField: Field?
    @State private var selectedPhoto: PhotosPickerItem?
    
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
            
            imageSection
            
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
                        ZStack {
                            Text("Delete Note")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                            if viewModel.isDeleting {
                                ProgressView()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
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
            await viewModel.loadPreviewIfNeeded()
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task { await viewModel.loadSelectedPhoto(newValue) }
            selectedPhoto = nil
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
    
    @ViewBuilder
    private var imageSection: some View {
        Section("Image") {
            if let data = viewModel.imageData, let preview = UIImage(data: data) {
                photoPicker {
                    Image(uiImage: preview)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .contentShape(Rectangle())
                }
            }
            HStack {
                attachButton
                    .buttonStyle(.plain)
                Spacer()
                if viewModel.hasImage {
                    Button("Remove", role: .destructive) {
                        Task { await viewModel.removeImage() }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                }
            }
        }
    }
    
    private var attachButton: some View {
        photoPicker {
            Label("Choose from Photos", systemImage: "photo.on.rectangle")
        }
    }
    
    private func photoPicker<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images, label: content)
    }
    
}


#Preview {
    NavigationStack {
        NoteEditorView(
            viewModel: NoteEditorViewModel(
                noteRepo: MockNoteRepository(),
                locationService: MockLocationService(),
                imageStorage: MockImageStorage()
            )
        )
    }
}
