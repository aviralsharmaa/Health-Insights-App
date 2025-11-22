# Personal Health Insights App

A comprehensive Flutter application for tracking and visualizing personal health metrics with a beautiful, modern UI and robust architecture.

## 📱 Overview

The Personal Health Insights App helps users monitor their health metrics through an intuitive interface with data visualization, trend analysis, and smart filtering capabilities. Built with Flutter best practices and clean architecture principles.

## ✨ Features

### Core Features
- **Dashboard Overview**: Visual summary of all health metrics with status indicators
- **Detailed Metric View**: Comprehensive information about each metric with interactive charts
- **Data Visualization**: Line charts showing historical trends using fl_chart
- **Local Data Persistence**: Saves data locally using SharedPreferences
- **Status-Based Cards**: Color-coded cards (Green/Orange/Red) based on metric status
- **Real-time Updates**: Pull-to-refresh functionality for data updates

### Bonus Features Implemented
- ✅ **Dark Mode Support**: Full dark theme implementation with toggle switch
- ✅ **Search & Filter**: Search metrics by name and filter by status
- ✅ **Smooth Animations**: Fade, slide, and opacity animations for better UX
- ✅ **Responsive Design**: Optimized layouts for different screen sizes
- ✅ **Clean Architecture**: Well-structured codebase with separation of concerns

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   │   └── app_constants.dart
│   ├── providers/          # State management
│   │   ├── health_provider.dart
│   │   └── theme_provider.dart
│   └── themes/            # Theme configurations
│       └── app_theme.dart
├── data/
│   ├── models/            # Data models
│   │   ├── health_metric.dart
│   │   └── user_health_data.dart
│   ├── repositories/      # Repository pattern
│   │   └── health_repository.dart
│   └── services/          # Data services
│       └── health_data_service.dart
├── presentation/
│   ├── screens/           # UI screens
│   │   ├── dashboard_screen.dart
│   │   └── metric_detail_screen.dart
│   └── widgets/           # Reusable widgets
│       ├── health_metric_card.dart
│       ├── metric_chart.dart
│       ├── summary_card.dart
│       ├── search_bar_widget.dart
│       ├── empty_state_widget.dart
│       └── loading_widget.dart
└── main.dart              # App entry point
```

### Architecture Layers

1. **Presentation Layer** (`presentation/`)
   - UI components and screens
   - Widgets are purely presentational
   - Consumes data from providers

2. **Core Layer** (`core/`)
   - State management (Provider)
   - Theme configurations
   - App constants and utilities

3. **Data Layer** (`data/`)
   - Data models with JSON serialization
   - Repository pattern for data operations
   - Services for data persistence and retrieval

## 🛠️ Technical Stack

### Dependencies
- **flutter**: UI framework
- **provider**: State management (^6.1.1)
- **shared_preferences**: Local data persistence (^2.2.2)
- **fl_chart**: Data visualization (^0.66.0)
- **lottie**: Advanced animations (^3.0.0)
- **intl**: Date formatting (^0.19.0)

### State Management
- **Provider** pattern for reactive state management
- Separate providers for health data and theme
- Clean separation between business logic and UI

### Data Persistence
- **SharedPreferences** for local storage
- JSON serialization for data models
- Repository pattern for data access abstraction

### UI/UX Highlights
- Material Design 3 (Material You)
- Smooth animations and transitions
- Color-coded status indicators
- Responsive card-based layouts
- Dark mode support
- Pull-to-refresh functionality

## 🎨 Design Decisions

### Color Scheme
- **Normal Status**: Green (#4CAF50) - Indicates healthy metrics
- **High Status**: Orange (#FF9800) - Warning for elevated values
- **Low Status**: Red (#F44336) - Alert for below-normal values
- **Primary**: Purple (#6C63FF) - App branding color

### Card Design
- **Border Radius**: 16px for modern, rounded corners
- **Elevation**: Subtle shadows for depth
- **Background Tints**: Status-based color coding for quick recognition
- **Padding**: Consistent spacing (8px, 16px, 24px)

### Navigation
- **Hero Animations**: Smooth transitions between screens
- **Slide Animations**: Cards slide in on screen entry
- **Fade Transitions**: Smooth opacity changes

### Data Visualization
- **Line Charts**: Show metric trends over time
- **Interactive Tooltips**: Tap data points for details
- **Gradient Fill**: Visual appeal under trend lines
- **Dynamic Scales**: Auto-adjusted based on data range

## 📊 Sample Data

The app comes with pre-loaded sample health metrics:

```json
{
  "user": "Alex Chen",
  "last_updated": "2024-01-15",
  "metrics": [
    {
      "name": "Hemoglobin",
      "value": 9.5,
      "unit": "g/dL",
      "status": "low",
      "range": "12 - 16",
      "history": [9.2, 9.3, 9.5]
    },
    // ... more metrics
  ]
}
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / VS Code
- Android SDK / iOS Simulator

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd healthapp
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Build for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🧪 Testing

The app architecture supports easy testing:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Screenshots

### Light Mode
- Dashboard with metric overview
- Summary cards showing statistics
- Search and filter functionality
- Detailed metric view with charts

### Dark Mode
- Full dark theme support
- Adjusted color schemes
- Consistent experience across modes

## 🎯 Future Enhancements

Given more time, I would add:

1. **Backend Integration**
   - REST API integration
   - Real-time data sync
   - User authentication

2. **Advanced Features**
   - Push notifications for critical values
   - Goal setting and tracking
   - Health recommendations based on metrics
   - Export reports (PDF/CSV)

3. **Enhanced Visualizations**
   - Multiple chart types (bar, pie, radar)
   - Comparison views
   - Custom date range selection

4. **Social Features**
   - Share metrics with healthcare providers
   - Family account linking
   - Community health insights

5. **Testing**
   - Unit tests for business logic
   - Widget tests for UI components
   - Integration tests for flows

6. **Accessibility**
   - Screen reader support
   - High contrast mode
   - Font size adjustments
   - Voice commands

7. **Performance**
   - Image caching
   - Lazy loading for large datasets
   - Background sync

## 🤝 Code Quality

### Best Practices Followed
- ✅ Clean code with meaningful names
- ✅ Proper error handling and null safety
- ✅ Consistent formatting and style
- ✅ Separation of concerns
- ✅ DRY (Don't Repeat Yourself) principle
- ✅ Single Responsibility Principle
- ✅ Proper use of const constructors
- ✅ Effective widget composition

### Performance Considerations
- Efficient list rendering with ListView builders
- Proper disposal of controllers and animations
- Optimized rebuilds using Provider
- Minimal widget tree depth
- Async/await for I/O operations

## 👨‍💻 Developer

**Aviral Sharma**

This project was developed as part of a Flutter Developer Assignment to demonstrate:
- UI/UX design capabilities
- State management expertise
- Clean architecture implementation
- Flutter best practices
- Problem-solving skills

## 📄 License

This project is created for assignment purposes.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- fl_chart package for beautiful charts
- Provider package for state management
- Material Design guidelines for UI inspiration

---

**Note**: This app demonstrates production-ready code with proper architecture, error handling, and user experience considerations. The implementation balances feature completeness with code quality and maintainability.
