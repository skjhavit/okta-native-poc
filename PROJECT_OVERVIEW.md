# Project Overview

This document provides a technical overview of the Okta React Native iOS POC architecture, implementation details, and design decisions.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        React Native App                      │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────┐ │
│  │ LoginScreen   │  │  HomeScreen   │  │  Navigation     │ │
│  │               │  │               │  │  (React Nav)    │ │
│  └───────┬───────┘  └───────┬───────┘  └────────┬────────┘ │
│          │                  │                     │          │
│          └──────────────────┴─────────────────────┘          │
│                             │                                │
│                  ┌──────────▼──────────┐                     │
│                  │   Okta React Native │                     │
│                  │        SDK          │                     │
│                  └──────────┬──────────┘                     │
└─────────────────────────────┼────────────────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   iOS Keychain    │  (Secure Token Storage)
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │    Safari View    │  (OAuth Browser)
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Okta Service    │  (Authentication)
                    └───────────────────┘
```

### Component Structure

```
App.js (Root)
  │
  ├─ Okta SDK Initialization
  ├─ Event Listeners (OAuth callbacks)
  │
  └─ AppNavigator (React Navigation)
      │
      ├─ LoginScreen
      │   ├─ Login Button
      │   └─ signIn() → Opens Safari
      │
      └─ HomeScreen
          ├─ User Profile Display
          ├─ Token Information
          └─ Logout Button → signOut()
```

## Key Components

### 1. App.js

**Purpose**: Application entry point and Okta SDK initialization

**Responsibilities**:
- Initialize Okta SDK with configuration
- Set up OAuth event listeners
- Render navigation container

**Key Code**:
```javascript
// Initialize Okta SDK
await createConfig({
  clientId: oktaConfig.clientId,
  redirectUri: oktaConfig.redirectUri,
  // ... other config
});

// Listen for OAuth events
EventEmitter.addListener('onSignInSuccess', handleSignInSuccess);
EventEmitter.addListener('onSignInFailure', handleSignInFailure);
```

### 2. LoginScreen

**Purpose**: Authentication initiation

**Flow**:
1. User taps "Login with Okta"
2. Component calls `signIn()`
3. Okta SDK generates PKCE challenge
4. Opens Safari with authorization URL
5. User authenticates
6. Safari redirects back to app
7. SDK handles token exchange
8. Navigate to HomeScreen

**Key Code**:
```javascript
await signIn(); // Opens Safari, handles PKCE, exchanges code for tokens
const user = await getUser(); // Get user profile
navigation.replace('Home', {user});
```

### 3. HomeScreen

**Purpose**: Display user information and handle logout

**Features**:
- Display user profile (name, email, etc.)
- Show ID token claims
- Display access token (truncated)
- Logout functionality

**Key Code**:
```javascript
const authenticated = await isAuthenticated(); // Check auth status
const {access_token} = await getAccessToken(); // Get token
const user = await getUser(); // Get profile
await signOut(); // Logout
```

### 4. AppNavigator

**Purpose**: Navigation management

**Stack**:
- LoginScreen (initial)
- HomeScreen (protected)

**Configuration**:
- No header (custom UI)
- No swipe back on HomeScreen (prevent unauthorized access)
- Fade animation between screens

## OAuth 2.0 + PKCE Flow

### Detailed Authentication Flow

```
1. User Initiates Login
   ├─ Tap "Login with Okta" button
   └─ LoginScreen calls signIn()

2. PKCE Challenge Generation
   ├─ SDK generates random code_verifier (43-128 chars)
   ├─ Creates code_challenge = BASE64URL(SHA256(code_verifier))
   └─ Stores code_verifier securely

