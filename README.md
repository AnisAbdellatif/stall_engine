# Stall Engine App

A realistic engine stalling simulation app for Assetto Corsa that adds immersive engine management mechanics to your driving experience.

## Description

This app simulates realistic engine stalling behavior in Assetto Corsa, requiring proper clutch and throttle management to keep your engine running. The engine will stall if RPM drops below a configurable threshold while the clutch is engaged, and includes authentic starter sounds and ignition controls.

## Features

-   **Realistic Engine Stalling**: Engine stalls when RPM drops below threshold with clutch engaged
-   **Configurable Stall RPM**: Adjust the RPM threshold at which the engine stalls
-   **Clutch Bite Point Control**: Customize when the clutch starts to engage
-   **Ignition System**: Optional ignition key requirement for starting the engine
-   **Authentic Sound Effects**:
    -   Starter motor sounds (3 stages)
    -   Ignition sound
    -   Engine turn-off sound
    -   Stall sound
-   **In-Game Configuration**: Adjust all settings through the app's GUI while driving

## Installation

### Method 1:

1. Simply drag and drop the zip and the content manager and install it normally as an app

### Method 2:

1. Extract the `stall_engine` folder to your Assetto Corsa apps directory:

    ```
    ...\steamapps\common\assettocorsa\apps\lua\stall_engine\
    ```

2. The app will automatically load when you start Assetto Corsa with Custom Shaders Patch installed.

## Requirements

-   Assetto Corsa with Custom Shaders Patch (CSP)
-   CSP Version 2578 or higher

## Configuration

### Control Bindings

Before using the app, you need to configure two control bindings in Assetto Corsa:

1. **Ignition Button**: Bind `__EXT_LIGHT_D` in Controls menu
2. **Starter Button**: Bind `__EXT_LIGHT_E` in Controls menu

### App Settings

The app provides an in-game configuration window with the following options:

-   **Enable Stall**: Toggle the stalling functionality on/off
-   **Ignition Required**: Require ignition to be on before starting the engine
-   **Sounds Enabled**: Enable/disable all sound effects
-   **Stall RPM**: Set the RPM threshold below which the engine stalls (default: 950 RPM)
-   **Clutch Bite Point**: Adjust when the clutch starts to engage (default: 50%)

## How to Use

1. **Starting the Engine**:

    - Turn on ignition (if enabled)
    - Hold the starter button until the engine starts
    - Listen for the authentic starter motor sequence

2. **Driving**:

    - Keep RPM above the stall threshold when clutch is engaged
    - Use proper clutch technique when starting from a stop
    - Be careful with gear changes at low RPM

3. **Stopping the Engine**:
    - Turn off ignition or press the starter button to kill the engine

## Sound Files

The app includes several authentic sound effects:

-   `Starter1.mp3` - Initial starter engagement
-   `Starter2.mp3` - Starter motor cranking (loops)
-   `Starter3.mp3` - Engine catch and start
-   `Ignition.mp3` - Ignition switch sound
-   `Kill.mp3` - Engine shutdown sound
-   `Stall.mp3` - Engine stall sound

## Configuration Files

-   `config.ini` - Stores user settings and preferences
-   `manifest.ini` - App metadata and CSP configuration

## Version

Current Version: **0.1**

## Author

Created by **Ashtray**

## License

This project is part of the Assetto Corsa Custom Shaders Patch ecosystem.

## Troubleshooting

### Common Issues

1. **App not loading**: Ensure CSP version 2578 or higher is installed
2. **Controls not working**: Check that `__EXT_LIGHT_D` and `__EXT_LIGHT_E` are properly bound in Controls menu
3. **No sounds**: Verify that "Sounds Enabled" is checked in the app settings

### Console Messages

The app provides detailed console output for debugging:

-   Engine start/stop events
-   Configuration changes
-   Control binding warnings

## Contributing

This app is designed to enhance the realism of Assetto Corsa driving. Feel free to modify the configuration values to match your preferred driving style or specific car characteristics.

---

For more information about Custom Shaders Patch apps, visit: https://github.com/ac-custom-shaders-patch/app-csp-defaults
