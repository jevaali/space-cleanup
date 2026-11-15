# 🛸 Space Debris Rescue

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2017.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

> An educational iOS game raising awareness about orbital debris and satellite protection, built with SwiftUI and SpriteKit.

Earth's orbit is becoming increasingly crowded with debris from decades of space exploration. **Space Debris Rescue** puts you in charge of protecting critical satellites from thousands of dangerous objects hurtling through space. Drag debris into Earth's atmosphere to burn it up, tap comets before they strike, and learn about real space systems while you play.

![Game Screenshot Placeholder]()

---

## 🌍 About the Project

This project combines my passion for **space systems engineering** with interactive game development to educate players about the growing problem of orbital debris—one of the most pressing challenges facing modern space operations.

---

## ✨ Features

### 🎮 Gameplay
- **Interactive debris removal**: Drag space debris into Earth's atmosphere before it collides with satellites
- **Comet defense**: Tap incoming comets to destroy them
- **Multiple satellites**: Choose from different satellite missions, each with unique characteristics
- **Difficulty progression**: Three difficulty tiers that increase spawn rates, debris speed, and challenge
- **Real-time scoring**: Earn points and coins based on performance

### 🏆 Progression System
- **User accounts**: Secure authentication with JWT tokens
- **Debris collection**: Unlock and collect real space debris objects (Common → Legendary rarity)
- **Global leaderboard**: Compete with players worldwide
- **Satellite unlocking**: Use earned coins to unlock new satellites and missions
- **Progress tracking**: View statistics, high scores, and achievements

### 📚 Educational Content
- **Learn mode**: Discover facts about real satellites, space debris, and orbital mechanics
- **Satellite details**: Each satellite includes educational information about its mission and purpose
- **Debris archive**: Collection system teaches about different types of space debris

### 🎨 Design
- Custom space-themed UI with smooth animations
- SpriteKit physics-based gameplay
- Dark mode optimized with cosmic color palettes
- Responsive layouts for different iOS devices

---

## 🛠 Tech Stack

### Frontend (This Repository)
- **SwiftUI**: Modern declarative UI framework
- **SpriteKit**: 2D game engine for physics-based gameplay
- **Swift Concurrency**: async/await for network requests and game state management
- **Combine**: Reactive programming for state management
- **UserDefaults**: Local persistence for authentication tokens and settings

### Backend (Separate Repository)
> **Note**: The backend server must be running separately for full functionality.

The game connects to a RESTful API backend that handles:
- User authentication and account management
- Game session processing and scoring
- Leaderboard rankings
- Satellite and debris data
- Progress tracking and unlocks

**Backend repository**: [Link to your backend repo here]

---

## 📋 Requirements

- **iOS**: 17.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Backend server**: Running instance of the Space Debris Rescue API

---

## 🚀 Setup & Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/space-debris-rescue-ios.git
cd space-debris-rescue-ios
```

### 2. Configure Backend Connection
Open `Constants.swift` and update the API base URL to match your backend server:

```swift
enum API {
    static let baseURL = "http://localhost:5021"  // Change to your backend URL
    // ...
}
```

### 3. Setup Backend Server
Before running the iOS app, ensure your backend server is running. See the [backend repository](link-to-backend) for setup instructions.

The backend should be accessible at the URL you configured in step 2.

### 4. Open in Xcode
```bash
open SpaceDebrisRescue.xcodeproj
```

### 5. Build and Run
1. Select your target device (simulator or physical device)
2. Press `Cmd + R` or click the Play button
3. The app will launch with the intro screen

### 6. Create an Account
On first launch:
1. Tap **"Register"** to create a new account
2. Enter your credentials
3. Log in and start playing!

---

## 🎯 How to Play

### Objective
Protect satellites from debris and comets for as long as possible while collecting points and coins.

### Controls
- **Drag debris**: Swipe debris objects toward Earth (center) to burn them up in the atmosphere
- **Tap comets**: Quickly tap incoming comets to destroy them before impact
- **Satellite selection**: Choose different satellites from the main menu, each offering unique challenges

### Game Mechanics
- **Lives**: Satellites start with 2-3 lives depending on difficulty
- **Scoring**: Points awarded for each debris/comet cleared
- **Coins**: Earn in-game currency to unlock new satellites
- **Debris types**: Collect rare debris objects for your archive
- **Progressive difficulty**: Spawn rates increase as you survive longer

### Tips
- Prioritize comets—they're fast and deadly!
- Drag debris smoothly toward Earth's center
- Higher difficulty tiers = greater rewards
- Complete satellite missions for bonus rewards

---

## 📁 Project Structure

```
SpaceDebrisRescue/
├── Views/
│   ├── ContentView.swift          # Root view and app state management
│   ├── LaunchView.swift           # Splash screen
│   ├── IntroView.swift            # Welcome/intro screen
│   ├── LoginView.swift            # User authentication
│   ├── RegisterView.swift         # Account creation
│   ├── MainMenuView.swift         # Main menu and satellite selection
│   ├── GameView.swift             # SpriteKit game container
│   ├── GameLoadingView.swift      # Pre-game loading screen
│   ├── LeaderboardView.swift      # Global rankings
│   ├── CollectionView.swift       # Debris collection archive
│   ├── RulesPopupView.swift       # In-game rules overlay
│   └── LearnView.swift            # Educational content
│
├── Game/
│   ├── GameScene.swift            # SpriteKit game logic and physics
│   └── GameResult.swift           # Game session data model
│
├── Services/
│   ├── AuthService.swift          # Authentication API calls
│   ├── SessionService.swift       # Game session submission
│   ├── LeaderboardService.swift   # Leaderboard data fetching
│   ├── SatelliteService.swift     # Satellite data and unlocking
│   └── DebrisImageStore.swift     # Local debris collection storage
│
├── Models/
│   └── DTOs/                      # Data transfer objects for API
│       ├── LeaderboardEntry.swift
│       ├── SatelliteCardDTO.swift
│       ├── ProcessGameSessionDTO.swift
│       └── UserCollectionItemDTO.swift
│
├── Resources/
│   ├── Constants.swift            # API endpoints and configuration
│   └── Assets.xcassets/           # Images, colors, and assets
│
└── Supporting Files/
    └── Info.plist