3. Authorization Request
   ├─ Build authorization URL:
   │  https://{{OKTA_DOMAIN}}/oauth2/default/v1/authorize?
   │    client_id={{OKTA_CLIENT_ID}}
   │    &redirect_uri={{IOS_REDIRECT_URI}}
   │    &response_type=code
   │    &scope=openid%20profile%20email
   │    &state=random_state_value
   │    &code_challenge=base64_challenge
   │    &code_challenge_method=S256
   └─ Open in Safari

4. User Authentication
   ├─ Safari loads Okta login page
   ├─ User enters credentials
   ├─ Optional: MFA
   └─ Okta validates credentials

5. Authorization Code Redirect
   ├─ Okta redirects to: {{IOS_REDIRECT_URI}}?code=xxx&state=yyy
   ├─ iOS recognizes custom URL scheme
   ├─ Opens app with deep link
   └─ SDK intercepts the redirect

6. Token Exchange
   ├─ SDK validates state parameter
   ├─ POST to /token endpoint:
   │  {
   │    grant_type: "authorization_code",
   │    code: "authorization_code_from_step_5",
   │    redirect_uri: "{{IOS_REDIRECT_URI}}",
   │    code_verifier: "original_code_verifier",
   │    client_id: "{{OKTA_CLIENT_ID}}"
   │  }
   ├─ Okta validates:
   │  - code_verifier matches code_challenge
   │  - authorization code is valid
   │  - redirect_uri matches
   └─ Returns tokens

7. Token Storage
   ├─ SDK receives tokens:
   │  - access_token
   │  - id_token
   │  - refresh_token (if offline_access scope)
   ├─ Stores in iOS Keychain (encrypted)
   └─ Triggers onSignInSuccess event

8. Navigate to Home
   ├─ Get user profile
   └─ Navigate to HomeScreen
```

### Why PKCE?

PKCE (Proof Key for Code Exchange) prevents authorization code interception attacks:

**Without PKCE** (vulnerable):
```
1. Attacker intercepts authorization code from redirect
2. Attacker exchanges code for tokens
3. Attacker gains access to user account
```

**With PKCE** (secure):
```
1. Attacker intercepts authorization code
2. Attacker cannot exchange code (needs code_verifier)
3. Only the original app can exchange code
```

## Security Features

### 1. PKCE

- **Purpose**: Prevent authorization code interception
- **Implementation**: Automatic in Okta SDK
- **Algorithm**: SHA-256 hashing of random verifier

### 2. iOS Keychain

- **Purpose**: Secure token storage
- **Features**:
  - Hardware-encrypted (on supported devices)
  - OS-managed access control
  - Survives app reinstalls (optional)
- **What's Stored**:
  - Access token
  - ID token
  - Refresh token

### 3. Browser-Based Authentication

- **Why Not WebView**:
  - WebViews can be compromised
  - No shared SSO state
  - Against OAuth 2.0 best practices

- **Why Safari**:
  - Separate process (isolated)
  - Shared SSO cookies
  - Follows OAuth 2.0 for native apps (RFC 8252)

### 4. No Client Secret

- **Reason**: Native apps can't securely store secrets
- **Solution**: PKCE provides security without client secret
- **Configuration**: Native app type in Okta doesn't use client secret

### 5. State Parameter

- **Purpose**: CSRF protection
- **Implementation**: Random value generated per request
- **Validation**: SDK verifies state on redirect

## Token Management

### Token Types

#### 1. Access Token
- **Purpose**: Access protected resources
- **Format**: JWT
- **Lifetime**: 1 hour (default)
- **Storage**: iOS Keychain
- **Usage**: API requests to resource servers

#### 2. ID Token
- **Purpose**: User identity information
- **Format**: JWT
- **Contains**: User claims (name, email, sub, etc.)
- **Storage**: iOS Keychain
- **Usage**: Display user information

#### 3. Refresh Token
- **Purpose**: Obtain new access tokens
- **Lifetime**: Longer (days/weeks)
- **Storage**: iOS Keychain
- **Usage**: Automatic token refresh

### Token Lifecycle

```
Access Token Received (1 hour lifetime)
        │
        ├─ Used for API calls
        ├─ Stored in Keychain
        │
        ▼
   Approaches Expiry (< 5 min)
        │
        ├─ SDK detects expiration
        │
        ▼
  Automatic Refresh
        │
        ├─ Uses refresh_token
        ├─ Calls /token endpoint
        │
        ▼
   New Access Token
        │
        └─ Cycle repeats
