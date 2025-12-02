import {
  apiUrl,
  BrandRawConfig,
  brandRawConfig,
  customLogoPaths
} from '../config';
import { useSelector } from '../store';
import useAuth from './useAuth';

const DEFAULT_WHITE_LOGO = '/static/images/logo/logo-white.png';
const DEFAULT_DARK_LOGO = '/static/images/logo/logo.png';
const CUSTOM_DARK_LOGO = `${apiUrl}images/custom-logo.png`;
const CUSTOM_WHITE_LOGO = `${apiUrl}images/custom-logo-white.png`;

interface BrandConfig extends BrandRawConfig {
  logo: { white: string; dark: string };
}
export function useBrand(): BrandConfig {
  const { company } = useAuth();
  const defaultBrand: Omit<BrandConfig, 'logo'> = {
    name: 'Atlas CMMS',
    shortName: 'Atlas',
    website: 'https://www.atlas-cmms.com',
    mail: 'contact@atlas-cmms.com',
    phone: '+212 6 30 69 00 50',
    addressStreet: '410, Boulevard Zerktouni, Hamad, №1',
    addressCity: 'Casablanca-Morocco 20040'
  };

  // Priority: 1. Company logo from database, 2. Custom logo from env, 3. Default logo
  const companyLogo = company?.logo?.url;
  const logoWhite = companyLogo || (customLogoPaths ? CUSTOM_WHITE_LOGO : DEFAULT_WHITE_LOGO);
  const logoDark = companyLogo || (customLogoPaths ? CUSTOM_DARK_LOGO : DEFAULT_DARK_LOGO);

  return {
    logo: {
      white: logoWhite,
      dark: logoDark
    },
    ...(brandRawConfig ? brandRawConfig : defaultBrand)
  };
}
