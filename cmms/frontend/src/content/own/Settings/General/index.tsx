import {
  Box,
  debounce,
  Divider,
  Grid,
  MenuItem,
  Select,
  TextField,
  Typography,
  Button,
  CircularProgress,
  styled,
  Avatar
} from '@mui/material';
import { useTranslation } from 'react-i18next';
import SettingsLayout from '../SettingsLayout';
import { Field, Formik } from 'formik';
import * as Yup from 'yup';
import CustomSwitch from '../../components/form/CustomSwitch';
import useAuth from '../../../../hooks/useAuth';
import internationalization, {
  supportedLanguages
} from '../../../../i18n/i18n';
import { useDispatch, useSelector } from '../../../../store';
import { getCurrencies } from '../../../../slices/currency';
import { ChangeEvent, useContext, useEffect, useMemo, useState } from 'react';
import { GeneralPreferences } from '../../../../models/owns/generalPreferences';
import { CustomSnackBarContext } from '../../../../contexts/CustomSnackBarContext';
import { CompanySettingsContext } from '../../../../contexts/CompanySettingsContext';
import { Company } from '../../../../models/owns/company';
import UploadTwoToneIcon from '@mui/icons-material/UploadTwoTone';

const Input = styled('input')({
  display: 'none'
});

const LogoPreview = styled(Box)(
  ({ theme }) => `
    display: flex;
    align-items: center;
    gap: ${theme.spacing(2)};
    margin-top: ${theme.spacing(2)};
    margin-bottom: ${theme.spacing(2)};
`
);

