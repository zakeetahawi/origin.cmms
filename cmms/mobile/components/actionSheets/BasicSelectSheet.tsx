import { SheetProps } from 'react-native-actions-sheet';
import { useTheme } from 'react-native-paper';
import * as React from 'react';
import { useTranslation } from 'react-i18next';
import CustomActionSheet, {
  CustomActionSheetOption
} from './CustomActionSheet';

export default function BasicSelectSheet(
  props: SheetProps<{
    items: Array<{ label: string; value: string; color?: string }>;
    onSelect: (item: { label: string; value: string }) => void;
    title?: string;
  }>
) {
  const { t } = useTranslation();
  const theme = useTheme();

  const options: CustomActionSheetOption[] = props.payload.items.map(
    (item) => ({
      title: item.label,
      icon: 'circle-outline',
      onPress: () => props.payload.onSelect(item),
      visible: true,
      color: item.color
    })
  );

  return <CustomActionSheet options={options} />;
}
