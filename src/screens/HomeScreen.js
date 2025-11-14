import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  ActivityIndicator,
  Alert,
} from 'react-native';
import {
  signOut,
  getAccessToken,
  getIdToken,
  getUser,
  isAuthenticated,
} from '@okta/okta-react-native';

/**
 * HomeScreen Component
 *
 * Displays user profile information and provides logout functionality.
 * Shows:
 * - User profile data (name, email, etc.)
 * - ID token claims
 * - Access token (truncated for security)
 */
const HomeScreen = ({navigation, route}) => {
  const [user, setUser] = useState(route.params?.user || null);
  const [accessToken, setAccessToken] = useState(null);
  const [idToken, setIdToken] = useState(null);
  const [loading, setLoading] = useState(true);
  const [loggingOut, setLoggingOut] = useState(false);

  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      // Check if user is authenticated
      const authenticated = await isAuthenticated();
      if (!authenticated) {
        navigation.replace('Login');
        return;
      }

      // Get user profile if not passed from login
      if (!user) {
        const userData = await getUser();
        setUser(userData);
      }

      // Get access token
      const {access_token} = await getAccessToken();
      setAccessToken(access_token);

      // Get ID token
      const {id_token} = await getIdToken();
      setIdToken(id_token);
    } catch (error) {
      console.error('Error loading user data:', error);
      Alert.alert('Error', 'Failed to load user data');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    Alert.alert(
      'Logout',
      'Are you sure you want to logout?',
      [
        {
          text: 'Cancel',
          style: 'cancel',
        },
        {
          text: 'Logout',
          style: 'destructive',
          onPress: performLogout,
        },
      ],
    );
  };

  const performLogout = async () => {
    setLoggingOut(true);
    try {
      /**
       * signOut() performs the following:
       * 1. Opens browser to Okta logout endpoint
       * 2. Clears Okta session
       * 3. Redirects back to app using {{IOS_REDIRECT_URI}}
       * 4. Clears tokens from iOS Keychain
       */
      await signOut();

      // Navigate back to login screen
      navigation.replace('Login');
    } catch (error) {
      console.error('Logout error:', error);
      Alert.alert('Error', 'Failed to logout. Please try again.');
      setLoggingOut(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#007dc1" />
        <Text style={styles.loadingText}>Loading user data...</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Welcome!</Text>
        <Text style={styles.headerSubtitle}>You are successfully logged in</Text>
      </View>

      {/* User Profile Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>User Profile</Text>
        <View style={styles.card}>
          <InfoRow label="Name" value={user?.name || 'N/A'} />
          <InfoRow label="Email" value={user?.email || 'N/A'} />
          <InfoRow label="Preferred Username" value={user?.preferred_username || 'N/A'} />
          <InfoRow label="Subject (sub)" value={user?.sub || 'N/A'} />
        </View>
      </View>

      {/* ID Token Claims Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>ID Token Claims</Text>
        <View style={styles.card}>
          {user && Object.entries(user).map(([key, value]) => (
            <InfoRow
              key={key}
              label={key}
              value={typeof value === 'object' ? JSON.stringify(value) : String(value)}
            />
          ))}
        </View>
      </View>

      {/* Access Token Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Access Token</Text>
        <View style={styles.card}>
          <Text style={styles.tokenText}>
            {accessToken ? `${accessToken.substring(0, 50)}...` : 'N/A'}
          </Text>
          <Text style={styles.tokenNote}>
            (Truncated for security. Stored securely in iOS Keychain)
          </Text>
        </View>
      </View>

      {/* Logout Button */}
      <View style={styles.buttonContainer}>
        <TouchableOpacity
          style={[styles.logoutButton, loggingOut && styles.logoutButtonDisabled]}
          onPress={handleLogout}
          disabled={loggingOut}>
          {loggingOut ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.logoutButtonText}>Logout</Text>
          )}
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

/**
 * InfoRow Component
 * Displays a label-value pair in a formatted row
 */
const InfoRow = ({label, value}) => (
  <View style={styles.infoRow}>
    <Text style={styles.infoLabel}>{label}:</Text>
    <Text style={styles.infoValue}>{value}</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
  },
  header: {
    backgroundColor: '#007dc1',
    padding: 24,
    paddingTop: 60,
    paddingBottom: 32,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  headerSubtitle: {
    fontSize: 16,
    color: '#e0f2fe',
  },
  section: {
    padding: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 12,
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  infoRow: {
    marginBottom: 12,
  },
  infoLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#666',
    textTransform: 'uppercase',
    marginBottom: 4,
  },
  infoValue: {
    fontSize: 14,
    color: '#333',
  },
  tokenText: {
    fontSize: 12,
    color: '#333',
    fontFamily: 'Courier',
    marginBottom: 8,
  },
  tokenNote: {
    fontSize: 11,
    color: '#999',
    fontStyle: 'italic',
  },
  buttonContainer: {
    padding: 16,
    paddingBottom: 32,
  },
  logoutButton: {
    backgroundColor: '#dc2626',
    paddingVertical: 16,
    borderRadius: 8,
    alignItems: 'center',
    shadowColor: '#dc2626',
    shadowOffset: {width: 0, height: 4},
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  },
  logoutButtonDisabled: {
    backgroundColor: '#999',
    shadowOpacity: 0.1,
  },
  logoutButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
});

export default HomeScreen;
