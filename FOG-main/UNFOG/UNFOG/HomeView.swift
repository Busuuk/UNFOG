import SwiftUI
import AVFoundation
import AudioToolbox

struct HomeView: View {
    // MARK: - States
    @State private var expandedButton: String? = nil
    @State private var timer: Timer?
    @State private var speechTimer: Timer?
    @State private var isFirstTimeLoadingHome = true
    @State private var isPlaying = false
    
    // Metronome
    @State private var metronomeAngle: Double = 0.0
    
    // Memo Aid
    @State private var progress: CGFloat = 0.0
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - App Group Storage
    // Replace "group.com.example.FOG" with your actual App Group identifier
    @AppStorage("bpm", store: UserDefaults(suiteName: "group.com.unfogg"))
    private var bpm: Double = 50
    
    @AppStorage("memoText", store: UserDefaults(suiteName: "group.com.unfogg"))
    private var memoText: String = ""
    
    @AppStorage("buttonOrder", store: UserDefaults(suiteName: "group.com.unfogg"))
    private var buttonOrder: String = "Metronome, Memo Aid"
    
    // MARK: - Durations
    private let duration: TimeInterval = 120
    private let speechDuration: TimeInterval = 60
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    // For matchedGeometryEffect transitions
    @Namespace private var circleNamespace
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    let screenW = proxy.size.width
                    let screenH = proxy.size.height
                    let centerX = screenW / 2
                    let headerY: CGFloat = 60
                    
