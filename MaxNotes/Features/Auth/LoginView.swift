import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) private var cs
    @State private var viewModel: LoginViewModel
    @State private var mode: AuthMode = .login
    
    init(viewModel: LoginViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mode == .login ? "Welcome back" : "Create account")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text(mode == .login
                             ? "Sign in to sync your notes securely."
                             : "Create an account to keep your notes backed up.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    
                    VStack(spacing: 24) {
                        floatingField(
                            title: "Email",
                            icon: "envelope.fill",
                            isSecure: false,
                            text: $viewModel.email,
                            keyboard: .emailAddress
                        )
                        
                        floatingField(
                            title: "Password",
                            icon: "lock.fill",
                            isSecure: true,
                            text: $viewModel.password,
                            keyboard: .default
                        )
                        
                        if mode == .signup {
                            floatingField(
                                title: "Confirm password",
                                icon: "lock.rotation",
                                isSecure: true,
                                text: $viewModel.confirmPassword,
                                keyboard: .default
                            )
                        }
                        
                        mainButton
                    }
                    .padding(24)
                    .background(glassCard)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .padding(.top, 8)
                    
                    footer
                    
                    if let error = viewModel.errorMessage {
                        glassBanner(text: error, icon: "exclamationmark.triangle.fill", tint: .red)
                    }
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 40)
            }
        }
    }
}

extension LoginView {
    
    private func floatingField(
        title: String,
        icon: String,
        isSecure: Bool,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Group {
                if isSecure {
                    SecureField("", text: text)
                } else {
                    TextField("", text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .keyboardType(keyboard)
            .textContentType(textContentType(for: title))
            .padding(.top, 2)
            
            Divider()
                .background(cs == .dark
                            ? Color.white.opacity(0.22)
                            : Color.black.opacity(0.1))
            
        }
    }
    
    private var mainButton: some View {
        Button {
            viewModel.handleSubmit(mode: mode)
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
                
                Text(mode.actionTitle)
                    .fontWeight(.semibold)
                
                Spacer()
                Image(systemName: "arrow.right")
            }
            .padding()
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [accent, accent.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: accent.opacity(0.3), radius: 18, y: 10)
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1)
        .animation(.easeInOut, value: viewModel.isLoading)
    }
    
    private var footer: some View {
        HStack(spacing: 6) {
            Text(mode.togglePrompt)
                .foregroundStyle(.secondary)
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    mode = mode == .login ? .signup : .login
                    viewModel.errorMessage = nil
                }
            } label: {
                Text(mode == .login ? "Create one" : "Log in")
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
    }
    
    private var glassCard: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(cs == .dark ? .thinMaterial : .ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(cs == .dark
                            ? Color.white.opacity(0.15)
                            : Color.white.opacity(0.2),
                            lineWidth: 1)
            )
            .shadow(color: .black.opacity(cs == .dark ? 0.55 : 0.15),
                    radius: cs == .dark ? 28 : 40,
                    y: cs == .dark ? 16 : 20)
    }
    
    private func glassBanner(text: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            
            Text(text)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(tint.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: tint.opacity(0.2), radius: 12, y: 6)
        .animation(.spring(), value: text)
    }
    
    private var background: some View {
        ZStack {
            LinearGradient(
                colors: cs == .dark
                ? [Color(red: 0.05, green: 0.06, blue: 0.09),
                   Color(red: 0.08, green: 0.09, blue: 0.15)]
                : [Color(red: 0.90, green: 0.95, blue: 1.0),
                   Color(red: 0.88, green: 1.0, blue: 0.93)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            if cs == .light {
                RadialGradient(
                    gradient: .init(colors: [
                        Color.white.opacity(0.35),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 150,
                    endRadius: 650
                )
            }
        }
    }
    
    
    private var accent: Color {
        cs == .dark ? Color.cyan : Color.blue
    }
    
    private func textContentType(for title: String) -> UITextContentType? {
        let lower = title.lowercased()
        if lower.contains("email") { return .emailAddress }
        if lower.contains("password") { return .password }
        return nil
    }
    
}

#Preview {
    LoginView(viewModel: LoginViewModel(authService: MockAuthService()))
}
