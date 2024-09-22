import SwiftUI
import Combine

struct Contact: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var name: String // Instagram Handle placeholder
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
        case phone
        case name
    }
}

struct APIResponse: Codable {
    let contact: Contact
}

class ContactViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var filteredContacts: [Contact] = []
    
    let baseURL = "https://stoplight.io/mocks/highlevel/integrations/39582863/contacts"
    
    func fetchContacts() {
        guard let url = URL(string: "\(baseURL)/ocQHyuzHvysMo5N5VsXc") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                                print("Raw API Response: \(jsonString)")
                            }
                // Decode the nested API response
                if let apiResponse = try? JSONDecoder().decode(APIResponse.self, from: data) {
                    DispatchQueue.main.async {
                        // Append the contact to the array
                        self.contacts.append(apiResponse.contact)
                    }
                } else {
                    print("Failed to decode API response")
                }
            } else if let error = error {
                print("Error fetching contacts: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func filterContacts(by letter: String) {
        filteredContacts = contacts.filter { $0.firstName.hasPrefix(letter) }
    }
    
    func pickRandomWinner() -> Contact? {
        return filteredContacts.randomElement()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContactViewModel()
    @State private var filterLetter: String = ""
    @State private var showWinner: Contact? = nil
    @State private var hasPurchasedFilters = false
    
    @State private var isFirstNameFilterEnabled = true
    @State private var isLastNameFilterEnabled = true
    @State private var isEmailFilterEnabled = true
    @State private var isPhoneNumberFilterEnabled = true
    @State private var isInstagramFilterEnabled = true
    
    var body: some View {
        VStack {
            // Title for contact filters
            VStack {
                FilterRow(label: "First Name", toggleValue: $isFirstNameFilterEnabled)
                HStack {
                    Text("Start with letter")
                    TextField("Enter letter", text: $filterLetter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                }
                .padding(.bottom)
                
                FilterRow(label: "Last Name", toggleValue: $isLastNameFilterEnabled)
                FilterRow(label: "Email", toggleValue: $isEmailFilterEnabled)
                FilterRow(label: "Phone Number", toggleValue: $isPhoneNumberFilterEnabled)
                FilterRow(label: "Instagram Handle", toggleValue: $isInstagramFilterEnabled)
            }
            .padding()
            
            // Display total and filtered contacts
            HStack {
                Text("Total Contacts: \(viewModel.contacts.count)")
                Text("Filtered Contacts: \(viewModel.filteredContacts.count)")
            }
            .padding()
            
            // Winner Display and Button
            VStack {
                if let winner = showWinner {
                    Text("Winner's Instagram: \(winner.name)")
                        .font(.headline)
                        .padding()
                } else {
                    Text("“name”")
                        .font(.headline)
                        .padding()
                }
                
                Button("Pick A Winner") {
                    showWinner = viewModel.pickRandomWinner()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .onAppear {
            viewModel.fetchContacts()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.orange, Color.pink]),
                                   startPoint: .leading, endPoint: .trailing))
    }
}

struct FilterRow: View {
    var label: String
    @Binding var toggleValue: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle(isOn: $toggleValue) {
                Text("")
            }
            .toggleStyle(SwitchToggleStyle(tint: .green))
            .frame(width: 100)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
