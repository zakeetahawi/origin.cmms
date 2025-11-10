import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';
import type { AppThunk } from 'src/store';
import api from '../utils/api';
import { revertAll } from 'src/utils/redux';

const basePath = 'license';
interface LicenseState {
  isLicenseValid: boolean | null;
}

const initialState: LicenseState = {
  isLicenseValid: null
};

const slice = createSlice({
  name: 'license',
  initialState,
  reducers: {
    getLicenseValidity(
      state: LicenseState,
      action: PayloadAction<{ validity: boolean }>
    ) {
      const { validity } = action.payload;
      state.isLicenseValid = validity;
    }
  }
});

export const reducer = slice.reducer;

export const getLicenseValidity = (): AppThunk => async (dispatch) => {
  const { success } = await api.get<{ success: boolean }>(
    `${basePath}/validity`
  );
  dispatch(slice.actions.getLicenseValidity({ validity: success }));
};

export default slice;