```

---

## 🔌 API Integration

The app communicates with the backend via REST API:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/identity/Account/Login` | POST | User authentication |
| `/game/GameAccount/Register` | POST | New user registration |
| `/identity/Account/RefreshToken` | POST | JWT token refresh |
| `/game/Leaderboard/List` | GET | Fetch global rankings |
| `/game/Collection/List` | GET | User's debris collection |
| `/game/Lobby/Get` | GET | Available satellites |
| `/game/Satellite/Details` | GET | Satellite information |
| `/game/Satellite/Unlock` | POST | Unlock new satellite |
| `/game/Session/Submit` | POST | Submit completed game session |
| `/game/Progress/Overview` | GET | User progress statistics |

All authenticated requests include JWT tokens in the `Authorization` header.

---

## 🧪 Testing

### Manual Testing
1. Launch the app in Simulator or on device
2. Register a test account
3. Play through a complete game session
4. Verify score submission and leaderboard updates
5. Test satellite unlocking with earned coins
6. Check debris collection updates

### Network Testing
- Test offline behavior (game sessions should queue for later submission)
- Verify token refresh on expiration
- Ensure proper error handling for network failures

---

## 🌟 Future Enhancements

- [ ] Offline play with session syncing
- [ ] Push notifications for leaderboard position changes
- [ ] iPad optimization with larger play area
- [ ] Multiplayer co-op mode
- [ ] AR mode using RealityKit
- [ ] More satellite missions and debris types
- [ ] Achievement system
- [ ] Daily challenges
- [ ] Social features (friends, sharing)

---

## 🎓 Educational Value

This project demonstrates:

### Space Systems Knowledge
- Orbital mechanics and debris trajectories
- Real satellite missions (GPS, ISS, Earth observation)
- Space sustainability and debris mitigation
- Current challenges in space operations

### Technical Skills
- iOS app development (SwiftUI, UIKit bridge)
- Game development (SpriteKit physics, collision detection)
- RESTful API integration
- Authentication and security (JWT)
- State management patterns
- Async programming (Swift Concurrency)
- Data persistence strategies
- UI/UX design for mobile games

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍🚀 About the Developer

I'm an aspiring space systems engineer passionate about combining technical skills with space exploration. This project represents the intersection of my interests in:
- **Space systems engineering** and orbital mechanics
- **Software development** and interactive experiences
- **Education** and raising awareness about space sustainability

**Connect with me**:
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

---

## 🙏 Acknowledgments

- **ESA** and **NASA** for space debris research and educational resources
- **Swift community** for excellent documentation and frameworks
- **SpriteKit tutorials** that helped with game physics implementation
- All the real satellite missions that inspired this game

---

## 📸 Screenshots

### Main Menu
[Add screenshot of main menu with satellite selection]

### Gameplay
[Add screenshot of active gameplay]

### Debris Collection
[Add screenshot of collection view]

### Leaderboard
[Add screenshot of leaderboard]

---

**Made with 💙 for Earth's orbit and beyond** 🌍🚀

---

*Disclaimer: This is an educational game. While based on real space debris concepts, gameplay mechanics are simplified for entertainment purposes. For accurate scientific information about space debris, please consult ESA, NASA, and other space agency resources.*
