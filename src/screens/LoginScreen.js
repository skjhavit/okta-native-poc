import React, {useState} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
} from 'react-native';
import {signIn, getAccessToken, getUser} from '@okta/okta-react-native';

/**
 * LoginScreen Component
 *
 * This screen provides the Okta login functionality using PKCE flow.
 * The Okta Sign-In Widget cannot be embedded in React Native, so we use
 * the secure browser-based authentication flow instead.
 *
 * Flow:
 * 1. User taps "Login with Okta"
 * 2. App opens Safari/Chrome with Okta login page (PKCE + OAuth)
 * 3. User authenticates in the browser
 * 4. Browser redirects back to app using {{IOS_REDIRECT_URI}}
 * 5. App exchanges authorization code for tokens
 * 6. Navigate to HomeScreen with user data
 */
const LoginScreen = ({navigation}) => {
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    setLoading(true);
    try {
      /**
       * signIn() performs the following:
       * 1. Generates PKCE code verifier and challenge
       * 2. Opens system browser (Safari on iOS) to Okta login page
       * 3. User authenticates in the browser
       * 4. Okta redirects to {{IOS_REDIRECT_URI}} (handled by iOS URL scheme)
       * 5. SDK automatically exchanges authorization code for tokens
       * 6. Returns success when tokens are stored securely in Keychain
       */
      await signIn();

      // Tokens are now stored securely in iOS Keychain
      // Retrieve access token
      const {access_token} = await getAccessToken();
      console.log('Access token obtained:', access_token ? 'Yes' : 'No');

      // Retrieve user profile information
      const user = await getUser();
      console.log('User profile:', user);

      // Navigate to HomeScreen with user data
      navigation.replace('Home', {user});
    } catch (error) {
      console.error('Login error:', error);

      // Handle common errors
      if (error.code === 'E_OAUTH_FAILED') {
        Alert.alert(
          'Login Failed',
          'OAuth authentication failed. Please check your Okta configuration.',
        );
      } else if (error.code === 'E_SIGN_IN_FAILED') {
        Alert.alert(
          'Sign In Failed',
          'Unable to sign in. Please try again.',
        );
      } else if (error.code === 'user_cancelled_login') {
        // User cancelled the login flow - no alert needed
        console.log('User cancelled login');
      } else {
        Alert.alert(
          'Error',
          error.message || 'An unexpected error occurred during login.',
        );
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Okta POC</Text>
        <Text style={styles.subtitle}>React Native iOS Integration</Text>

        <View style={styles.infoBox}>
          <Text style={styles.infoTitle}>About This POC</Text>
          <Text style={styles.infoText}>
            This demonstrates Okta authentication using:
          </Text>
          <Text style={styles.bulletPoint}>• PKCE (Proof Key for Code Exchange)</Text>
          <Text style={styles.bulletPoint}>• OAuth 2.0 Authorization Code Flow</Text>
          <Text style={styles.bulletPoint}>• Secure browser-based authentication</Text>
          <Text style={styles.bulletPoint}>• iOS Keychain for token storage</Text>
        </View>

        <TouchableOpacity
          style={[styles.loginButton, loading && styles.loginButtonDisabled]}
          onPress={handleLogin}
          disabled={loading}>
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.loginButtonText}>Login with Okta</Text>
          )}
        </TouchableOpacity>

        <Text style={styles.note}>
          Note: This will open Safari to complete authentication securely.
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 40,
  },
  infoBox: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    marginBottom: 40,
    width: '100%',
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  infoTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 12,
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  bulletPoint: {
    fontSize: 14,
    color: '#666',
    marginLeft: 8,
    marginTop: 4,
  },
  loginButton: {
    backgroundColor: '#007dc1',
    paddingHorizontal: 40,
    paddingVertical: 16,
    borderRadius: 8,
    width: '100%',
    alignItems: 'center',
    shadowColor: '#007dc1',
    shadowOffset: {width: 0, height: 4},
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  },
  loginButtonDisabled: {
    backgroundColor: '#999',
    shadowOpacity: 0.1,
  },
  loginButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  note: {
    marginTop: 16,
    fontSize: 12,
    color: '#999',
    textAlign: 'center',
    fontStyle: 'italic',
  },
});

export default LoginScreen;