```

### Token Refresh

**Automatic** (recommended):
```javascript
// SDK automatically refreshes when calling getAccessToken()
const {access_token} = await getAccessToken();
// If expired, SDK uses refresh token automatically
```

**Manual** (if needed):
```javascript
import {refreshTokens} from '@okta/okta-react-native';
await refreshTokens();
```

## Configuration Files

### 1. okta.config.js

**Purpose**: Centralized Okta configuration

**Required Values**:
- `issuer`: Authorization server URL
- `clientId`: Okta application client ID
- `redirectUri`: iOS app callback URL
- `scopes`: OAuth scopes

### 2. Info.plist

**Purpose**: iOS app configuration

**Critical Settings**:
- `CFBundleURLSchemes`: URL scheme for OAuth redirects
- Must match redirect URI scheme

### 3. Podfile

**Purpose**: iOS native dependencies

**Key Dependency**:
- `OktaOidc`: Native iOS SDK for Okta

## File Structure Explained

```
okta-native-poc/
│
├── App.js                    # App entry point, SDK initialization
├── index.js                  # React Native registration
├── okta.config.js           # Okta configuration (EDIT THIS)
│
├── src/
│   ├── navigation/
│   │   └── AppNavigator.js  # React Navigation setup
│   │
│   └── screens/
│       ├── LoginScreen.js   # Login UI + signIn()
│       └── HomeScreen.js    # Profile UI + signOut()
│
├── ios/
│   ├── Podfile              # CocoaPods dependencies
│   ├── OktaPOC/
│   │   └── Info.plist       # iOS config (EDIT URL SCHEME)
│   └── OktaPOC.xcworkspace  # Xcode workspace (open this)
│
├── package.json             # npm dependencies
├── metro.config.js          # Metro bundler config
├── babel.config.js          # Babel transpiler config
│
└── Documentation/
    ├── README.md            # Main documentation
    ├── OKTA_SETUP.md        # Okta configuration guide
    ├── QUICKSTART.md        # Quick start guide
    ├── TROUBLESHOOTING.md   # Common issues
    └── PROJECT_OVERVIEW.md  # This file
