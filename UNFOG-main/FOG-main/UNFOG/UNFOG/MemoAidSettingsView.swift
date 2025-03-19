import SwiftUI
import WatchConnectivity

struct MemoAidSettingsView: View {
    @AppStorage("memoText", store: UserDefaults(suiteName: "group.Unfog"))
    private var memoText: String = ""
    
    private let session = WCSession.default
    @State private var showSavedAlert = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(LocalizedStringKey("memoaid"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text(LocalizedStringKey("textmemo"))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.gray)
                
                ZStack(alignment: .topLeading) {
                    if memoText.isEmpty {
                        Text(LocalizedStringKey("EnterMemo"))
                            .foregroundColor(.gray.opacity(0.7))
                            .padding(.top, 12)
                            .padding(.leading, 5)
                    }
                    TextEditor(text: $memoText)
                        .padding()
                        .frame(maxWidth: 350, minHeight: 150)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    sendToWatch()
                    showSavedAlert = true
                }) {
                    Text(LocalizedStringKey("Savewatch"))
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.horizontal, 30)
                        .scaleEffect(showSavedAlert ? 1.05 : 1.0)
                        .animation(.spring(), value: showSavedAlert)
                }
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showSavedAlert) {
                Alert(title: Text(LocalizedStringKey("salvato")), message: Text(LocalizedStringKey("textsave")), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func sendToWatch() {
        guard session.activationState == .activated else {
            print("❌ WCSession not activated on iPhone")
            return
        }
        
        let dataToSend = ["memoText": memoText]
        if session.isReachable {
            session.sendMessage(dataToSend, replyHandler: nil, errorHandler: { error in
                print("❌ Error sending memo text: \(error.localizedDescription)")
            })
        } else {
            do {
                try session.updateApplicationContext(dataToSend)
                print("✅ Memo text sent via updateApplicationContext")
            } catch {
                print("❌ Error updating app context: \(error)")
            }
        }
    }
}

#Preview {
    MemoAidSettingsView()
}
