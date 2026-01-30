# MyTodoList

A modern iOS todo app with a sleek dark UI design.

## Features

- Create, complete, and delete tasks
- Priority levels (Low / Medium / High)
- Optional due dates with overdue indicators
- Search functionality
- Swipe-to-delete for pending tasks
- Clear all completed tasks at once
- Data persisted locally using SwiftData

## Screenshots

The app features a dark purple gradient theme with card-based task display.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository
2. Open `MyTodoList.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (Cmd+R)

## Project Structure

```
MyTodoList/
├── MyTodoListApp.swift    # App entry point
├── Item.swift             # Data model
├── ContentView.swift      # Main task list view
├── AddTodoView.swift      # New task creation view
└── Assets.xcassets/       # App icons and colors
```

## Tech Stack

- **SwiftUI** - Declarative UI framework
- **SwiftData** - Local data persistence
- **Swift** - Programming language

## License

MIT License
