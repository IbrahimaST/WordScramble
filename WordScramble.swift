import SwiftUI

struct WordScramble: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var userEntry = ""
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var userScore: Int {
        var scoreSum = 0
        
        for item in usedWords {
            scoreSum += item.count
        }
        return scoreSum * 2
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word:", text: $userEntry)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) {
                        word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit() {
                addNewWord()
            }
            .onAppear(perform: {
                startGame()
            })
            .toolbar {
                VStack(spacing: 10) {
                    Button("Restart") {
                        startGame()
                    }
                    .padding(.trailing, 7)
                    .frame(width: 110, height: 50)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.gradient)
                                .ignoresSafeArea()
                        )
                    .background(.ultraThickMaterial)
                    
                    
                    Text("Current Score: \(userScore)")
                        .font(.headline.weight(.semibold))
                }
                .padding(.top, 50)
            }
            .alert(alertTitle, isPresented: $isShowingAlert) {
                Button("Ok", role: .cancel) {}
            } message:{
                Text(alertMessage)
            }
        }
    }
    
    func addNewWord() {
        let newWord = userEntry.lowercased().trimmingCharacters(in: .whitespaces)
        
        
        guard (newWord.count >= 3 && newWord != rootWord) else {
            alertDisplay(message: "Try a different word!", title: "Same as root word")
            return
        }
        
        guard isOriginal(word: userEntry) else {
            alertDisplay(message: "Be more original", title: "Word used already")
            return
        }

        guard isPossible(word: userEntry) else {
            alertDisplay(message: "You can't spell that word from '\(rootWord)'!", title: "Word not possible")
            return
        }

        guard isReal(word: userEntry) else {
            alertDisplay(message: "You can't just make them up, you know!", title: "Word not recognized")
            return
        }

        
        withAnimation {
            usedWords.insert(newWord, at: 0)
        }
        
        userEntry = ""
    }
        
    func startGame() {
        usedWords.removeAll()
        // finding the file
        if let wordListURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // loads file into a string
            if let wordContents = try? String(contentsOf: wordListURL) {
                // converts into an array of strings
                let words = wordContents.components(separatedBy: "\n")
                
                // Picks a random word and sets a default value
                rootWord = words.randomElement() ?? "universe"
                
                // exits
                return
            }
        }
        // If we are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    func alertDisplay(message: String, title: String) {
        isShowingAlert = true
        alertTitle = title
        alertMessage = message
    }
}

#Preview {
    WordScramble()
}
