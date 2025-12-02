import { useEffect, useState } from 'react';
import {
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Paper,
    TablePagination,
    Typography,
    Box,
    CircularProgress
} from '@mui/material';
import { RoleAuditLog } from 'src/models/owns/role';
import { getRoleAuditLogs } from 'src/slices/role';
import { useTranslation } from 'react-i18next';
import { format } from 'date-fns';

interface Props {
    roleId: number;
}

const RoleAuditLogTable = ({ roleId }: Props) => {
    const { t } = useTranslation();
    const [logs, setLogs] = useState<RoleAuditLog[]>([]);
    const [loading, setLoading] = useState(false);
    const [page, setPage] = useState(0);
    const [rowsPerPage, setRowsPerPage] = useState(10);
    const [total, setTotal] = useState(0);

    const fetchLogs = async () => {
        setLoading(true);
        try {
            const response = await getRoleAuditLogs(roleId, page, rowsPerPage);
            setLogs(response.content);
            setTotal(response.totalElements);
        } catch (error) {
            console.error('Failed to fetch audit logs', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        if (roleId) {
            fetchLogs();
        }
    }, [roleId, page, rowsPerPage]);

    const handleChangePage = (event: unknown, newPage: number) => {
        setPage(newPage);
    };

    const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
        setRowsPerPage(parseInt(event.target.value, 10));
        setPage(0);
    };

    if (loading && logs.length === 0) {
        return (
            <Box display="flex" justifyContent="center" p={3}>
                <CircularProgress />
            </Box>
        );
    }

    return (
        <Box sx={{ mt: 3 }}>
            <Typography variant="h6" gutterBottom>
                {t('Audit Trail')}
            </Typography>
            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow>
                            <TableCell>{t('Date')}</TableCell>
                            <TableCell>{t('User')}</TableCell>
                            <TableCell>{t('Action')}</TableCell>
                            <TableCell>{t('Field')}</TableCell>
                            <TableCell>{t('Old Value')}</TableCell>
                            <TableCell>{t('New Value')}</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {logs.map((log) => (
                            <TableRow key={log.id}>
                                <TableCell>{format(new Date(log.changedAt), 'PPpp')}</TableCell>
                                <TableCell>{log.changedByName}</TableCell>
                                <TableCell>{log.changeType}</TableCell>
                                <TableCell>{log.fieldName || '-'}</TableCell>
                                <TableCell sx={{ maxWidth: 200, wordBreak: 'break-word' }}>{log.oldValue || '-'}</TableCell>
                                <TableCell sx={{ maxWidth: 200, wordBreak: 'break-word' }}>{log.newValue || '-'}</TableCell>
                            </TableRow>
                        ))}
                        {logs.length === 0 && (
                            <TableRow>
                                <TableCell colSpan={6} align="center">
                                    {t('No logs found')}
                                </TableCell>
                            </TableRow>
                        )}
                    </TableBody>
                </Table>
            </TableContainer>
            <TablePagination
                rowsPerPageOptions={[5, 10, 25]}
                component="div"
                count={total}
                rowsPerPage={rowsPerPage}
                page={page}
                onPageChange={handleChangePage}
                onRowsPerPageChange={handleChangeRowsPerPage}
            />
        </Box>
    );
};

export default RoleAuditLogTable;
