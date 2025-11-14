/**
 * Okta React Native iOS POC
 * Main Application Entry Point
 *
 * This app demonstrates a complete Okta OAuth integration for iOS:
 * - PKCE-based authentication flow
 * - Secure browser redirect handling
 * - Token management with iOS Keychain
 * - User profile retrieval
 * - Logout functionality
 */

import React, {useEffect} from 'react';
import {StatusBar, Platform, Alert} from 'react-native';
import {createConfig, EventEmitter} from '@okta/okta-react-native';
import AppNavigator from './src/navigation/AppNavigator';
import oktaConfig from './okta.config';

/**
 * Initialize Okta SDK with configuration
 *
 * This must be called before any Okta SDK methods are used.
 * The configuration is loaded from okta.config.js
 */
const initializeOkta = async () => {
  try {
    await createConfig({
      clientId: oktaConfig.clientId,
      redirectUri: oktaConfig.redirectUri,
      endSessionRedirectUri: oktaConfig.endSessionRedirectUri,
      discoveryUri: oktaConfig.discoveryUri,
      scopes: oktaConfig.scopes,
      requireHardwareBackedKeyStore: oktaConfig.requireHardwareBackedKeyStore,
    });
    console.log('Okta SDK initialized successfully');
  } catch (error) {
    console.error('Failed to initialize Okta SDK:', error);
    Alert.alert(
      'Configuration Error',
      'Failed to initialize Okta. Please check your configuration in okta.config.js',
    );
  }
};

const App = () => {
  useEffect(() => {
    // Initialize Okta SDK when app starts
    initializeOkta();

    /**
     * Set up event listeners for OAuth callbacks
     *
     * These events are triggered when the app receives OAuth redirects:
     * - onSignInSuccess: Authentication succeeded
     * - onSignInFailure: Authentication failed
     * - onSignOutSuccess: Logout succeeded
     * - onSignOutFailure: Logout failed
     */
    const signInSuccessListener = EventEmitter.addListener(
      'onSignInSuccess',
      event => {
        console.log('Sign in success:', event);
      },
    );

    const signInFailureListener = EventEmitter.addListener(
      'onSignInFailure',
      event => {
        console.error('Sign in failure:', event);
      },
    );

    const signOutSuccessListener = EventEmitter.addListener(
      'onSignOutSuccess',
      event => {
        console.log('Sign out success:', event);
      },
    );

    const signOutFailureListener = EventEmitter.addListener(
      'onSignOutFailure',
      event => {
        console.error('Sign out failure:', event);
      },
    );

    // Cleanup listeners on unmount
    return () => {
      signInSuccessListener.remove();
      signInFailureListener.remove();
      signOutSuccessListener.remove();
      signOutFailureListener.remove();
    };
  }, []);

  return (
    <>
      <StatusBar barStyle="light-content" backgroundColor="#007dc1" />
      <AppNavigator />
    </>
  );
};

export default App;
