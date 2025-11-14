# Okta Application Setup Guide

This guide provides **exact step-by-step instructions** for configuring Okta for your React Native iOS application.

## Table of Contents

- [Overview](#overview)
- [Step 1: Create Okta Account](#step-1-create-okta-account)
- [Step 2: Create Native Application](#step-2-create-native-application)
- [Step 3: Configure Application Settings](#step-3-configure-application-settings)
- [Step 4: Configure Grant Types](#step-4-configure-grant-types)
- [Step 5: Configure Redirect URIs](#step-5-configure-redirect-uris)
- [Step 6: Gather Configuration Values](#step-6-gather-configuration-values)
- [Step 7: Configure Trusted Origins (Optional)](#step-7-configure-trusted-origins-optional)
- [Configuration Summary](#configuration-summary)
- [Verification Checklist](#verification-checklist)

## Overview

For React Native iOS apps, you must create a **Native Application** in Okta with:
- **PKCE enabled** (Proof Key for Code Exchange)
- **Authorization Code** grant type
- **Refresh Token** grant type (for offline access)
- Proper **redirect URIs** for iOS app scheme

## Step 1: Create Okta Account

If you don't have an Okta account:

1. Go to [https://developer.okta.com/signup/](https://developer.okta.com/signup/)
2. Click "Sign Up"
3. Fill in your information:
   - Email
   - First Name
   - Last Name
   - Country
4. Click "Get started"
5. Check your email and verify your account
6. Set your password
7. You'll be redirected to your Okta Admin Dashboard

**Note your Okta Domain**: It will look like `dev-123456.okta.com` or `dev-123456.oktapreview.com`

## Step 2: Create Native Application

1. **Log in to Okta Admin Dashboard**:
   - URL: `https://{{OKTA_DOMAIN}}-admin.okta.com` (or click the Admin button)

2. **Navigate to Applications**:
   - In the left sidebar, click **Applications** → **Applications**

3. **Create New Application**:
   - Click **Create App Integration** button

4. **Select Sign-in Method**:
   - Choose: **OIDC - OpenID Connect**
   - Click **Next**

5. **Select Application Type**:
   - Choose: **Native Application**
   - Click **Next**

**Why Native Application?**
- ✅ Designed for mobile/desktop apps
- ✅ Supports PKCE (required for security)
- ✅ Does not require client secret
- ✅ Uses system browser for authentication

## Step 3: Configure Application Settings

On the "New Native App Integration" page:

### General Settings

1. **App integration name**: Enter a name
   - Example: `React Native iOS POC`
   - This is just for your reference in Okta

2. **Logo** (Optional): Upload a logo if desired

### Sign-in redirect URIs

This is **critical** for the OAuth flow to work.

1. Click **+ Add URI** in the "Sign-in redirect URIs" section

2. Enter your iOS redirect URI:
   ```
   {{IOS_REDIRECT_URI}}
   ```

   **Example**: `com.mycompany.oktapoc:/callback`

   **Format Rules**:
   - Must use a custom URL scheme (e.g., `com.mycompany.app`)
   - Use reverse domain notation (recommended)
   - Must end with `:/callback` or another path
   - Must be **lowercase** (iOS URL schemes are case-insensitive but use lowercase)
   - Cannot be `http://` or `https://` (must be a custom scheme)

3. **Important**: You can add multiple redirect URIs for different environments:
   ```
   com.mycompany.oktapoc:/callback
   com.mycompany.oktapoc.dev:/callback
   com.mycompany.oktapoc.staging:/callback
   ```

### Sign-out redirect URIs

1. Click **+ Add URI** in the "Sign-out redirect URIs" section

2. Enter the **same URI** as the sign-in redirect URI:
   ```
   {{IOS_REDIRECT_URI}}
   ```

   **Example**: `com.mycompany.oktapoc:/callback`

3. **Important**: The logout redirect URI should match the login redirect URI

### Controlled access

Choose who can use this application:

- **Skip group assignment for now** (default)
- Or select specific groups if you want to limit access

## Step 4: Configure Grant Types

After creating the app, you need to configure grant types:

1. **Save the application** (click "Save" at the bottom)

2. **Navigate to the General tab** (if not already there)

3. Scroll to **General Settings** → Click **Edit**

4. Under **Grant type**, ensure these are checked:
   - ✅ **Authorization Code** (required)
   - ✅ **Refresh Token** (recommended for offline access)
   - ❌ **Implicit (Hybrid)** - Not needed for native apps
   - ❌ **Client Credentials** - Not applicable for native apps

5. **Refresh Token Behavior**:
   - Choose: **Rotate token after every use** (more secure)
   - Or: **Use persistent token** (simpler but less secure)

6. **Click "Save"**

## Step 5: Configure Redirect URIs

Verify your redirect URIs are correct:

### Login Redirect URIs

Format: `{{APP_SCHEME}}:/callback`

**Examples**:
```
com.mycompany.oktapoc:/callback
com.acme.myapp:/callback
mycompanyapp:/callback
```

### Logout Redirect URIs

Format: Same as login redirect URI

**Examples**:
```
com.mycompany.oktapoc:/callback
com.acme.myapp:/callback
mycompanyapp:/callback
```

### Mapping to App Scheme

The **{{APP_SCHEME}}** is the first part before `:/`

| Redirect URI | APP_SCHEME |
|-------------|------------|
| `com.mycompany.oktapoc:/callback` | `com.mycompany.oktapoc` |
| `com.acme.myapp:/callback` | `com.acme.myapp` |
| `myapp:/callback` | `myapp` |

You'll use **{{APP_SCHEME}}** in your iOS `Info.plist` configuration.

## Step 6: Gather Configuration Values

After creating the application, gather these values:

### 1. Client ID

- On the application's **General** tab
- Look for **Client ID**
- It looks like: `0oa5abc123xyz789def`
- Copy this value → You'll use it as **{{OKTA_CLIENT_ID}}**

### 2. Okta Domain

- Found in the top-right corner of the Admin Dashboard
- Or in the browser URL
- Format: `dev-123456.okta.com` or `dev-123456.oktapreview.com`
- **Do NOT include** `https://` or `-admin`
- Copy this value → You'll use it as **{{OKTA_DOMAIN}}**

### 3. Redirect URIs

- The redirect URIs you configured earlier
- Example: `com.mycompany.oktapoc:/callback`
- Copy this value → You'll use it as **{{IOS_REDIRECT_URI}}**

### 4. App Scheme

- The scheme part of your redirect URI (before `:/`)
- Example: `com.mycompany.oktapoc`
- Copy this value → You'll use it as **{{APP_SCHEME}}**

### Configuration Summary Table

| Placeholder | Example Value | Where to Find |
|------------|---------------|---------------|
| **{{OKTA_DOMAIN}}** | `dev-123456.okta.com` | Top-right corner of Admin Dashboard |
| **{{OKTA_CLIENT_ID}}** | `0oa5abc123xyz789def` | Application → General → Client ID |
| **{{IOS_REDIRECT_URI}}** | `com.mycompany.oktapoc:/callback` | Application → General → Sign-in redirect URIs |
| **{{APP_SCHEME}}** | `com.mycompany.oktapoc` | First part of redirect URI (before `:/`) |

## Step 7: Configure Trusted Origins (Optional)

This step is **optional** but recommended for production apps.

1. **Navigate to Security → API → Trusted Origins**

2. **Click "Add Origin"**

3. **Add your redirect URI scheme**:
   - Name: `iOS App`
   - Origin URL: `{{APP_SCHEME}}:/`
   - Example: `com.mycompany.oktapoc:/`
   - Type: Check both **CORS** and **Redirect**

4. **Click "Save"**

**Note**: This helps prevent CORS issues in some scenarios.

## Configuration Summary

After completing all steps, your Okta application should have:

### Application Type
- ✅ **Native Application**

### Grant Types
- ✅ **Authorization Code**
- ✅ **Refresh Token**

### Authentication Settings
- ✅ **PKCE**: Required (automatically enabled for Native Apps)
- ❌ **Client Secret**: Not used (native apps don't have secrets)

### Redirect URIs

**Sign-in redirect URIs**:
```
{{IOS_REDIRECT_URI}}
```
Example: `com.mycompany.oktapoc:/callback`

**Sign-out redirect URIs**:
```
{{IOS_REDIRECT_URI}}
```
Example: `com.mycompany.oktapoc:/callback`

### Scopes

The following scopes should be available (enabled by default):
- ✅ `openid` - Required for OIDC
- ✅ `profile` - User profile information
- ✅ `email` - User email address
- ✅ `offline_access` - Refresh token (if using refresh tokens)

## Verification Checklist

Before proceeding to the React Native app configuration, verify:

- [ ] Application type is **Native Application**
- [ ] Grant type **Authorization Code** is enabled
- [ ] Grant type **Refresh Token** is enabled (if you want offline access)
- [ ] **Sign-in redirect URI** is configured with your iOS app scheme
- [ ] **Sign-out redirect URI** is configured (same as sign-in)
- [ ] Redirect URI format is correct: `{{APP_SCHEME}}:/callback`
- [ ] You have copied **{{OKTA_DOMAIN}}** (without https://)
- [ ] You have copied **{{OKTA_CLIENT_ID}}**
- [ ] You have copied **{{IOS_REDIRECT_URI}}**
- [ ] You have extracted **{{APP_SCHEME}}** from the redirect URI

## Next Steps

Now that your Okta application is configured:

1. Update `okta.config.js` in your React Native project with the values
2. Update `ios/OktaPOC/Info.plist` with the **{{APP_SCHEME}}**
3. Run the app and test the authentication flow

See the main [README.md](./README.md) for complete setup instructions.

## Common Mistakes to Avoid

### ❌ Wrong Application Type
- **Don't** create a "Single-Page Application" or "Web Application"
- **Do** create a "Native Application"

### ❌ Incorrect Redirect URI Format
- **Don't** use: `http://localhost:8080/callback`
- **Don't** use: `https://myapp.com/callback`
- **Do** use: `com.mycompany.myapp:/callback`

### ❌ Mismatched Redirect URIs
- Ensure the redirect URI in Okta **exactly matches** the one in `okta.config.js`
- Capitalization matters (use lowercase)
- Include the path (e.g., `/callback`)

### ❌ Forgetting Logout Redirect URI
- Both **sign-in** and **sign-out** redirect URIs must be configured
- They should typically be the same

### ❌ Including https:// in Okta Domain
- **Don't** use: `https://dev-123456.okta.com`
- **Do** use: `dev-123456.okta.com`

### ❌ Wrong URL Scheme in Info.plist
- The `CFBundleURLSchemes` in `Info.plist` must match the **{{APP_SCHEME}}**
- **Don't** include `:/` or `/callback` in the scheme
- Example: If redirect URI is `com.myapp:/callback`, scheme is `com.myapp`

## Troubleshooting Okta Configuration

### Issue: "Invalid redirect URI"

**Cause**: Redirect URI in the app doesn't match Okta configuration

**Solution**:
1. Check Okta app settings → Sign-in redirect URIs
2. Check `okta.config.js` → `redirectUri`
3. Ensure they match exactly (including case and special characters)

### Issue: "This client is not authorized to use this grant type"

**Cause**: Grant types not enabled in Okta

**Solution**:
1. Go to your Okta application → General → Edit
2. Ensure "Authorization Code" and "Refresh Token" are checked
3. Save

### Issue: "Client authentication failed"

**Cause**: Trying to use client secret (not needed for native apps)

**Solution**:
- Native apps don't use client secrets
- Ensure you're using PKCE (automatically enabled)
- Don't include `client_secret` in your configuration

## Additional Okta Settings

### Enable Self-Service Registration (Optional)

If you want users to self-register:

1. Go to **Directory** → **Self-Service Registration**
2. Click **Edit**
3. Enable **Self-service registration**
4. Configure registration settings
5. Click **Save**

### Multi-Factor Authentication (Optional)

To require MFA:

1. Go to **Security** → **Authenticators**
2. Add authenticators (e.g., Okta Verify, SMS, Email)
3. Go to **Security** → **Authentication Policies**
4. Create or edit a policy
5. Add MFA requirement rules
6. Assign the policy to your application

### Custom Authorization Server (Advanced)

By default, this POC uses the "default" authorization server (`/oauth2/default`).

To use a custom authorization server:

1. Go to **Security** → **API** → **Authorization Servers**
2. Click **Add Authorization Server**
3. Configure the server
4. Update `okta.config.js`:
   ```javascript
   issuer: 'https://{{OKTA_DOMAIN}}/oauth2/your-auth-server-id',
   discoveryUri: 'https://{{OKTA_DOMAIN}}/oauth2/your-auth-server-id',
   ```

## Resources

- [Okta Native App Documentation](https://developer.okta.com/docs/guides/sign-into-mobile-app/)
- [OAuth 2.0 for Native Apps](https://developer.okta.com/docs/concepts/oauth-openid/#authorization-code-flow-with-pkce)
- [Okta React Native SDK](https://github.com/okta/okta-react-native)
- [PKCE Flow Explained](https://developer.okta.com/docs/concepts/oauth-openid/#authorization-code-flow-with-pkce)