                    // Get items from settings and trim spaces
                    let items = buttonOrder
                        .components(separatedBy: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                    
                    // Determine Y positions based on how many items
                    let yPositions: [CGFloat] = {
                        if items.count == 1 {
                            return [screenH / 2]
                        } else if items.count == 2 {
                            // For 2 items, positions at 0.35 and 0.70 of screen height
                            return [screenH * 0.35, screenH * 0.70]
                        } else {
                            // Distribute evenly if more than 2
                            return items.enumerated().map { index, _ in
                                screenH * (0.2 + 0.6 * CGFloat(index) / CGFloat(items.count - 1))
                            }
                        }
                    }()
                    
                    let diagonal = sqrt(screenW * screenW + screenH * screenH)
                    
                    // 1) Header
                    headerView()
                        .position(x: centerX, y: headerY)
                    
                    // 2) Collapsed circles
                    ForEach(Array(items.enumerated()), id: \.element) { (index, item) in
                        if expandedButton == nil || expandedButton == item {
                            collapsedCircle(item: item)
                                .matchedGeometryEffect(id: item,
                                                       in: circleNamespace,
                                                       anchor: .center)
                                .transition(.scale.combined(with: .opacity))
                                .position(x: centerX, y: yPositions[index])
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        toggleFeature(for: item)
                                    }
                                }
                        }
                    }
                    
                    // 3) Expanded overlay
                    if let selected = expandedButton {
                        expandedCircleOverlay(item: selected,
                                              screenW: screenW,
                                              screenH: screenH,
                                              diagonal: diagonal)
                            .zIndex(1)
                            .transition(.opacity)
                    }
                }
            }
            .onAppear {
                // Expand the first item automatically on first load
                if isFirstTimeLoadingHome {
                    let items = buttonOrder
                        .components(separatedBy: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                    if let firstItem = items.first {
                        toggleFeature(for: firstItem)
                    }
                    isFirstTimeLoadingHome = false
                }
            }
            .onDisappear {
                stopAllActions()
            }
        }
    }
    
    // MARK: - Header
    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Text("FOGGY")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            NavigationLink(destination: SettingsHomeView()) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(red: 103/255, green: 58/255, blue: 183/255))
            }
        }
        // Match your original width/height if desired
        .frame(width: 350, height: 40)
    }
    
    // MARK: - Collapsed Circle
    @ViewBuilder
    private func collapsedCircle(item: String) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.white]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                // Circle dimension: 220x220, matching your old code
                .frame(width: 220, height: 220)
                .shadow(color: Color.purple.opacity(0.3),
                        radius: 10, x: 0, y: 5)
            
            // Vertical stack: item text above the icon
            VStack(spacing: 8) {
                Text(item)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                if item == "Memo Aid" {
                    Image(systemName: "brain.head.profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.purple)
                } else if item == "Metronome" {
                    // If iOS 17+ is available, use "metronome"; otherwise fallback
                    if #available(iOS 17, *) {
                        Image(systemName: "metronome")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.purple)
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
    
    // MARK: - Expanded Circle Overlay
    @ViewBuilder
    private func expandedCircleOverlay(item: String,
                                       screenW: CGFloat,
                                       screenH: CGFloat,
                                       diagonal: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.white]),
                        center: .center,
                        startRadius: 50,
                        endRadius: diagonal * 0.8
                    )
                )
                .matchedGeometryEffect(id: item,
                                       in: circleNamespace,
                                       anchor: .center)
                .frame(width: diagonal * 1.3, height: diagonal * 1.3)
                .position(x: screenW / 2, y: screenH / 2)
                .ignoresSafeArea()
            
            expandedContent(item: item, screenW: screenW, screenH: screenH)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                expandedButton = nil
                stopAllActions()
            }
        }
    }
    
    // MARK: - Expanded Content
    @ViewBuilder
    private func expandedContent(item: String,
                                screenW: CGFloat,
                                screenH: CGFloat) -> some View {
        VStack {
            Spacer().frame(height: screenH * 0.4)
            
            Text(item)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 30)
            
            if item == "Metronome" {
                SwingingMetronome(angle: metronomeAngle)
                    .frame(width: 150, height: 150)
            } else if item == "Memo Aid" {
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.purple)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Toggle Feature
    private func toggleFeature(for item: String) {
        if expandedButton == item {
            expandedButton = nil
            stopAllActions()
        } else {
            expandedButton = item
            stopAllActions()
            if item == "Metronome" {
                startMetronome()
            } else if item == "Memo Aid" {
                startSpeaking()
            }
        }
    }
    
    // MARK: - Stop All Actions
    private func stopAllActions() {
        stopMetronome()
        stopSpeaking()
    }
    
    // MARK: - Metronome Functions
    private func startMetronome() {
        let interval = 60.0 / bpm
        isPlaying = true
        feedbackGenerator.prepare()
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            playMetronomeEffect()
        }
        
        // Automatically stop after `duration` seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            stopMetronome()
        }
    }
    
    private func stopMetronome() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
        metronomeAngle = 0.0
    }
    
    private func playMetronomeEffect() {
        AudioServicesPlaySystemSound(1104)
        feedbackGenerator.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.1)) {
            metronomeAngle = (metronomeAngle == 20) ? -20 : 20
        }
    }
    
    // MARK: - Speech Functions
    private func startSpeaking() {
        var timeRemaining = speechDuration
        progress = 0.0
        let step = 1.0 / speechDuration
        
        speechTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                speakText(memoText)
                timeRemaining -= 1
                progress += step
            } else {
                timer.invalidate()
                stopSpeaking()
            }
        }
    }
    
    private func stopSpeaking() {
        speechTimer?.invalidate()
        speechTimer = nil
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}

// MARK: - Swinging Metronome View
fileprivate struct SwingingMetronome: View {
    let angle: Double

    var body: some View {
        ZStack {
            MetronomeBody()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 60, height: 80)
            
            Rectangle()
                .fill(Color.purple)
                .frame(width: 4, height: 60)
                .rotationEffect(.degrees(angle), anchor: .bottom)
                .offset(y: -10)
        }
    }
}

// MARK: - Metronome Body Shape
fileprivate struct MetronomeBody: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topWidth = rect.width * 0.6
        let bottomWidth = rect.width
        let height = rect.height
        let xOffset = (bottomWidth - topWidth) / 2
        
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: bottomWidth, y: height))
        path.addLine(to: CGPoint(x: bottomWidth - xOffset, y: 0))
        path.addLine(to: CGPoint(x: xOffset, y: 0))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    HomeView()
}
