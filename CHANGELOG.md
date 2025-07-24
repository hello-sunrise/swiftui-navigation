# Changelog
All notable changes to this project will be documented in this file.

**Guiding Principles**
Changelogs are for humans, not machines.
There should be an entry for every single version.
The same types of changes should be grouped.
Versions and sections should be linkable.
The latest version comes first.
The release date of each version is displayed.
Mention whether you follow Semantic Versioning.

**Types of changes**
* `Added` for new features.
* `Changed` for changes in existing functionality.
* `Deprecated` for soon-to-be removed features.
* `Removed` for now removed features.
* `Fixed` for any bug fixes.
* `Security` in case of vulnerabilities.

## [1.6.3] - 2025-07-24

### Fixed
- Support orientation rotation

## [1.6.2] - 2025-06-12

### Fixed
- Updated swift-async-queue 0.7.1

## [1.6.1] - 2025-01-08

### Changed
- Support iOS 16 -> 18

## [1.6.0] - 2024-02-15

### Removed
- Parameter `completion`

### Changed
- Enforced any screen transitions tasks to be executed one after another using internally a FIFO queue

## [1.5.0] - 2023-12-01

### Added
- Method `NavController.setOnNavigationChange()`

## [1.4.1] - 2023-11-13

### Fixed
- Screen background clear with `Transaction.coverOverFullscreen`

## [1.4.0] - 2023-10-16

### Added
- EnvironmentValues `\.isRemovedFromStack`

## [1.3.0] - 2023-10-11

### Added
- Parameter `animated` to `NavController` functions
- Parameters `pushTransition` and `popTransition` to `NavController.push()`

### Removed
- Parameter `transition` to `NavController.push()`

### Fixed
- Dismissing detection of `Transition.sheet`

## [1.2.0] - 2023-10-02

### Added
- `NavHost` parameter `windowBackgroundColor`
- Parameter `defaultTransition` to `NavGraph.screen()`

### Changed
- Renamed `TransitionStyle` to `Transition`

### Fixed
- `backgroundColor` not changing when switching between light and dark mode

## [1.1.0] - 2023-07-19

### Added
- `NavController` instance as environment object in SwiftUI context
-  Sample project

### Fixed
- Transition `coverFullscreen` by setting `window.backgroundColor`

## [1.0.0] - 2023-07-17

### Added
- Migrated project from https://github.com/Dreem-Organization/dreem-ios-navigation/
