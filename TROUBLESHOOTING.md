# Troubleshooting Guide

This guide covers common issues and solutions when setting up and running the Okta React Native iOS POC.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Configuration Issues](#configuration-issues)
- [Build Issues](#build-issues)
- [Runtime Issues](#runtime-issues)
- [Authentication Issues](#authentication-issues)
- [Redirect Issues](#redirect-issues)
- [Token Issues](#token-issues)
- [Device-Specific Issues](#device-specific-issues)
- [Debugging Tips](#debugging-tips)

## Installation Issues

### Issue: `npm install` fails

**Error**: `npm ERR! code ERESOLVE`

**Solution**:
```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and package-lock
rm -rf node_modules package-lock.json

# Reinstall
npm install
```

### Issue: `pod install` fails

**Error**: `[!] CocoaPods could not find compatible versions for pod "OktaOidc"`

**Solution**:
```bash
cd ios

# Update CocoaPods repo
pod repo update

# Remove Pods and reinstall
rm -rf Pods Podfile.lock
pod deintegrate
pod install

cd ..
```

### Issue: "You don't have write permissions for /Library/Ruby/Gems"

**Solution**:
```bash
# Use sudo to install CocoaPods
sudo gem install cocoapods

# Or use Homebrew (recommended)
brew install cocoapods
```

### Issue: Xcode Command Line Tools not found

**Error**: `xcode-select: error: tool 'xcodebuild' requires Xcode`

**Solution**:
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Set the path to Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

## Configuration Issues

### Issue: "Failed to initialize Okta SDK"

**Possible Causes**:
1. Incorrect `okta.config.js` values
2. Malformed URLs
3. Missing required fields

**Solution**:
```javascript
// Verify okta.config.js has correct format:
export default {
  // No https:// prefix, no trailing slash
  issuer: 'https://dev-123456.okta.com/oauth2/default',

  // Client ID should be alphanumeric
  clientId: '0oa5abc123xyz789',

  // Must use custom scheme, not http/https
  redirectUri: 'com.myapp:/callback',

  // Same as redirectUri
  endSessionRedirectUri: 'com.myapp:/callback',

  // Same as issuer
  discoveryUri: 'https://dev-123456.okta.com/oauth2/default',

  // Array of strings
  scopes: ['openid', 'profile', 'email', 'offline_access'],

  // Boolean
  requireHardwareBackedKeyStore: false,
};
```

### Issue: "Invalid configuration" on app start

**Solution**:
1. Check that `{{OKTA_DOMAIN}}` doesn't include `https://`
2. Verify Client ID is copied correctly (no spaces)
3. Ensure redirect URI uses a custom scheme, not http/https
4. Check for typos in the configuration file

### Issue: URL scheme not recognized

**Error**: App doesn't open after Okta redirect

**Solution**:
1. Open `ios/OktaPOC/Info.plist`
2. Find `CFBundleURLSchemes`
3. Ensure the scheme matches your redirect URI:
   ```xml
   <key>CFBundleURLSchemes</key>
   <array>
     <string>com.myapp</string> <!-- Should match first part of redirect URI -->
   </array>
   ```
4. If redirect URI is `com.myapp:/callback`, scheme should be `com.myapp`

## Build Issues

### Issue: "No bundle URL present"

**Error**: Red screen with "No bundle URL present"

**Solution**:
```bash
# Start Metro bundler in a separate terminal
npm start

# In another terminal, run the app
npm run ios
```

### Issue: "Command PhaseScriptExecution failed"

**Solution**:
```bash
# Clean build folder in Xcode
# Or via command line:
cd ios
xcodebuild clean -workspace OktaPOC.xcworkspace -scheme OktaPOC
cd ..

# Rebuild
npm run ios
```

### Issue: "Signing for 'OktaPOC' requires a development team"

**Solution**:
1. Open `ios/OktaPOC.xcworkspace` in Xcode
2. Select the project in the navigator
3. Select the `OktaPOC` target
4. Go to "Signing & Capabilities"
5. Select your Team from the dropdown
6. Let Xcode automatically manage signing

### Issue: Build succeeds but app crashes immediately

**Solution**:
```bash
# Reset Metro cache
npm start -- --reset-cache

# Clean and rebuild
cd ios
xcodebuild clean
cd ..
npm run ios
```

### Issue: "Multiple commands produce" error

**Solution**:
1. Open Xcode
2. Go to File → Workspace Settings
3. Change Build System to "Legacy Build System"
4. Clean and rebuild

## Runtime Issues

### Issue: App shows white screen on launch

**Possible Causes**:
1. Metro bundler not running
2. JavaScript bundle not loaded
3. Initialization error

**Solution**:
```bash
# Check Metro bundler is running
npm start

# Check for errors in Metro bundler console
# Check React Native debugger console

# Reset everything:
watchman watch-del-all
rm -rf node_modules
npm install
cd ios && pod install && cd ..
npm start -- --reset-cache
```

### Issue: "invariant violation" error

**Solution**:
```bash
# Clear React Native cache
npm start -- --reset-cache

# If that doesn't work, clear all caches:
watchman watch-del-all
rm -rf $TMPDIR/react-*
rm -rf $TMPDIR/metro-*
npm start -- --reset-cache
```

### Issue: "Network request failed"

**Possible Causes**:
1. Metro bundler not accessible
2. Network connectivity issues
3. Firewall blocking connection

**Solution**:
```bash
# Ensure Metro bundler is running on default port
npm start

# Check firewall settings
# On physical device, ensure device and Mac are on same network
```

## Authentication Issues

### Issue: "OAuth authentication failed"

**Error**: Alert shows "OAuth authentication failed"

**Possible Causes**:
1. Incorrect Okta domain
2. Wrong client ID
3. Invalid redirect URI
4. Grant types not enabled in Okta

**Solution**:
1. Verify Okta configuration in `okta.config.js`
2. Check Okta app settings:
   - Application type: Native Application
   - Grant types: Authorization Code, Refresh Token
   - PKCE: Enabled
3. Ensure redirect URIs match exactly

### Issue: "Sign in failed"

**Error**: Alert shows "Unable to sign in"

**Possible Causes**:
1. Okta service down
2. Network connectivity issues
3. Invalid credentials

**Solution**:
1. Check internet connection
2. Verify Okta domain is accessible: `https://{{OKTA_DOMAIN}}`
3. Try signing in directly at `https://{{OKTA_DOMAIN}}`
4. Check Okta status: https://status.okta.com/

### Issue: User cancelled login but app shows error

**Solution**:
This is expected behavior. The code handles `user_cancelled_login` error code:
```javascript
if (error.code === 'user_cancelled_login') {
  console.log('User cancelled login');
  // No alert shown
}
```

### Issue: Login works but user data not displayed

**Solution**:
1. Check console logs for errors
2. Verify scopes include `profile` and `email`
3. Check that user has profile data in Okta:
   - Go to Okta Admin → Directory → People
   - Find the user
   - Verify profile information is filled in

## Redirect Issues

### Issue: Safari opens but doesn't redirect back to app

**Possible Causes**:
1. URL scheme not configured in Info.plist
2. Scheme doesn't match redirect URI
3. iOS doesn't recognize the scheme

**Solution**:
1. Verify `Info.plist` configuration:
   ```xml
   <key>CFBundleURLSchemes</key>
   <array>
     <string>{{APP_SCHEME}}</string>
   </array>
   ```

2. Ensure scheme matches redirect URI:
   - Redirect URI: `com.myapp:/callback`
   - Scheme: `com.myapp` (no `:/callback`)

3. Rebuild the app after changing Info.plist

4. Test the URL scheme:
   ```bash
   # On simulator, use this in terminal:
   xcrun simctl openurl booted "com.myapp:/callback?code=test"
   ```

### Issue: "Invalid redirect URI" error from Okta

**Possible Causes**:
1. Redirect URI not configured in Okta app
2. Redirect URI in code doesn't match Okta
3. Typo in redirect URI

**Solution**:
1. Check Okta app → General → Sign-in redirect URIs
2. Ensure it matches `okta.config.js` → `redirectUri`
3. Case-sensitive match required
4. Include the path (e.g., `/callback`)

### Issue: Redirect works but app shows "deep link not handled"

**Solution**:
The Okta SDK should automatically handle the redirect. If you see this error:
1. Check that `createConfig` was called before `signIn`
2. Verify EventEmitter listeners are set up in App.js
3. Check console logs for SDK initialization errors

## Token Issues

### Issue: "Failed to get access token"

**Possible Causes**:
1. User not authenticated
2. Tokens expired
3. Tokens not stored properly

**Solution**:
```javascript
// Check if user is authenticated first
import {isAuthenticated} from '@okta/okta-react-native';

const authenticated = await isAuthenticated();
if (!authenticated) {
  // Redirect to login
  navigation.replace('Login');
  return;
}

// Then get token
const {access_token} = await getAccessToken();
```

### Issue: "Token has expired"

**Solution**:
The SDK should automatically refresh tokens. If you see this error:
1. Ensure `offline_access` scope is included
2. Check that Refresh Token grant type is enabled in Okta
3. Try signing out and signing in again

### Issue: Tokens not persisting after app restart

**Solution**:
This shouldn't happen as tokens are stored in Keychain. If it does:
1. Check device has Keychain access
2. Verify no errors during token storage
3. Try uninstalling and reinstalling the app
4. Check for iOS Keychain permission issues

## Device-Specific Issues

### Issue: Works on simulator but not on physical device

**Possible Causes**:
1. Device not trusted for development
2. Provisioning profile issues
3. Network configuration differences

**Solution**:
1. Trust developer certificate on device:
   - Settings → General → VPN & Device Management
   - Trust your developer certificate

2. Verify device is connected to internet

3. Ensure Mac and device are on same network (for Metro)

4. Check Xcode shows device as connected

### Issue: "Could not connect to development server" on physical device

**Solution**:
```bash
# Get your Mac's IP address
ipconfig getifaddr en0

# Ensure device can reach this IP
# On device, open Safari and go to http://<IP>:8081

# Or configure React Native to use IP:
# In ios/OktaPOC/AppDelegate.mm, modify jsCodeLocation
```

### Issue: App installed but icon is grayed out

**Possible Causes**:
1. Provisioning profile issue
2. App not fully installed

**Solution**:
1. Delete the app from device
2. Rebuild and reinstall from Xcode
3. Verify provisioning profile is valid

## Debugging Tips

### Enable Okta SDK Debug Logs

Add to your `App.js`:
```javascript
import {EventEmitter} from '@okta/okta-react-native';

// Log all Okta events
EventEmitter.addListener('*', (event) => {
  console.log('Okta Event:', event);
});
```

### View Network Requests

1. Open React Native debugger
2. Enable Network inspection
3. Watch for requests to Okta domain

### Check Metro Bundler Logs

The Metro bundler console shows:
- Bundle build status
- Console.log output
- React errors
- Network requests

### Use Xcode Console

1. Open `ios/OktaPOC.xcworkspace`
2. Run from Xcode
3. View console output in bottom panel
4. Filter for "Okta" to see SDK logs

### Debug on Physical Device

1. Connect device via USB
2. Open Xcode
3. Select device from dropdown
4. Run and view console logs

### Check React Native Debugger

```bash
# Start debugger (if installed)
open "rndebugger://set-debugger-loc?host=localhost&port=8081"

# In app, shake device and select "Debug"
```

### Inspect iOS Keychain

You can't directly inspect Keychain in simulator, but you can:
```javascript
import {isAuthenticated, getAccessToken} from '@okta/okta-react-native';

// Check authentication status
const isAuth = await isAuthenticated();
console.log('Is authenticated:', isAuth);

// Try to get token
try {
  const {access_token} = await getAccessToken();
  console.log('Token exists:', !!access_token);
} catch (error) {
  console.log('No token:', error);
}
```

### Reset Everything

If all else fails, complete reset:
```bash
# 1. Clean React Native
watchman watch-del-all
rm -rf node_modules
rm -rf $TMPDIR/react-*
rm -rf $TMPDIR/metro-*
npm cache clean --force

# 2. Clean iOS
cd ios
rm -rf Pods Podfile.lock
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData
pod deintegrate

# 3. Reinstall
cd ..
npm install
cd ios && pod install && cd ..

# 4. Start fresh
npm start -- --reset-cache

# 5. In new terminal
npm run ios
```

## Getting Help

If you're still stuck:

1. **Check the logs**: Most issues show helpful error messages
2. **Search GitHub Issues**: [Okta React Native SDK Issues](https://github.com/okta/okta-react-native/issues)
3. **Okta Community**: [Okta Developer Forum](https://devforum.okta.com/)
4. **Stack Overflow**: Tag questions with `okta` and `react-native`

## Common Error Messages Reference

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| "No bundle URL present" | Metro not running | Run `npm start` |
| "Failed to initialize Okta SDK" | Config error | Check `okta.config.js` |
| "Invalid redirect URI" | URI mismatch | Match Okta app and code |
| "OAuth authentication failed" | Grant type issue | Enable Authorization Code |
| "Could not connect to server" | Network issue | Check Metro bundler |
| "Signing requires team" | Xcode config | Set Team in Xcode |
| "Command PhaseScriptExecution failed" | Build cache | Clean build folder |
| "Token has expired" | No refresh | Enable offline_access |
| "Deep link not handled" | SDK not ready | Check initialization |
| "Network request failed" | Connectivity | Check internet connection |
