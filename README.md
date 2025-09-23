# Dispatcher - Fleet Management System

A Flutter-based fleet management application for tracking orders, trips, and vehicle operations with comprehensive state persistence and business rule enforcement.

## Architecture

**Clean Architecture + Bloc Pattern**

The app follows Clean Architecture principles with clear separation of concerns:

**Why Clean Architecture?**
- **Testability**: Clear boundaries make unit testing straightforward
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features without breaking existing code
- **Independence**: Business logic is independent of UI and data sources

## State Machine

### Order State Machine

## State Machine
![State Machine](https://drive.google.com/uc?export=view&id=1GNug07qeFr_BCjcqCAlQsbhFk7iXP8_l)

### State Transition Rules
- **Order**: Cannot transition from Completed/Failed back to Pending
- **Trip**: Cannot start without assigned orders; cannot cancel completed trips
- **Stop**: Cannot complete until all orders are processed; auto-completes when all orders done
- **TripExecution**: Automatically manages state based on trip and stop statuses

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dispatcher
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

### Running the App

**Development Environment:**
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

**Production Environment:**
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

**Specific Platforms:**
```bash
# Android
flutter run --flavor dev -t lib/main_dev.dart -d android

# iOS
flutter run --flavor dev -t lib/main_dev.dart -d ios

# Web
flutter run --flavor dev -t lib/main_dev.dart -d web
```

## Key Features

### 🚀 **Comprehensive State Persistence**
- App restarts to exact same state (no data reloading)
- Navigation stack restoration
- Form state persistence
- Filter state persistence

### 📱 **Business Rules Implementation**
- **COD Accuracy**: Cash collection validation with tolerance
- **Partial Delivery Policy**: Prevents partial delivery for discounted orders
- **Timezone Awareness**: Depot timezone handling for all date/time operations

### 🎯 **State Management**
- **HydratedBloc**: Automatic state persistence
- **AppStateManager**: Global app state coordination
- **NavigationRestorationService**: Navigation state recovery

## Trade-offs Made

### ✅ **Chosen Approaches**

1. **HydratedBloc over SharedPreferences**
   - **Why**: Automatic serialization, better type safety
   - **Trade-off**: Slightly more complex setup, but better maintainability

2. **Clean Architecture over Simple MVC**
   - **Why**: Better testability, separation of concerns
   - **Trade-off**: More boilerplate code, but easier to maintain and scale

3. **Bloc over Provider/Riverpod**
   - **Why**: Better state management for complex business logic
   - **Trade-off**: Steeper learning curve, but more predictable state flow

### ⚠️ **Limitations**

1. **No Real-time Updates**: Data changes only on app restart
2. **Single Device**: No multi-device synchronization
3. **Limited Scalability**: Designed for single depot operations

## AI Assistance

### �� **Where AI Was Used**

1. **Architecture Design**: AI helped structure the Clean Architecture layers and state management patterns
2. **Business Logic Implementation**: Complex state machines and business rules were implemented with AI guidance
3. **Error Handling**: AI assisted in creating comprehensive error handling and validation logic
4. **State Persistence**: AI helped design the comprehensive state persistence system
5. **Code Refactoring**: AI assisted in fixing compilation errors and improving code quality

### 🎯 **Why AI Was Valuable**

- **Complex State Management**: AI helped navigate the intricacies of Bloc pattern and state persistence
- **Business Rule Implementation**: AI assisted in translating business requirements into code
- **Error Resolution**: AI quickly identified and fixed compilation and runtime errors
- **Architecture Decisions**: AI provided insights on trade-offs and best practices

## Project Structure