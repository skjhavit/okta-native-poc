# Quick Start - Complete Setup Guide

This guide shows the **complete setup process** in the correct order.

## 🚀 Three-Step Setup

### Step 1: Bootstrap the Project (First Time Only)

This creates the Xcode project files:

```bash
chmod +x bootstrap.sh setup.sh run.sh
./bootstrap.sh
```

**What it does:**
- Creates Xcode project files (.xcodeproj)
- Preserves your Okta configuration
- Sets up the iOS project structure

**Time**: ~2-3 minutes

---

### Step 2: Install Dependencies

This installs all npm and iOS dependencies:

```bash
./setup.sh
```

**What it does:**
- Checks prerequisites (Node.js, CocoaPods, Xcode)
- Installs npm packages
- Runs `pod install` for iOS dependencies
- Verifies configuration

**Time**: ~5-10 minutes

---

### Step 3: Run the App

```bash
./run.sh
```

**What it does:**
- Starts Metro bundler
- Builds and launches app on iOS Simulator
- Shows logs

**Time**: ~2-3 minutes (first build)

---

## 📋 Complete Command Sequence

Copy and paste these commands:

```bash
# 1. Make scripts executable
chmod +x bootstrap.sh setup.sh run.sh fix-cocoapods.sh

# 2. Bootstrap the project (creates Xcode files)
./bootstrap.sh

# 3. Install dependencies
./setup.sh

# 4. Run the app
./run.sh
```

---

## ⚠️ Important: CocoaPods PATH Issue

If `setup.sh` says "CocoaPods is not installed" but you just installed it:

### Quick Fix:
```bash
# Close and reopen your terminal, then try:
pod --version

# If that works, run setup again:
./setup.sh
```

### Alternative: Use Homebrew (Recommended)
```bash
# Uninstall gem version
sudo gem uninstall cocoapods

# Install via Homebrew
brew install cocoapods

# Verify
pod --version

# Run setup
./setup.sh
```

### Manual PATH Fix:
```bash
# Reload your shell configuration
source ~/.zshrc        # if using zsh
# OR
source ~/.bash_profile  # if using bash

# Verify
pod --version

# Run setup
./setup.sh
```

---

## 🎯 What You Should See

### After `./bootstrap.sh`:
```
========================================
Bootstrap Complete! 🎉
========================================

✓ Xcode project files created
✓ Okta configuration preserved

Next Steps:
  1. Run the setup script:
     ./setup.sh
```

### After `./setup.sh`:
```
========================================
Setup Complete! 🎉
========================================

✓ All dependencies installed successfully
✓ Configuration verified

To run: ./run.sh
```

### After `./run.sh`:
```
========================================
App is Running
========================================

✓ App is running on iOS Simulator
✓ Metro bundler is running

Press Ctrl+C to stop
```

---

## 🔧 Troubleshooting

### "Xcode project not found!"

**Solution**: Run bootstrap first:
```bash
./bootstrap.sh
```

### "CocoaPods is not installed"

**Solution**: See CocoaPods PATH Issue section above, or:
```bash
brew install cocoapods
```

### "node_modules not found"

**Solution**: Run setup:
```bash
./setup.sh
```

### "Metro bundler not running"

**Solution**: Start Metro manually:
```bash
npm start
```

---

## 📱 After Setup - Testing the App

Once the app is running:

1. **Login Screen** appears
2. Tap **"Login with Okta"**
3. **Safari opens** with Cargill Okta login
4. **Enter credentials** for Cargill QA environment
5. **Complete authentication**
6. **App opens** and shows Home screen with your profile

---

## ⚙️ Configuration (Already Set)

Your project is pre-configured for Cargill:

- **Okta Issuer**: `https://login-qa-customer.cargill.com/oauth2/auszzmfs36uUBqxYU0h7`
- **Client ID**: `0oa2jt1ncajFZjObu0h8`
- **Redirect URI**: `com.cargill.oktapoc:/callback`
- **App Scheme**: `com.cargill.oktapoc`

Make sure your Okta application has:
- ✅ Application Type: Native Application
- ✅ Grant Types: Authorization Code, Refresh Token
- ✅ Sign-in redirect URI: `com.cargill.oktapoc:/callback`
- ✅ Sign-out redirect URI: `com.cargill.oktapoc:/callback`

---

## 📚 More Information

- **SETUP_INSTRUCTIONS.md** - Detailed setup guide
- **README.md** - Complete documentation
- **TROUBLESHOOTING.md** - Common issues
- **PROJECT_OVERVIEW.md** - Technical architecture

---

## ✅ Success Indicators

You'll know everything worked when:

- ✅ `./bootstrap.sh` completes without errors
- ✅ `./setup.sh` shows "Setup Complete! 🎉"
- ✅ `./run.sh` launches iOS Simulator
- ✅ App shows login screen
- ✅ Tapping "Login with Okta" opens Safari
- ✅ After login, app shows home screen with user data

---

## 🆘 Still Having Issues?

1. Check **TROUBLESHOOTING.md** for common problems
2. Make sure all prerequisites are installed:
   - Node.js 18+
   - CocoaPods
   - Xcode 14+
3. Try the manual setup steps in **SETUP_INSTRUCTIONS.md**

---

**Happy coding! 🚀**