```

## Dependencies

### npm Dependencies

```json
{
  "react": "18.2.0",                           // React library
  "react-native": "0.73.6",                    // React Native framework
  "@okta/okta-react-native": "^2.10.0",       // Okta SDK
  "@react-navigation/native": "^6.1.9",        // Navigation library
  "@react-navigation/native-stack": "^6.9.17", // Stack navigator
  "react-native-safe-area-context": "^4.8.2",  // Safe area handling
  "react-native-screens": "^3.29.0"            // Native screens
}
```

### iOS Dependencies (CocoaPods)

```ruby
pod 'OktaOidc', '~> 3.11.0'  # Okta native iOS SDK
```

## Design Decisions

### 1. Why React Navigation?

- ✅ Most popular React Native navigation library
- ✅ Native performance
- ✅ Good TypeScript support
- ✅ Active maintenance

### 2. Why Not TypeScript?

- For POC simplicity
- Easier for developers new to React Native
- Can be migrated later if needed

### 3. Why Functional Components?

- Modern React best practice
- Hooks provide cleaner state management
- Better performance
- Easier to test

### 4. Why No Redux/MobX?

- Authentication state managed by Okta SDK
- Small app doesn't need state management
- Can be added later if needed

### 5. Why No React Context?

- Okta SDK provides its own state
- Navigation handles screen state
- Minimal shared state needed

## Error Handling

### Error Handling Strategy

```javascript
try {
  await signIn();
} catch (error) {
  // Check error code
  if (error.code === 'E_OAUTH_FAILED') {
    // OAuth configuration error
  } else if (error.code === 'user_cancelled_login') {
    // User cancelled (silent)
  } else {
    // Unexpected error
  }
}
```

### Common Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| `E_OAUTH_FAILED` | OAuth configuration error | Check config |
| `E_SIGN_IN_FAILED` | Sign-in failed | Retry |
| `user_cancelled_login` | User cancelled | Silent (no alert) |
| `E_GET_USER_FAILED` | Failed to get user | Check scopes |
| `E_GET_TOKEN_FAILED` | Failed to get token | Re-authenticate |

## Testing Strategy

### Unit Testing (Not Implemented)

Potential tests:
- Configuration validation
- Error handling logic
- Component rendering

### Integration Testing (Manual)

Current testing approach:
1. Login flow
2. Token retrieval
3. User profile display
4. Logout flow
5. Redirect handling

### E2E Testing (Not Implemented)

Could use:
- Detox (React Native E2E framework)
- Appium (Cross-platform)

## Performance Considerations

### 1. Token Caching

- Tokens stored in Keychain (not re-fetched every time)
- SDK caches tokens in memory

### 2. Lazy Loading

- Screens only loaded when navigated to
- React Navigation handles this automatically

### 3. Image Optimization

- No images in this POC
- For production: Use optimized images, lazy loading

### 4. Bundle Size

- Current: ~2-3 MB
- Okta SDK: ~500 KB
- React Navigation: ~200 KB

## Production Readiness Checklist

To make this production-ready:

- [ ] Add error tracking (Sentry, Crashlytics)
- [ ] Implement analytics
- [ ] Add loading states and skeletons
- [ ] Implement token refresh handling
- [ ] Add biometric authentication (Face ID/Touch ID)
- [ ] Implement deep linking
- [ ] Add offline support
- [ ] Implement retry logic for network failures
- [ ] Add proper logging
- [ ] Security hardening (jailbreak detection, SSL pinning)
- [ ] Add comprehensive error messages
- [ ] Implement protected routes
- [ ] Add session timeout
- [ ] Implement proper splash screen
- [ ] Add app icon and branding
- [ ] Setup CI/CD pipeline
- [ ] Add automated testing
- [ ] Implement feature flags
- [ ] Add proper environment management (dev/staging/prod)
- [ ] Security audit
- [ ] Performance optimization
- [ ] Accessibility improvements

## Extending This POC

### Add Protected API Calls

```javascript
import {getAccessToken} from '@okta/okta-react-native';

const callProtectedAPI = async () => {
  const {access_token} = await getAccessToken();

  const response = await fetch('https://api.example.com/protected', {
    headers: {
      'Authorization': `Bearer ${access_token}`,
    },
  });

  return response.json();
};
```

### Add Biometric Authentication

```javascript
import TouchID from 'react-native-touch-id';

const authenticateWithBiometrics = async () => {
  try {
    await TouchID.authenticate('Authenticate to access the app');
    // Proceed with Okta login
  } catch (error) {
    // Biometric auth failed
  }
};
```

### Add Deep Linking

```javascript
import {Linking} from 'react-native';

Linking.addEventListener('url', handleDeepLink);

const handleDeepLink = ({url}) => {
  // Parse URL and navigate accordingly
  if (url.includes('/profile')) {
    navigation.navigate('Profile');
  }
};
```

## Resources

- [Okta React Native SDK](https://github.com/okta/okta-react-native)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)
- [OAuth for Native Apps RFC 8252](https://tools.ietf.org/html/rfc8252)
- [React Native Documentation](https://reactnative.dev/)
- [React Navigation](https://reactnavigation.org/)

## License

This POC is for educational and evaluation purposes.
