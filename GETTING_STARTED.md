# Getting Started with Okta React Native iOS POC

Welcome! This guide will help you get the Okta React Native iOS POC up and running on your Mac.

## What You'll Build

A fully functional React Native iOS app with Okta authentication featuring:
- ✅ Secure OAuth 2.0 + PKCE login flow
- ✅ Browser-based authentication (Safari)
- ✅ Secure token storage in iOS Keychain
- ✅ User profile display
- ✅ Complete logout flow

## Before You Start

### Required Software

Ensure you have these installed:

1. **macOS**: Catalina (10.15) or later
2. **Xcode**: Version 14 or later
   - Install from Mac App Store
   - Install Command Line Tools: `xcode-select --install`
3. **Node.js**: Version 18 or later
   - Check: `node --version`
   - Install: https://nodejs.org/
4. **CocoaPods**: Latest version
   - Check: `pod --version`
   - Install: `sudo gem install cocoapods`
5. **Watchman** (recommended):
   - Install: `brew install watchman`

### Okta Account

You'll need an Okta Developer account:
- Sign up for free: https://developer.okta.com/signup/
- No credit card required
- Instant activation

## Step-by-Step Setup

### Step 1: Install Project Dependencies

```bash
# Navigate to project directory
cd okta-native-poc

# Install JavaScript dependencies
npm install

# Install iOS native dependencies
cd ios
pod install
cd ..
```

**Expected Output**:
- npm: `added XXX packages`
- pod: `Pod installation complete!`

**Troubleshooting**:
- If npm fails: Try `npm cache clean --force` then `npm install`
- If pod fails: Try `pod repo update` then `pod install`

### Step 2: Configure Okta

#### 2a. Create Okta Application

1. **Log in to Okta**:
   - Go to https://developer.okta.com/
   - Click "Sign In" or create account

2. **Create Application**:
   - Click **Applications** → **Applications** in sidebar
   - Click **Create App Integration**
   - Select **OIDC - OpenID Connect**
   - Select **Native Application**
   - Click **Next**

3. **Configure Application**:
   - **App integration name**: `React Native iOS POC`
   - **Sign-in redirect URIs**: Add `com.mycompany.oktapoc:/callback`
   - **Sign-out redirect URIs**: Add `com.mycompany.oktapoc:/callback`
   - Click **Save**

4. **Configure Grant Types**:
   - Click **Edit** in General Settings
   - Under **Grant type**, ensure these are checked:
     - ✅ Authorization Code
     - ✅ Refresh Token
   - Click **Save**

5. **Note Your Configuration**:
   - **Client ID**: Copy from General tab (e.g., `0oa5abc123xyz789`)
   - **Okta Domain**: From top-right corner (e.g., `dev-123456.okta.com`)

#### 2b. Update App Configuration

**Edit `okta.config.js`**:

Replace these lines:
```javascript
issuer: 'https://{{OKTA_DOMAIN}}/oauth2/default',
clientId: '{{OKTA_CLIENT_ID}}',
redirectUri: '{{IOS_REDIRECT_URI}}',
endSessionRedirectUri: '{{IOS_REDIRECT_URI}}',
discoveryUri: 'https://{{OKTA_DOMAIN}}/oauth2/default',
```

With your actual values:
```javascript
issuer: 'https://dev-123456.okta.com/oauth2/default',
clientId: '0oa5abc123xyz789',
redirectUri: 'com.mycompany.oktapoc:/callback',
endSessionRedirectUri: 'com.mycompany.oktapoc:/callback',
discoveryUri: 'https://dev-123456.okta.com/oauth2/default',
```

**Edit `ios/OktaPOC/Info.plist`**:

Find this section:
```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>{{APP_SCHEME}}</string>
</array>
```

Replace with your scheme (the part before `:/`):
```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>com.mycompany.oktapoc</string>
</array>
```

### Step 3: Run the App

#### Option A: iOS Simulator (Easiest)

```bash
# Terminal 1: Start Metro bundler
npm start

# Terminal 2: Run on simulator
npm run ios
```

The iOS Simulator will launch automatically and install the app.

#### Option B: Physical iPhone

1. **Open Xcode Workspace**:
   ```bash
   open ios/OktaPOC.xcworkspace
   ```
   ⚠️ **Important**: Open `.xcworkspace`, NOT `.xcodeproj`

2. **Configure Signing**:
   - Select `OktaPOC` project in navigator (left sidebar)
   - Select `OktaPOC` target
   - Go to "Signing & Capabilities" tab
   - Under "Signing", select your Team
   - Check "Automatically manage signing"

