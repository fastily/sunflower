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

    /// The main body of the View
    var body: some View {
        VStack {
            Text("Login to Commons")
                .font(.title)
                .padding(.bottom, 20)

            HStack {
                Spacer()
                Form {
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                }
                Spacer()
            }
            .padding(.bottom, 20)

            HStack {
                Button("Submit") {
                    if username.isEmpty {
                        return
                    }

                    loginInProgress = true

                    Task {
                        if await modelData.wiki.login(username, password) {
                            UIUtils.dismissSheet(presentationMode)
                            modelData.isLoggedIn = true
                        }
                        else {
                            loginInProgress = false
                            loginJustFailed = true
                        }
                    }
                }
                .disabled(loginInProgress)
                .alert("Incorrect username/password, please try again.", isPresented: $loginJustFailed, actions: {})
                .keyboardShortcut(.defaultAction)
                .padding(.trailing, 10)

                Button("Cancel") {
                    UIUtils.dismissSheet(presentationMode)
                }
                .disabled(loginInProgress)
            }

        }
        .frame(minWidth:400, minHeight:200)
        .padding()

    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewLayout(.fixed(width: 400, height: 200))
    }
}
