/**
 * Okta Configuration
 *
 * IMPORTANT: Replace these placeholders with your actual Okta configuration:
 * - {{OKTA_DOMAIN}}: Your Okta domain (e.g., dev-123456.okta.com)
 * - {{OKTA_CLIENT_ID}}: Your Okta application client ID
 * - {{APP_SCHEME}}: Your app's URL scheme (e.g., com.myapp)
 */

export default {
  // Your Okta domain WITHOUT https://
  // Example: dev-123456.okta.com
  issuer: 'https://{{OKTA_DOMAIN}}/oauth2/default',

  // Your Okta application's Client ID
  clientId: '{{OKTA_CLIENT_ID}}',

  // Redirect URI for login callbacks
  // Format: {{APP_SCHEME}}:/callback
  // Example: com.myapp:/callback
  redirectUri: '{{IOS_REDIRECT_URI}}',

  // Logout redirect URI
  // Must match the login redirect URI
  endSessionRedirectUri: '{{IOS_REDIRECT_URI}}',

  // Discovery URI - automatically configured from issuer
  discoveryUri: 'https://{{OKTA_DOMAIN}}/oauth2/default',

  // OAuth scopes
  scopes: ['openid', 'profile', 'email', 'offline_access'],

  // PKCE is required for native apps
  requireHardwareBackedKeyStore: false,
};