3. **Connect iPhone**:
   - Connect via USB
   - Unlock your iPhone
   - Trust the computer if prompted

4. **Select Device**:
   - In Xcode, select your iPhone from device dropdown (top-left)

5. **Run**:
   - Click Run button (▶️) or press Cmd+R
   - Wait for build to complete
   - App will install on your iPhone

6. **Trust Developer** (First time only):
   - On iPhone: Settings → General → VPN & Device Management
   - Find your developer certificate
   - Tap "Trust"
   - Return to app

### Step 4: Test the App

#### First Launch

1. **App Opens** → You should see Login screen
2. **Tap "Login with Okta"** → Safari opens
3. **Okta Login Page** → Enter your credentials
4. **Authenticate** → Complete MFA if enabled
5. **Redirect** → Safari redirects back to app
6. **Home Screen** → See your profile information

#### What to Verify

- ✅ Login button works
- ✅ Safari opens with Okta login
- ✅ Can authenticate successfully
- ✅ App opens after authentication
- ✅ Home screen shows user information
- ✅ Access token is displayed
- ✅ Logout button works
- ✅ Returns to login screen after logout

#### Expected Behavior

**On Simulator**:
- Safari opens in separate window/tab
- Automatically redirects back to app
- Smooth transition

**On iPhone**:
- Safari app opens
- After login, tap "Open in OktaPOC" or similar
- App opens and shows home screen

### Step 5: Understanding the Flow

```
┌──────────────────┐
│   Login Screen   │
│  [Login Button]  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Safari Opens    │
│  Okta Login Page │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Enter Credentials│
│   (Username +    │
│    Password)     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Safari Redirects │
│   Back to App    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Home Screen    │
│  User Profile +  │
│     Tokens       │
└──────────────────┘
```

## Next Steps

### Learn More

- **README.md**: Complete documentation
- **OKTA_SETUP.md**: Detailed Okta configuration
- **TROUBLESHOOTING.md**: Common issues and solutions
- **PROJECT_OVERVIEW.md**: Technical architecture

### Customize the App

1. **Change App Scheme**:
   - Update redirect URI in Okta
   - Update `okta.config.js`
   - Update `Info.plist`

2. **Add More Screens**:
   - Create new components in `src/screens/`
   - Add routes to `src/navigation/AppNavigator.js`

3. **Call Protected APIs**:
   ```javascript
   const {access_token} = await getAccessToken();
   const response = await fetch('https://api.example.com/protected', {
     headers: {
       'Authorization': `Bearer ${access_token}`
     }
   });
   ```

## Troubleshooting Quick Fixes

### "No bundle URL present"
```bash
npm start
```

### "Failed to initialize Okta SDK"
- Check `okta.config.js` has correct values
- Ensure Okta Domain doesn't include `https://`

### "Invalid redirect URI"
- Verify redirect URI in Okta app matches `okta.config.js`
- Check for typos and exact match (case-sensitive)

### App doesn't open after redirect
- Verify URL scheme in `Info.plist` matches redirect URI
- Rebuild app after changing Info.plist

### Pod install fails
```bash
cd ios
pod repo update
pod install
cd ..
```

### Build fails in Xcode
```bash
# Clean build
cd ios
xcodebuild clean
cd ..
npm run ios
```

## Getting Help

### Documentation
- **Main README**: [README.md](./README.md)
- **Okta Setup**: [OKTA_SETUP.md](./OKTA_SETUP.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **Quick Start**: [QUICKSTART.md](./QUICKSTART.md)

### Support Resources
- Okta Developer Docs: https://developer.okta.com/docs/
- React Native Docs: https://reactnative.dev/
- Okta Community: https://devforum.okta.com/
- Stack Overflow: Tag with `okta` + `react-native`

### Checking Logs

**Metro Bundler**: Shows console.log output and errors

**Xcode Console**: Shows native iOS logs and errors

**React Native Debugger**: Shows network requests and state

## Success! What You've Accomplished

✅ Set up a complete React Native development environment
✅ Configured Okta for mobile authentication
✅ Implemented OAuth 2.0 + PKCE flow
✅ Integrated secure browser-based login
✅ Stored tokens securely in iOS Keychain
✅ Built a working authentication flow

You now have a solid foundation for building production React Native apps with Okta authentication!

## What's Next?

Consider these enhancements:
- Add biometric authentication (Face ID / Touch ID)
- Implement protected API calls
- Add deep linking
- Implement token refresh handling
- Add error tracking (Sentry)
- Add analytics
- Build for production
- Deploy to TestFlight

Happy coding! 🚀
