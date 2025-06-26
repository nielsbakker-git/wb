# WB - Water & Body iOS App

A comprehensive iOS application for tracking water intake, body measurements, workouts, and nutrition.

## Features

- **Water Tracking**: Log daily water intake with customizable goals
- **Body Measurements**: Track body measurements over time
- **Workout Management**: Log workouts, save routines, and view history
- **Nutrition Tracking**: Log meals and track nutritional intake
- **Dashboard**: Overview of daily progress and statistics
- **User Profile**: Personal settings and preferences

## Project Structure

```
WB/
├── WB/                    # Main iOS app source code
│   ├── WBApp.swift       # App entry point
│   ├── ContentView.swift # Main content view
│   ├── MainTabView.swift # Tab navigation
│   ├── Views/            # UI Views
│   │   ├── DashboardView.swift
│   │   ├── WaterLogView.swift
│   │   ├── BodyMeasurementsView.swift
│   │   ├── WorkoutsView.swift
│   │   ├── MealLogView.swift
│   │   └── UserProfileView.swift
│   ├── Models/           # Data models
│   │   └── Models.swift
│   ├── Managers/         # Business logic
│   │   └── DataManager.swift
│   └── Components/       # Reusable UI components
│       ├── StatCard.swift
│       └── FilterChip.swift
├── WBTests/              # Unit tests
├── WBUITests/            # UI tests
└── Data/                 # Sample data files
    ├── allexercises.csv
    ├── allexercises.json
    ├── fooditems.csv
    └── fooditems.json
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd WB
   ```

2. Open the project in Xcode:
   ```bash
   open WB.xcodeproj
   ```

3. Build and run the project on your device or simulator.

## Data Files

The project includes sample data files:
- `allexercises.csv/json`: Exercise database
- `fooditems.csv/json`: Food items database
- `convert_csv_to_json.py`: Utility script to convert CSV to JSON

## Development

### Adding New Features

1. Create new Swift files in the appropriate directory
2. Follow the existing naming conventions
3. Update the README.md with new features

### Testing

- Unit tests are located in `WBTests/`
- UI tests are located in `WBUITests/`
- Run tests using Cmd+U in Xcode

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please open an issue on GitHub. 