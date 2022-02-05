import SwiftUI


/// Represents the user login page.
struct LoginView: View {

    /// The presentation mode environment variable, can be used to dismiss this `View` when embedded in a sheet
    @Environment(\.presentationMode) var presentationMode

    /// The shared model data object
    @EnvironmentObject var modelData: ModelData

    /// The text entered by the user in the username field
    @State private var username = ""

    /// The text entered by the user in the password field
    @State private var password = ""

    /// Indicates whether a login API call is currently in progress.  Should disable the UI buttons while this is happening
    @State private var loginInProgress = false

    /// Indicates if the user entered in bad credentials.  Should show the user a message informing them of what happened.
    @State private var loginJustFailed = false

    var body: some View {
        VStack {
            Text("Login to Commons")
                .font(.title)
                .padding(.bottom, 20)

            Form {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
            }
            .padding(.bottom, 20)

            HStack {
                Button("Submit") {
                    loginInProgress = true

                    Task {
                        if await modelData.wiki.login(username, password) {
                            dismissSheet()
                            modelData.isLoggedIn = true
                        }
                        else {
                            loginInProgress = false
                            loginJustFailed = true
                        }
                    }
                }
                .disabled(loginInProgress)
                .alert("Incorrect username/password, please try again.", isPresented: $loginJustFailed) {
                    Button("OK", role: .cancel) {
                        // nobody cares
                    }
                }
                .keyboardShortcut(.defaultAction)
                .padding(.trailing, 10)

                Button("Cancel") {
                    dismissSheet()
                }
                .disabled(loginInProgress)
            }

        }
        .frame(minWidth:400, minHeight:200)
        .padding()

    }

    /// Convenience function, dismiss this view
    private func dismissSheet() {
        presentationMode.wrappedValue.dismiss()
        NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewLayout(.fixed(width: 400, height: 200))
    }
}
