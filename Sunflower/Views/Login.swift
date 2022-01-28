//

import SwiftUI

struct Login: View {

    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""

    @State private var password = ""

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
                    dismissSheet()
                }
                .keyboardShortcut(.defaultAction)
                .padding(.trailing, 10)

                Button("Cancel") {
                    dismissSheet()
                }
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
