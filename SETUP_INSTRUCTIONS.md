# Automated Setup Instructions

This project includes automated scripts to make setup and running the app as easy as possible!

## 🚀 Quick Start (One Command!)

### Step 1: Run Setup Script

```bash
chmod +x setup.sh run.sh
./setup.sh
```

This single command will:
- ✅ Check all prerequisites (Node.js, CocoaPods, Xcode)
- ✅ Clean any previous installations
- ✅ Install all npm dependencies
- ✅ Install all iOS dependencies (CocoaPods)
- ✅ Verify configuration
- ✅ Display configuration summary

**Time**: About 5-10 minutes (mostly downloading dependencies)

### Step 2: Run the App

```bash
./run.sh
```

This will:
- ✅ Start Metro bundler
- ✅ Launch the app on iOS Simulator
- ✅ Keep running until you press Ctrl+C

**Time**: About 2-3 minutes (first build is slower)

## 📋 What the Scripts Do

### `setup.sh` - Complete Setup Automation

This script performs a complete setup:

1. **Checks Prerequisites**
   - Node.js 18+ installed
   - npm installed
   - CocoaPods installed
   - Xcode installed
   - Xcode Command Line Tools installed
   - Watchman installed (optional)

2. **Verifies Configuration**
   - Checks `okta.config.js` exists and is configured
   - Checks `Info.plist` exists and is configured
   - Confirms no placeholders remain

3. **Cleans Previous Installations**
   - Removes old `node_modules`
   - Removes old iOS `Pods`
   - Clears Metro cache
   - Clears Watchman cache (if installed)

4. **Installs Dependencies**
   - Runs `npm install` for JavaScript dependencies
   - Runs `pod install` for iOS native dependencies

5. **Verifies Installation**
   - Checks all dependencies installed correctly
   - Verifies Okta SDK is present
   - Confirms React Navigation is installed

6. **Displays Summary**
   - Shows your configuration
   - Provides next steps

### `run.sh` - Easy App Execution

This script simplifies running the app:

1. **Checks Dependencies**
   - Verifies `node_modules` exists
   - Verifies `Pods` exists

2. **Manages Metro**
   - Kills any existing Metro instances
   - Starts Metro bundler in background
   - Waits for Metro to be ready

3. **Launches App**
   - Builds and launches on iOS Simulator
   - Shows build progress

4. **Keeps Running**
   - Metro stays running
   - Shows console logs
   - Ctrl+C to stop

## 🔧 Configuration (Already Done!)

Your configuration has been pre-configured for Cargill's QA Okta environment:

### Okta Configuration (`okta.config.js`)
- ✅ **Issuer**: `https://login-qa-customer.cargill.com/oauth2/auszzmfs36uUBqxYU0h7`
- ✅ **Client ID**: `0oa2jt1ncajFZjObu0h8`
- ✅ **Redirect URI**: `com.cargill.oktapoc:/callback`

### iOS Configuration (`ios/OktaPOC/Info.plist`)
- ✅ **App Scheme**: `com.cargill.oktapoc`

## ⚠️ Important: Okta Application Settings

Make sure your Okta application has these settings:

1. **Application Type**: Native Application
2. **Grant Types**:
   - ✅ Authorization Code
   - ✅ Refresh Token
3. **Sign-in redirect URIs**:
   - `com.cargill.oktapoc:/callback`
4. **Sign-out redirect URIs**:
   - `com.cargill.oktapoc:/callback`

## 📝 Manual Setup (If Scripts Fail)

If the automated scripts fail, you can run commands manually:

### Install Dependencies
```bash
# Install npm dependencies
npm install

# Install iOS dependencies
cd ios
pod install
cd ..
```

### Run the App
```bash
# Terminal 1: Start Metro
npm start

# Terminal 2: Run iOS
npm run ios
```

## 🎯 What to Expect

### First Time Running `setup.sh`

```
========================================
Step 1: Checking Prerequisites
========================================

✓ Node.js is installed: v18.17.0
✓ npm is installed: 9.8.1
✓ CocoaPods is installed: 1.12.1
✓ Xcode 14.3 is installed
✓ Xcode Command Line Tools are installed

========================================
Step 2: Verifying Configuration
========================================

✓ okta.config.js found
✓ okta.config.js has been configured
✓ Info.plist found
✓ Info.plist has been configured

[... continues through all steps ...]

========================================
Setup Complete! 🎉
========================================

✓ All dependencies installed successfully
✓ Configuration verified

Next Steps:
  Run: ./run.sh
```

