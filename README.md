# S & J PhotoBooth App

A beautiful and elegant iOS PhotoBooth application designed for Shahnila & Josh's wedding celebration.

## Features

### 🎉 Wedding-Themed Experience
- Personalized welcome screen for Shahnila & Josh
- Elegant photo strips with wedding branding
- Clean, minimal design aesthetic
- Custom "S & J" app icon

### 📸 PhotoBooth Functionality
- **3-Photo Sessions** - Streamlined workflow with automatic progression
- **Real-time Camera Preview** - Live camera feed with overlay frame
- **Smart Photo Capture** - Auto-countdown with smile prompts
- **Instant Preview** - Immediate photo strip generation
- **Custom Photo Strips** - Wedding-themed layouts with personalized messages

### 🎨 User Interface
- **Welcome Page** - Elegant introduction with simple typography
- **Camera View** - Clean interface with minimal controls
- **Review Screen** - Large photo strip preview for easy viewing
- **Settings** - Wedding customization options

### 🛠 Technical Features
- Modern UIKit architecture with UIScene lifecycle
- AVFoundation camera integration
- Core Image photo processing
- File-based photo storage
- Comprehensive error handling
- MVVM design pattern

## Screenshots

*Coming soon - Add screenshots of the app in action*

## Requirements

- iOS 13.0+
- iPhone/iPad with rear camera
- Xcode 14.0+ for development

## Installation

### For Development
1. Clone the repository:
   ```bash
   git clone https://github.com/belcapistrano/sandj_photobooth_app.git
   ```

2. Open `com.bcaps.photobooth.xcodeproj` in Xcode

3. Select your target device or simulator

4. Build and run (⌘+R)

### For Wedding Use
1. Build the app in Xcode
2. Install on iPad/iPhone for the wedding event
3. Ensure good lighting for best photo quality
4. Place device in stable position for guests

## Usage

### Taking Photos
1. **Launch App** - Tap the "S & J" icon
2. **Start Session** - Tap the blue "START" button
3. **Pose & Smile** - Follow the countdown prompts
4. **3 Photos** - App automatically takes 3 photos with countdowns
5. **Review** - Automatically shows the completed photo strip
6. **Save/Share** - Use the action button to save or share

### Settings
- Access via the "Settings" button in camera view
- Customize wedding theme elements
- Adjust photo session preferences

## Architecture

```
com.bcaps.photobooth/
├── Managers/           # Core functionality managers
│   ├── CameraManager.swift
│   ├── FilterManager.swift
│   └── SessionManager.swift
├── Models/             # Data models
│   ├── Photo.swift
│   ├── PhotoSession.swift
│   └── LayoutTemplate.swift
├── Views/              # UI components
│   ├── Welcome/
│   ├── Camera/
│   ├── Review/
│   └── Settings/
├── ViewModels/         # MVVM view models
├── Storage/            # Data persistence
├── Utilities/          # Helper classes
└── Assets.xcassets/    # App resources & icons
```

## Technical Details

### Camera Features
- **Flash Control** - Toggle camera flash on/off
- **Camera Switching** - Front/rear camera toggle
- **Auto-focus** - Tap to focus functionality
- **Session Management** - Handles photo capture workflow

### Photo Processing
- **Image Scaling** - Automatic sizing for photo strips
- **Layout Generation** - Creates formatted photo strips
- **Quality Optimization** - Maintains high image quality
- **Wedding Branding** - Adds personalized text and styling

### Storage
- **Local Storage** - Photos saved to app documents
- **Session Persistence** - Maintains photo sessions
- **Settings Storage** - Preserves user preferences

## Testing

The app includes comprehensive unit tests:

```bash
# Run tests in Xcode
⌘+U
```

Test coverage includes:
- Camera manager functionality
- Photo session handling
- Storage operations
- Model validation
- Error handling

## Contributing

This is a specialized wedding app for Shahnila & Josh. For modifications or improvements:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Wedding Day Setup

### Recommended Setup
- **Device**: iPad (larger screen for groups)
- **Position**: Stable surface or tripod mount
- **Lighting**: Well-lit area, avoid backlighting
- **Background**: Clean, simple background
- **Instructions**: Small sign explaining how to use

### Tips for Best Results
- Ensure good lighting for photo quality
- Position camera at chest height for groups
- Test the app before the event
- Have someone demonstrate for guests
- Consider having prints made from the photo strips

## License

This project is developed for personal use for Shahnila & Josh's wedding celebration.

## Acknowledgments

- Built with love for Shahnila & Josh's special day
- Developed using Swift and UIKit
- Camera functionality powered by AVFoundation

---

**Happy Wedding Day! 💕**

*Enjoy capturing beautiful memories with the S & J PhotoBooth App*