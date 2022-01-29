import SwiftUI


/// Represents the user login page.
struct Login: View {

    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var modelData: ModelData

    @State private var username = ""

    @State private var password = ""

    @State private var loginInProgress = false

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

                    //                    print("Logging in with \(username) :::: \(password)")
                    modelData.wiki.login(username, password) { success in
                        if success {
                            dismissSheet()
                            modelData.mainButtonState = .standby
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

    func dismissSheet() {
        presentationMode.wrappedValue.dismiss()
        NSApp.mainWindow?.endSheet(NSApp.keyWindow!) // workaround SwiftUI to show dismiss animation
    }
}


struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
            .frame(minWidth:400, minHeight:200)
    }
}
