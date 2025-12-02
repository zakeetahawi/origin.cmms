import React, { useEffect, useState } from 'react';
import { Box, Button, FormControl, InputLabel, MenuItem, Select, Table, TableBody, TableCell, TableHead, TableRow, Typography } from '@mui/material';
import { useTranslation } from 'react-i18next';
import { FieldPermissionDTO } from '../../../../models/owns/fieldPermission';
import { getFieldPermissions, saveFieldPermissions } from '../../../../slices/role';

interface RoleFieldPermissionsProps {
    roleId: number;
}

const permissionOptions = ['READ_ONLY', 'READ_WRITE', 'HIDDEN'] as const;

type PermissionType = typeof permissionOptions[number];

export default function RoleFieldPermissions({ roleId }: RoleFieldPermissionsProps) {
    const { t } = useTranslation();
    const [permissions, setPermissions] = useState<FieldPermissionDTO[]>([]);
    const [loading, setLoading] = useState<boolean>(false);

    useEffect(() => {
        const fetch = async () => {
            setLoading(true);
            const data = await getFieldPermissions(roleId);
            setPermissions(data);
            setLoading(false);
        };
        fetch();
    }, [roleId]);

    const handleChange = (index: number, newType: PermissionType) => {
        setPermissions(prev => {
            const copy = [...prev];
            copy[index] = { ...copy[index], permissionType: newType };
            return copy;
        });
    };

    const handleSave = async () => {
        setLoading(true);
        await saveFieldPermissions(roleId, permissions);
        setLoading(false);
    };

    return (
        <Box sx={{ mt: 4 }}>
            <Typography variant="h5" gutterBottom>{t('field_permissions')}</Typography>
            <Table>
                <TableHead>
                    <TableRow>
                        <TableCell>{t('entity_type')}</TableCell>
                        <TableCell>{t('field_name')}</TableCell>
                        <TableCell>{t('permission')}</TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    {permissions.map((perm, idx) => (
                        <TableRow key={perm.id ?? idx}>
                            <TableCell>{perm.entityType}</TableCell>
                            <TableCell>{perm.fieldName}</TableCell>
                            <TableCell>
                                <FormControl fullWidth>
                                    <InputLabel>{t('permission')}</InputLabel>
                                    <Select
                                        value={perm.permissionType}
                                        label={t('permission')}
                                        onChange={e => handleChange(idx, e.target.value as PermissionType)}
                                    >
                                        {permissionOptions.map(opt => (
                                            <MenuItem key={opt} value={opt}>{t(opt.toLowerCase())}</MenuItem>
                                        ))}
                                    </Select>
                                </FormControl>
                            </TableCell>
                        </TableRow>
                    ))}
                </TableBody>
            </Table>
            <Box sx={{ mt: 2, display: 'flex', justifyContent: 'flex-end' }}>
                <Button variant="contained" color="primary" onClick={handleSave} disabled={loading}>
                    {t('save')}
                </Button>
            </Box>
        </Box>
    );
}
