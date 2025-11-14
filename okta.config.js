/**
 * Okta Configuration - Cargill QA Environment
 *
 * This configuration is set up for Cargill's QA Okta environment.
 *
 * IMPORTANT: Ensure your Okta application has the following settings:
 * - Application Type: Native Application
 * - Grant Types: Authorization Code, Refresh Token
 * - Sign-in redirect URI: com.cargill.oktapoc:/callback
 * - Sign-out redirect URI: com.cargill.oktapoc:/callback
 */

export default {
  // Cargill QA Okta authorization server
  // Custom authorization server: auszzmfs36uUBqxYU0h7
  issuer: 'https://login-qa-customer.cargill.com/oauth2/auszzmfs36uUBqxYU0h7',

  // Okta application Client ID
  clientId: '0oa2jt1ncajFZjObu0h8',

  // Redirect URI for login callbacks
  // This must match EXACTLY in your Okta application settings
  redirectUri: 'com.cargill.oktapoc:/callback',

  // Logout redirect URI
  // This must match EXACTLY in your Okta application settings
  endSessionRedirectUri: 'com.cargill.oktapoc:/callback',

  // Discovery URI - same as issuer
  discoveryUri: 'https://login-qa-customer.cargill.com/oauth2/auszzmfs36uUBqxYU0h7',

  // OAuth scopes
  // - openid: Required for OIDC
  // - profile: User profile information
  // - email: User email address
  // - offline_access: Enables refresh tokens
  scopes: ['openid', 'profile', 'email', 'offline_access'],

  // Hardware-backed keystore
  // Set to false to allow running on iOS Simulator
  // For production, consider setting to true for enhanced security
  requireHardwareBackedKeyStore: false,
};
