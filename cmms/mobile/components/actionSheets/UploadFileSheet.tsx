import { SheetProps } from 'react-native-actions-sheet';
import { useTheme } from 'react-native-paper';
import * as React from 'react';
import { useTranslation } from 'react-i18next';
import CustomActionSheet, { CustomActionSheetOption } from './CustomActionSheet';

export default function PartDetailsSheet(
  props: SheetProps<{
    onPickImage: () => void;
    onTakePhoto: () => void;
  }>
) {
  const { t } = useTranslation();
  const theme = useTheme();
  const options: CustomActionSheetOption[] = [
    {
      title: t('library'),
      icon: 'image-multiple',
      onPress: props.payload.onPickImage,
      visible: true
    },
    {
      title: t('camera'),
      icon: 'camera',
      onPress: props.payload.onTakePhoto,
      visible: true
    }
  ];

  return <CustomActionSheet options={options} />;
}