function GeneralSettings() {
  const { t }: { t: any } = useTranslation();
  const switchLanguage = ({ lng }: { lng: any }) => {
    internationalization.changeLanguage(lng);
  };
  const { showSnackBar } = useContext(CustomSnackBarContext);
  const { uploadFiles } = useContext(CompanySettingsContext);
  const { patchGeneralPreferences, companySettings, patchCompany, company } = useAuth();
  const { generalPreferences } = companySettings;
  const dispatch = useDispatch();
  const { currencies } = useSelector((state) => state.currencies);
  const [changingLogo, setChangingLogo] = useState<boolean>(false);

  useEffect(() => {
    dispatch(getCurrencies());
  }, []);

  const onDaysBeforePMNotifChange = (event) =>
    patchGeneralPreferences({
      daysBeforePrevMaintNotification: Number(event.target.value)
    }).then(() => showSnackBar(t('changes_saved_success'), 'success'));
  const debouncedPMNotifChange = useMemo(
    () => debounce(onDaysBeforePMNotifChange, 1300),
    []
  );

  const onChangeLogo = (event: ChangeEvent<HTMLInputElement>) => {
    setChangingLogo(true);
    uploadFiles([], Array.from(event.target.files), true)
      .then((files) =>
        patchCompany({ logo: { id: files[0].id } } as Partial<Company>)
      )
      .then(() => showSnackBar(t('logo_updated_success'), 'success'))
      .catch(() => showSnackBar(t('logo_update_failed'), 'error'))
      .finally(() => setChangingLogo(false));
  };

  const switches: {
    title: string;
    description: string;
    name: keyof GeneralPreferences;
  }[] = [
    {
      title: t('auto_assign_wo'),
      description: t('auto_assign_wo_description'),
      name: 'autoAssignWorkOrders'
    },
    {
      title: t('auto_assign_requests'),
      description: t('auto_assign_requests_description'),
      name: 'autoAssignRequests'
    },
    {
      title: t('disable_closed_wo_notification'),
      description: t('disable_closed_wo_notification_description'),
      name: 'disableClosedWorkOrdersNotif'
    },
    {
      title: t('ask_feedback_wo_closed'),
      description: t('ask_feedback_wo_closed_description'),
      name: 'askFeedBackOnWOClosed'
    },
    {
      title: t('include_labor_in_total_cost'),
      description: t('include_labor_in_total_cost_description'),
      name: 'laborCostInTotalCost'
    },
    {
      title: t('enable_wo_updates_requesters'),
      description: t('enable_wo_updates_requesters_description'),
      name: 'woUpdateForRequesters'
    },
    {
      title: t('simplify_wo'),
      description: t('simplify_wo_description'),
      name: 'simplifiedWorkOrder'
    }
  ];
  const onSubmit = async (
    _values,
    { resetForm, setErrors, setStatus, setSubmitting }
  ) => {};
  return (
    <Grid item xs={12}>
      <Box p={4}>
        <Formik
          initialValues={generalPreferences}
          validationSchema={Yup.object().shape({
            language: Yup.string(),
            dateFormat: Yup.string(),
            currency: Yup.string(),
            businessType: Yup.string(),
            autoAssignWorkOrders: Yup.bool(),
            autoAssignRequests: Yup.bool(),
            disableClosedWorkOrdersNotif: Yup.bool(),
            askFeedBackOnWOClosed: Yup.bool(),
            laborCostInTotalCost: Yup.bool(),
            woUpdateForRequesters: Yup.bool()
          })}
          onSubmit={onSubmit}
        >
          {({
            errors,
            handleBlur,
            handleChange,
            handleSubmit,
            isSubmitting,
            touched,
            values
          }) => (
            <form onSubmit={handleSubmit}>
              <Grid container spacing={3}>
                <Grid item xs={12}>
                  <Grid container spacing={2}>
                    <Grid item xs={12}>
                      <Typography variant="h6" sx={{ mb: 0.5 }}>
                        {t('company_logo')}
                      </Typography>
                      <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                        {t('company_logo_description')}
                      </Typography>
                      <LogoPreview>
                        {company?.logo?.url && (
                          <Avatar
                            src={company.logo.url}
                            variant="rounded"
                            sx={{ width: 80, height: 80 }}
                          />
                        )}
                        <Box>
                          <Input
                            accept="image/*"
                            id="change-logo-input"
                            disabled={changingLogo}
                            onChange={onChangeLogo}
                            type="file"
                          />
                          <label htmlFor="change-logo-input">
                            <Button
                              startIcon={
                                changingLogo ? (
                                  <CircularProgress size="1rem" />
                                ) : (
                                  <UploadTwoToneIcon />
                                )
                              }
                              variant="contained"
                              disabled={changingLogo}
                              component="span"
                            >
                              {company?.logo ? t('change_logo') : t('upload_logo')}
                            </Button>
                          </label>
                        </Box>
                      </LogoPreview>
                    </Grid>
                    <Grid item xs={12}>
                      <Divider />
                    </Grid>
                    <Grid item xs={12}>
                      <Typography variant="h6" sx={{ mb: 0.5 }}>
                        {t('language')}
                      </Typography>
                      <Field
                        onChange={(event) => {
                          patchGeneralPreferences({
                            language: event.target.value
                          });
                          switchLanguage({
                            lng: event.target.value.toLowerCase()
                          });
                        }}
                        value={generalPreferences.language}
                        as={Select}
                        name="language"
                      >
                        {supportedLanguages.map((language) => (
                          <MenuItem
                            key={language.code}
                            value={language.code.toUpperCase()}
                          >
                            {language.label}
                          </MenuItem>
                        ))}
                      </Field>
                    </Grid>
                    <Grid item xs={12}>
                      <Typography variant="h6" sx={{ mb: 0.5 }}>
                        {t('date_format')}
                      </Typography>
                      <Field
                        onChange={(event) =>
                          patchGeneralPreferences({
                            dateFormat: event.target.value
                          })
                        }
                        value={generalPreferences.dateFormat}
                        as={Select}
                        name="dateFormat"
                      >
                        <MenuItem value="MMDDYY">MM/DD/YY</MenuItem>
                        <MenuItem value="DDMMYY">DD/MM/YY</MenuItem>
                      </Field>
                    </Grid>
                    <Grid item xs={12}>
                      <Typography variant="h6" sx={{ mb: 0.5 }}>
                        {t('currency')}
                      </Typography>
                      <Field
                        onChange={(event) =>
                          patchGeneralPreferences({
                            currency: currencies.find(
                              (currency) =>
                                currency.id === Number(event.target.value)
                            )
                          })
                        }
                        value={generalPreferences.currency?.id}
                        as={Select}
                        name="currency"
                      >
                        {[...currencies]
                          .sort((a, b) => a.name.localeCompare(b.name))
                          .map((currency) => (
                            <MenuItem
                              key={currency.id}
                              value={currency.id}
                            >{`${currency.name} - ${currency.code}`}</MenuItem>
                          ))}
                      </Field>
                    </Grid>
                    <Grid item xs={12}>
                      <Typography variant="h6" sx={{ mb: 0.5 }}>
                        {t('days_before_pm_notification')}
                      </Typography>
                      <TextField
                        onChange={debouncedPMNotifChange}
                        type={'number'}
                        defaultValue={
                          generalPreferences.daysBeforePrevMaintNotification
                        }
                        name="daysBeforePrevMaintNotification"
                        InputProps={{
                          endAdornment: <Typography>{t('day')}</Typography>
                        }}
                      >
                        {currencies.map((currency) => (
                          <MenuItem
                            key={currency.id}
                            value={currency.id}
                          >{`${currency.name} - ${currency.code}`}</MenuItem>
                        ))}
                      </TextField>
                    </Grid>
                    {/*<Grid item xs={12}>
                        <Typography variant="h6" sx={{ mb: 0.5 }}>
                          {t('business_type')}
                        </Typography>
                        <Field
                          onChange={(event) =>
                            patchGeneralPreferences({
                              businessType: event.target.value
                            })
                          }
                          value={generalPreferences.businessType}
                          as={Select}
                          name="businessType"
                        >
                          <MenuItem value="GENERAL_ASSET_MANAGEMENT">
                            {t('general_asset_management')}
                          </MenuItem>
                          <MenuItem value="PHYSICAL_ASSET_MANAGEMENT">
                            {t('physical_asset_management')}
                          </MenuItem>
                        </Field>
                      </Grid>*/}
                  </Grid>
                  <Divider sx={{ mt: 3 }} />
                  <Grid container spacing={2} sx={{ mt: 1 }}>
                    {switches.map((element) => (
                      <CustomSwitch
                        key={element.name}
                        title={element.title}
                        description={element.description}
                        checked={values[element.name]}
                        name={element.name}
                        handleChange={(event) => {
                          handleChange(event);
                          patchGeneralPreferences({
                            [element.name]: event.target.checked
                          });
                        }}
                      />
                    ))}
                  </Grid>
                </Grid>
              </Grid>
            </form>
          )}
        </Formik>
      </Box>
    </Grid>
  );
}

export default GeneralSettings;
