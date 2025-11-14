# Quick Start Guide

Get up and running with the Okta React Native iOS POC in 15 minutes.

## Prerequisites

- macOS with Xcode installed
- Node.js 18+
- CocoaPods installed
- Okta Developer account

## 1. Install Dependencies (2 minutes)

```bash
# Install npm dependencies
npm install

# Install iOS dependencies
cd ios && pod install && cd ..
```

## 2. Configure Okta (5 minutes)

### Create Okta Application

1. Go to [Okta Developer Console](https://developer.okta.com/)
2. Sign in or create account
3. Click **Applications** → **Create App Integration**
4. Select **OIDC** → **Native Application**
5. Configure:
   - Name: `React Native POC`
   - Sign-in redirect URI: `com.mycompany.oktapoc:/callback`
   - Sign-out redirect URI: `com.mycompany.oktapoc:/callback`
6. Click **Save**
7. Note your **Client ID** and **Okta Domain**

## 3. Update Configuration (3 minutes)

### Edit `okta.config.js`

Replace placeholders with your values:

```javascript
export default {
  issuer: 'https://dev-123456.okta.com/oauth2/default',  // Your Okta domain
  clientId: '0oa5abc123xyz789',                          // Your Client ID
  redirectUri: 'com.mycompany.oktapoc:/callback',        // Your redirect URI
  endSessionRedirectUri: 'com.mycompany.oktapoc:/callback',
  discoveryUri: 'https://dev-123456.okta.com/oauth2/default',
  scopes: ['openid', 'profile', 'email', 'offline_access'],
  requireHardwareBackedKeyStore: false,
};
```

### Edit `ios/OktaPOC/Info.plist`

Find `{{APP_SCHEME}}` and replace with your scheme:

```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>com.mycompany.oktapoc</string>  <!-- Match your redirect URI scheme -->
</array>
```

## 4. Run the App (2 minutes)

### On iOS Simulator

```bash
# Terminal 1: Start Metro
npm start

# Terminal 2: Run app
npm run ios
```

### On Physical iPhone

1. Open Xcode:
   ```bash
   open ios/OktaPOC.xcworkspace
   ```

2. Select your device from the dropdown

3. Click Run (▶️) button

4. Trust developer certificate on device:
   - Settings → General → VPN & Device Management
   - Trust your certificate

## 5. Test Authentication (3 minutes)

1. **Launch app** - See login screen

2. **Tap "Login with Okta"** - Safari opens

3. **Enter credentials** - Sign in to Okta

4. **Complete authentication** - Redirected back to app

5. **View profile** - See user information

6. **Test logout** - Tap logout button

## Expected Flow

```
App Launch
    ↓
Login Screen
    ↓
[Tap "Login with Okta"]
    ↓
Safari Opens → Okta Login Page
    ↓
[Enter credentials]
    ↓
Safari → Redirect to app
    ↓
Home Screen (with user data)
    ↓
[Tap "Logout"]
    ↓
Login Screen
```

## Verification Checklist

- [ ] App launches without errors
- [ ] "Login with Okta" button appears
- [ ] Tapping button opens Safari
- [ ] Okta login page loads
- [ ] After login, app opens automatically
- [ ] Home screen shows user information
- [ ] Access token is displayed (truncated)
- [ ] Logout works and returns to login screen

## Common Issues

### App doesn't open after Okta redirect

**Fix**: Check URL scheme in `Info.plist` matches redirect URI

### "Failed to initialize Okta SDK"

**Fix**: Verify `okta.config.js` has correct values (no `https://` in domain)

### "Invalid redirect URI"

**Fix**: Ensure redirect URI in Okta app matches `okta.config.js`

### "No bundle URL present"

**Fix**: Make sure Metro bundler is running (`npm start`)

## Next Steps

- Read [README.md](./README.md) for detailed documentation
- See [OKTA_SETUP.md](./OKTA_SETUP.md) for advanced Okta configuration
- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) if you encounter issues

## Need Help?

- **Okta Docs**: https://developer.okta.com/docs/
- **React Native Docs**: https://reactnative.dev/
- **GitHub Issues**: https://github.com/okta/okta-react-native/issues
