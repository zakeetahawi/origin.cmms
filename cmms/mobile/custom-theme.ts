import { MD3LightTheme as DefaultTheme, useTheme } from 'react-native-paper';

export const customTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#5569ff',
    secondary: '#959be0',
    tertiary: '#9DA1A1',
    background: '#ebecf6',
    secondaryContainer: '#7b7d93',
    success: '#57CA22',
    warning: '#FFA319',
    error: '#FF1943',
    info: '#33C2FF',
    black: '#223354',
    white: '#ffffff',
    primaryAlt: '#000C57',
    primaryContainer: '#333586',
    tertiaryContainer: 'black',
    grey: '#676b6b'
  }
};
export const useAppTheme = () => useTheme<typeof customTheme>();
