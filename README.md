> **Important:** The folder must be named `Munk-Carwash` (exactly as shown) for the script to work correctly.

# Munk-Carwash

An RP-style car wash script for FiveM ESX with NPC, ox_target, language switching, and premium shine.

## Requirements / Dependencies
- **FiveM server**
- **ESX** (es_extended)
- **ox_target**
- **okokNotify** (optional, for better notifications)


## Download and Installation

Here you can download my RP Carwash script for FiveM ESX. Remember, the folder must be named **Munk-Carwash** (exactly as shown), or the script will not work!

**Download:** [DOWNLOAD LINK]

### Installation
1. Extract the `Munk-Carwash` folder into your `resources` directory.
2. Add the following to your `server.cfg`:
   ```
   ensure Munk-Carwash
   ```
3. Make sure the following resources start before this script:
   - `es_extended`
   - `ox_target`
   - (optional) `okokNotify`

Read the README.md for more information about setup, requirements, and features.

## Configuration
- Edit `config.lua` for prices, language, locations, and settings.
- Set language with `Config.Locale = "da"` (Danish) or `"en"` (English).
- Add more car wash locations in `Config.Locations`.

## Features
- NPC washes your car with animation and returns to its home position.
- ox_target menu with normal and premium wash.
- Premium wash gives extra shine.
- Blip on the map.
- Notifications via okokNotify, ESX, or GTA native.
- Danish and English language support.

## Support
If you experience issues, check that all dependencies are installed and started correctly.

---

**Enjoy the script!**
