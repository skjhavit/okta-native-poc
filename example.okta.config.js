/**
 * Example Okta Configuration
 *
 * This is an example configuration file showing the correct format.
 * Copy this to okta.config.js and replace with your actual values.
 *
 * To use:
 * 1. Copy this file: cp example.okta.config.js okta.config.js
 * 2. Replace all {{PLACEHOLDER}} values with your actual Okta configuration
 * 3. Make sure okta.config.js is in .gitignore (it already is)
 */

export default {
  /**
   * Issuer URL
   * Format: https://{{OKTA_DOMAIN}}/oauth2/default
   * Example: https://dev-123456.okta.com/oauth2/default
   *
   * IMPORTANT:
   * - Include https://
   * - Do NOT include -admin
   * - Include /oauth2/default (or your custom auth server)
   */
  issuer: 'https://{{OKTA_DOMAIN}}/oauth2/default',

  /**
   * Client ID
   * Found in: Okta Admin → Applications → Your App → General → Client ID
   * Format: Alphanumeric string (e.g., 0oa5abc123xyz789)
   */
  clientId: '{{OKTA_CLIENT_ID}}',

  /**
   * Redirect URI for login
   * Format: {{APP_SCHEME}}:/callback
   * Example: com.mycompany.app:/callback
   *
   * IMPORTANT:
   * - Must use a custom URL scheme (not http/https)
   * - Must match Okta app "Sign-in redirect URIs" setting EXACTLY
   * - Use lowercase
   * - Must match URL scheme in Info.plist
   */
  redirectUri: '{{IOS_REDIRECT_URI}}',

  /**
   * Redirect URI for logout
   * Should be the same as redirectUri
   * Must match Okta app "Sign-out redirect URIs" setting EXACTLY
   */
  endSessionRedirectUri: '{{IOS_REDIRECT_URI}}',

  /**
   * Discovery URI
   * Should be the same as issuer
   * Used to discover OAuth endpoints
   */
  discoveryUri: 'https://{{OKTA_DOMAIN}}/oauth2/default',

  /**
   * OAuth Scopes
   * - openid: Required for OpenID Connect
   * - profile: User's profile information (name, etc.)
   * - email: User's email address
   * - offline_access: Enables refresh tokens for token refresh
   */
  scopes: ['openid', 'profile', 'email', 'offline_access'],

  /**
   * Require Hardware-Backed KeyStore
   * - true: Requires device with hardware-backed security (more secure)
   * - false: Works on all devices including simulators
   *
   * For production, consider setting to true for enhanced security
   * For development, keep as false to work on simulators
   */
  requireHardwareBackedKeyStore: false,
};

/**
 * CONFIGURATION CHECKLIST
 *
 * Before running the app, ensure:
 *
 * [ ] issuer includes https:// and /oauth2/default
 * [ ] clientId is copied from Okta (no spaces)
 * [ ] redirectUri uses custom scheme (not http/https)
 * [ ] redirectUri matches Okta app settings EXACTLY
 * [ ] endSessionRedirectUri matches redirectUri
 * [ ] discoveryUri matches issuer
 * [ ] scopes includes 'openid' at minimum
 * [ ] URL scheme in Info.plist matches redirect URI scheme
 *
 * EXAMPLE VALUES:
 *
 * issuer: 'https://dev-123456.okta.com/oauth2/default'
 * clientId: '0oa5abc123xyz789'
 * redirectUri: 'com.mycompany.oktapoc:/callback'
 * endSessionRedirectUri: 'com.mycompany.oktapoc:/callback'
 * discoveryUri: 'https://dev-123456.okta.com/oauth2/default'
 *
 * Info.plist URL scheme: com.mycompany.oktapoc
 */
