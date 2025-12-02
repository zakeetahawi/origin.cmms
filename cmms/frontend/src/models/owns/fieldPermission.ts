export interface FieldPermissionDTO {
    id?: number;
    roleId: number;
    entityType: string;
    fieldName: string;
    permissionType: 'READ_ONLY' | 'READ_WRITE' | 'HIDDEN';
}
