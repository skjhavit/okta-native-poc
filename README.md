# Okta React Native iOS POC

A complete, production-ready proof-of-concept for integrating Okta authentication into a React Native iOS application using OAuth 2.0 + PKCE flow.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)

## Overview

This POC demonstrates a secure, native iOS authentication flow using Okta. The implementation follows OAuth 2.0 best practices with PKCE (Proof Key for Code Exchange) for enhanced security in mobile applications.

**Key Characteristics:**
- ✅ iOS-only implementation (not a web view)
- ✅ PKCE-based OAuth 2.0 flow
- ✅ Secure browser-based authentication (Safari)
- ✅ iOS Keychain for secure token storage
- ✅ Automatic token refresh
- ✅ Complete login/logout flow

## Features

- **Secure Authentication**: Browser-based OAuth with PKCE
- **Token Management**: Automatic secure storage in iOS Keychain
- **User Profile**: Retrieve and display user information
- **ID Token Claims**: Access all user claims from ID token
- **Session Management**: Proper login/logout flow
- **Error Handling**: Comprehensive error handling and user feedback

## Prerequisites

Before you begin, ensure you have the following installed on your macOS machine:

- **macOS**: Required for iOS development
- **Node.js**: 18 or later
- **Xcode**: Latest version (14+)
- **Xcode Command Line Tools**: `xcode-select --install`
- **CocoaPods**: `sudo gem install cocoapods`
- **Watchman** (optional but recommended): `brew install watchman`
- **An Okta Account**: [Sign up for free](https://developer.okta.com/signup/)

## Quick Start

### 1. Clone and Install Dependencies

```bash
# Navigate to project directory
cd okta-native-poc

# Install npm dependencies
npm install

# Install iOS dependencies
cd ios && pod install && cd ..
```

### 2. Configure Okta Application

See [OKTA_SETUP.md](./OKTA_SETUP.md) for detailed Okta configuration instructions.

**Quick Summary:**
1. Create a **Native Application** in Okta
2. Enable **PKCE** (disabled by default for native apps)
3. Configure redirect URIs (login and logout)
4. Note your **Client ID** and **Okta Domain**

### 3. Update Configuration

Edit `okta.config.js` and replace the placeholders:

```javascript
export default {
  issuer: 'https://{{OKTA_DOMAIN}}/oauth2/default',
  clientId: '{{OKTA_CLIENT_ID}}',
  redirectUri: '{{IOS_REDIRECT_URI}}',
  endSessionRedirectUri: '{{IOS_REDIRECT_URI}}',
  discoveryUri: 'https://{{OKTA_DOMAIN}}/oauth2/default',
  scopes: ['openid', 'profile', 'email', 'offline_access'],
  requireHardwareBackedKeyStore: false,
};
```

**Example:**
```javascript
export default {
  issuer: 'https://dev-123456.okta.com/oauth2/default',
  clientId: '0oa5abc123xyz789',
  redirectUri: 'com.mycompany.oktapoc:/callback',
  endSessionRedirectUri: 'com.mycompany.oktapoc:/callback',
  discoveryUri: 'https://dev-123456.okta.com/oauth2/default',
  scopes: ['openid', 'profile', 'email', 'offline_access'],
  requireHardwareBackedKeyStore: false,
};
```

### 4. Update iOS URL Scheme

Edit `ios/OktaPOC/Info.plist` and replace `{{APP_SCHEME}}`:

```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>com.mycompany.oktapoc</string>
</array>
```

**Important**: The URL scheme must match the first part of your redirect URI.
- Redirect URI: `com.mycompany.oktapoc:/callback`
- URL Scheme: `com.mycompany.oktapoc`

## Running the App

### Option 1: iOS Simulator

```bash
# Start Metro bundler
npm start

# In a new terminal, run on iOS
npm run ios
```

Or run directly with device selection:
```bash
npx react-native run-ios --simulator="iPhone 15 Pro"
```

### Option 2: Real iPhone Device

1. **Open Xcode**:
   ```bash
   open ios/OktaPOC.xcworkspace
   ```

2. **Configure Signing**:
   - Select the `OktaPOC` project in the navigator
   - Select the `OktaPOC` target
   - Go to "Signing & Capabilities"
   - Select your Team
   - Xcode will automatically generate a provisioning profile

3. **Connect Your iPhone**:
   - Connect your iPhone via USB
   - Trust the computer on your iPhone if prompted
   - Select your device from the device dropdown in Xcode

4. **Run the App**:
   - Click the Play button in Xcode, or
   - Run: `npx react-native run-ios --device`

5. **Trust Developer Certificate** (First time only):
   - On your iPhone: Settings → General → VPN & Device Management
   - Tap your developer certificate
   - Tap "Trust"

## Testing

### Test the Complete Flow

1. **Launch the App**
   - You should see the Login screen with an "Login with Okta" button

2. **Click "Login with Okta"**
   - Safari will open with your Okta login page
   - The URL will be: `https://{{OKTA_DOMAIN}}/oauth2/default/v1/authorize?...`

3. **Enter Credentials**
   - Username: Your Okta username
   - Password: Your Okta password

4. **Authenticate**
   - Complete any MFA if configured
   - Okta will redirect back to your app

5. **View Home Screen**
   - You should see the Home screen with:
     - Welcome message
     - User profile information (name, email)
     - ID token claims
     - Access token (truncated)

6. **Test Logout**
   - Tap the "Logout" button
   - Confirm logout in the alert
   - Safari will open briefly to clear the Okta session
   - You'll be redirected back to the Login screen

### Expected Behavior

**On Simulator:**
- Safari opens in a new window/tab
- Redirects back to the app automatically
- Smooth transition between screens

**On Real Device:**
- Safari app opens
- After authentication, user taps "Open in OktaPOC" or similar
- App opens and shows Home screen

### What to Test

- ✅ Login flow completes successfully
- ✅ User data is displayed correctly
- ✅ Access token is retrieved
- ✅ Logout clears the session
- ✅ Cannot navigate back to Home after logout
- ✅ Redirect URIs work correctly

## Configuration

### Redirect URI Structure

The redirect URI must follow this pattern:

```
{{APP_SCHEME}}:/callback
```

**Examples:**
- `com.mycompany.app:/callback`
- `com.acme.oktapoc:/callback`
- `myapp:/callback`

**Important Rules:**
1. The scheme must be unique to your app
2. Use reverse domain notation (recommended): `com.yourcompany.appname`
3. Must match exactly in:
   - Okta application settings (Login redirect URIs)
   - Okta application settings (Logout redirect URIs)
   - `okta.config.js` (`redirectUri` and `endSessionRedirectUri`)
   - `Info.plist` (`CFBundleURLSchemes`)

### Okta Configuration Details

| Setting | Value |
|---------|-------|
| **Application Type** | Native Application |
| **Grant Types** | Authorization Code, Refresh Token |
| **PKCE** | Required |
| **Login Redirect URIs** | `{{IOS_REDIRECT_URI}}` |
| **Logout Redirect URIs** | `{{IOS_REDIRECT_URI}}` |
| **Scopes** | openid, profile, email, offline_access |

### Info.plist Configuration

The `Info.plist` file must include:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>com.oktapoc</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>{{APP_SCHEME}}</string>
    </array>
  </dict>
</array>
```

## Project Structure

```
okta-native-poc/
├── App.js                      # Main app component with Okta initialization
├── index.js                    # App entry point
├── app.json                    # App configuration
├── okta.config.js             # Okta configuration (UPDATE THIS)
├── package.json               # Dependencies
├── babel.config.js            # Babel configuration
├── metro.config.js            # Metro bundler configuration
├── src/
│   ├── navigation/
│   │   └── AppNavigator.js    # React Navigation setup
│   └── screens/
│       ├── LoginScreen.js     # Login screen with Okta integration
│       └── HomeScreen.js      # Home screen with user profile
├── ios/
│   ├── Podfile                # CocoaPods dependencies
│   ├── OktaPOC/
│   │   └── Info.plist         # iOS configuration (UPDATE THIS)
│   └── OktaPOC.xcworkspace    # Xcode workspace (use this, not .xcodeproj)
└── README.md                  # This file
```

## How It Works

### Authentication Flow

```
1. User taps "Login with Okta"
   ↓
2. App generates PKCE code verifier & challenge
   ↓
3. App opens Safari with Okta authorization URL
   ↓
4. User authenticates in Safari (username/password/MFA)
   ↓
5. Okta redirects to: {{IOS_REDIRECT_URI}}?code=xxx&state=yyy
   ↓
6. iOS recognizes the URL scheme and opens the app
   ↓
7. Okta SDK intercepts the redirect automatically
   ↓
8. SDK exchanges authorization code + code verifier for tokens
   ↓
9. Tokens are stored securely in iOS Keychain
   ↓
10. App navigates to Home screen
```

### Token Storage

- **Where**: iOS Keychain (secure, encrypted storage)
- **What**: Access token, ID token, Refresh token
- **Security**: Hardware-backed encryption on supported devices
- **Lifecycle**: Automatic token refresh when expired

### Why Not Embedded Sign-In Widget?

The Okta Sign-In Widget is a web-based component that **cannot be embedded** in React Native apps because:
1. It requires a full browser environment with JavaScript execution
2. React Native WebView has limitations and security concerns
3. Native OAuth flow is more secure and provides better UX

Instead, we use the **secure browser-based flow** which:
- ✅ Uses the device's system browser (Safari)
- ✅ Leverages iOS's secure app-to-browser communication
- ✅ Follows OAuth 2.0 best practices for native apps
- ✅ Provides better security than WebView-based solutions

## Troubleshooting

### Common Issues

#### 1. "No bundle URL present"

**Solution**: Make sure Metro bundler is running
```bash
npm start
```

#### 2. "Failed to initialize Okta SDK"

**Causes**:
- Incorrect configuration in `okta.config.js`
- Invalid Client ID or Okta Domain

**Solution**: Double-check your Okta configuration

#### 3. "Redirect URI mismatch"

**Causes**:
- Redirect URI in `okta.config.js` doesn't match Okta app settings
- URL scheme in `Info.plist` doesn't match redirect URI

**Solution**: Ensure consistency across:
- Okta app settings → Login redirect URIs
- Okta app settings → Logout redirect URIs
- `okta.config.js` → `redirectUri`
- `okta.config.js` → `endSessionRedirectUri`
- `Info.plist` → `CFBundleURLSchemes`

#### 4. "Pod install fails"

**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

#### 5. "App doesn't open after Okta redirect"

**Causes**:
- URL scheme not configured in `Info.plist`
- URL scheme doesn't match redirect URI

**Solution**: Verify `Info.plist` has the correct `CFBundleURLSchemes`

#### 6. "Could not connect to development server"

**Solution**:
```bash
# Reset Metro cache
npm start -- --reset-cache
```

#### 7. "Command PhaseScriptExecution failed"

**Solution**:
```bash
# Clean build
cd ios
xcodebuild clean
cd ..
```

### Debug Mode

To see detailed Okta SDK logs:

1. Open Xcode: `open ios/OktaPOC.xcworkspace`
2. Run the app from Xcode
3. Check the console output for detailed logs

### Testing Tips

1. **Use Okta Developer Account**: Free and no credit card required
2. **Test on Simulator First**: Easier debugging
3. **Check Console Logs**: `console.log` statements in the code show the flow
4. **Test Logout**: Ensure session is cleared completely
5. **Test Token Refresh**: Leave app running for token expiration

## Security Considerations

1. **PKCE**: Always enabled for native apps (prevents authorization code interception)
2. **Secure Storage**: Tokens stored in iOS Keychain (hardware-encrypted)
3. **No Client Secret**: Native apps don't use client secrets (can't be secured)
4. **Browser-Based Auth**: More secure than WebView (separate process, no JS injection)
5. **Token Refresh**: Automatic refresh using refresh tokens
6. **Logout**: Clears both app tokens and Okta session

## Additional Resources

- [Okta React Native SDK Documentation](https://github.com/okta/okta-react-native)
- [Okta Developer Documentation](https://developer.okta.com/docs/)
- [OAuth 2.0 for Native Apps (RFC 8252)](https://tools.ietf.org/html/rfc8252)
- [PKCE (RFC 7636)](https://tools.ietf.org/html/rfc7636)
- [React Native Documentation](https://reactnative.dev/)

## Next Steps

After getting the POC running, consider:

1. **Add Token Refresh Handling**: Implement automatic token refresh before expiration
2. **Implement Protected Routes**: Add authentication checks to routes
3. **Add Deep Linking**: Handle deep links that require authentication
4. **Error Boundaries**: Add React error boundaries for better error handling
5. **Loading States**: Improve loading states and transitions
6. **Biometric Authentication**: Add Face ID/Touch ID for app access
7. **Offline Support**: Handle offline scenarios gracefully
8. **Production Hardening**: Add proper error tracking and analytics

## License

This is a proof-of-concept for educational and evaluation purposes.
