import Constants from 'expo-constants';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const googleMapsConfig = {
  apiKey: Constants.expoConfig?.extra?.GOOGLE_KEY || ''
};

// Safely get API URL from Expo config with fallback for web
const getDefaultApiUrl = (): string => {
  try {
    // Try to get from expo config first
    if (Constants.expoConfig?.extra?.API_URL) {
      return Constants.expoConfig.extra.API_URL;
    }

    // Fallback for web environment
    if (typeof window !== 'undefined') {
      // Use localhost for web development
      return 'http://localhost:8080';
    }

    // Final fallback
    return 'http://192.168.1.3:8080';
  } catch (error) {
    console.warn('Error getting API URL from config, using fallback:', error);
    return 'http://localhost:8080';
  }
};

const defaultApiUrl = getDefaultApiUrl();
export const IS_LOCALHOST = false;

// Function to get the API URL (either custom or default)
export const getApiUrl = async (): Promise<string> => {
  try {
    // Try to get custom URL from AsyncStorage
    const customUrl = await AsyncStorage.getItem('customApiUrl');

    // Use custom URL if available, otherwise use default
    const rawApiUrl = customUrl || defaultApiUrl;
    return rawApiUrl.endsWith('/') ? rawApiUrl : rawApiUrl + '/';
  } catch (error) {
    // Fallback to default URL if there's an error
    const rawApiUrl = defaultApiUrl;
    return rawApiUrl.endsWith('/') ? rawApiUrl : rawApiUrl + '/';
  }
};