### Running `run.sh`

```
========================================
Okta React Native iOS POC
========================================

========================================
Starting Metro Bundler
========================================

✓ Metro started (PID: 12345)
ℹ Waiting for Metro to be ready...
✓ Metro is ready!

========================================
Launching iOS App
========================================

[Build output...]

✓ App launched successfully!

========================================
App is Running
========================================

✓ App is running on iOS Simulator
✓ Metro bundler is running

Press Ctrl+C to stop Metro and exit
```

## 🐛 Troubleshooting Scripts

### "Permission denied" when running scripts

**Fix**:
```bash
chmod +x setup.sh run.sh
```

### "Node.js is not installed"

**Fix**: Install Node.js from https://nodejs.org/
```bash
# Check version after installing
node --version  # Should be 18+
```

### "CocoaPods is not installed"

**Fix**:
```bash
sudo gem install cocoapods
```

### "Xcode is not installed"

**Fix**: Install Xcode from Mac App Store

### Setup script fails at "npm install"

**Fix**:
```bash
# Clear npm cache
npm cache clean --force

# Run setup again
./setup.sh
```

### Setup script fails at "pod install"

**Fix**:
```bash
# Update CocoaPods repo
cd ios
pod repo update
pod install
cd ..
```

### Run script can't find Metro on port 8081

**Fix**:
```bash
# Kill any process using port 8081
lsof -ti:8081 | xargs kill -9

# Run again
./run.sh
```

## 🔄 Alternative: Manual Commands

If you prefer not to use the scripts:

### Full Setup
```bash
# Install dependencies
npm install
cd ios && pod install && cd ..

# Run app
npm start                    # Terminal 1
npm run ios                  # Terminal 2
```

### Clean and Rebuild
```bash
# Clean everything
rm -rf node_modules package-lock.json
rm -rf ios/Pods ios/Podfile.lock
watchman watch-del-all

# Reinstall
npm install
cd ios && pod install && cd ..

# Run
npm start -- --reset-cache   # Terminal 1
npm run ios                  # Terminal 2
```

## 📱 Testing on Physical Device

The scripts run on iOS Simulator by default. To run on a physical iPhone:

1. **Open in Xcode**:
   ```bash
   open ios/OktaPOC.xcworkspace
   ```

2. **Configure Signing**:
   - Select your Team
   - Xcode will manage provisioning

3. **Select Device**:
   - Connect iPhone via USB
   - Select from device dropdown

4. **Run**:
   - Click Run (▶️) button

5. **Trust Certificate** (first time):
   - Settings → General → VPN & Device Management
   - Trust your developer certificate

## 📚 Additional Documentation

- **README.md** - Complete project documentation
- **GETTING_STARTED.md** - Detailed beginner's guide
- **QUICKSTART.md** - Quick reference guide
- **OKTA_SETUP.md** - Okta configuration details
- **TROUBLESHOOTING.md** - Common issues and solutions
- **PROJECT_OVERVIEW.md** - Technical architecture

## ✅ Script Features

### Color-Coded Output
- 🔵 Blue - Information messages
- ✅ Green - Success messages
- ⚠️ Yellow - Warnings
- ❌ Red - Errors

### Progress Tracking
- Each step is clearly labeled
- Shows current progress
- Provides time estimates

### Error Handling
- Stops on errors
- Shows clear error messages
- Provides fix suggestions

### Cleanup
- Ctrl+C safely stops processes
- Kills Metro on exit
- Cleans up background processes

## 🎉 Success!

If you see this after running `./setup.sh`:

```
========================================
Setup Complete! 🎉
========================================
```

And this after running `./run.sh`:

```
✓ App is running on iOS Simulator
✓ Metro bundler is running
```

You're all set! The app is running and you can test the Okta login flow.

## 🆘 Need Help?

1. Check **TROUBLESHOOTING.md** for common issues
2. Review the error message from the script
3. Try manual setup commands
4. Check the detailed documentation

## 💡 Pro Tips

1. **First Run**: Setup and first build take longer (10-15 minutes total)
2. **Subsequent Runs**: Much faster (2-3 minutes)
3. **Keep Metro Running**: Enables Fast Refresh for quick iteration
4. **Use Scripts**: They handle edge cases and cleanup automatically
5. **Read Logs**: Scripts show detailed progress and errors

Happy coding! 🚀
