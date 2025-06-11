import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showSignUp: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Sign In")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }

            Button(action: {
                // Dummy login action
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Text("or")
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Button(action: {
                    // Dummy Google login action
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Sign in with Google")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }

                Button(action: {
                    // Dummy Apple login action
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Sign in with Apple")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            Spacer()

            // Sign Up button at the bottom
            Button(action: {
                showSignUp = true
            }) {
                Text("Don't have an account? Sign Up")
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                    .padding(.vertical, 12)
            }
            .fullScreenCover(isPresented: $showSignUp) {
                SignUpView()
            }
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
