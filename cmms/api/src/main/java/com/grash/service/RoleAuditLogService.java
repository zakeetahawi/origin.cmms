package com.grash.service;

import com.grash.dto.RolePatchDTO;
import com.grash.model.OwnUser;
import com.grash.model.Role;
import com.grash.model.RoleAuditLog;
import com.grash.model.enums.PermissionEntity;
import com.grash.repository.RoleAuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class RoleAuditLogService {

    private final RoleAuditLogRepository roleAuditLogRepository;

    public RoleAuditLog create(RoleAuditLog roleAuditLog) {
        return roleAuditLogRepository.save(roleAuditLog);
    }

    public void logRoleCreation(Role role, OwnUser changedBy) {
        RoleAuditLog log = RoleAuditLog.builder()
                .role(role)
                .changedBy(changedBy)
                .changeType("CREATE")
                .description("Role created: " + role.getName())
                .changedAt(new Date())
                .build();
        roleAuditLogRepository.save(log);
    }

    public void logRoleDeletion(Role role, OwnUser changedBy) {
        RoleAuditLog log = RoleAuditLog.builder()
                .role(role)
                .changedBy(changedBy)
                .changeType("DELETE")
                .description("Role deleted: " + role.getName())
                .changedAt(new Date())
                .build();
        roleAuditLogRepository.save(log);
    }

    public void logRoleUpdate(Role oldRole, RolePatchDTO updates, OwnUser changedBy) {
        // Log name change
        if (updates.getName() != null && !updates.getName().equals(oldRole.getName())) {
            logFieldChange(oldRole, changedBy, "name", oldRole.getName(), updates.getName(), "NAME_CHANGED");
        }

        // Log description change
        if (updates.getDescription() != null && !updates.getDescription().equals(oldRole.getDescription())) {
            logFieldChange(oldRole, changedBy, "description",
                    oldRole.getDescription(), updates.getDescription(), "DESCRIPTION_CHANGED");
        }

        // Log permission changes
        logPermissionChanges(oldRole, updates, changedBy);
    }

    private void logPermissionChanges(Role oldRole, RolePatchDTO updates, OwnUser changedBy) {
        // Create permissions
        if (updates.getCreatePermissions() != null) {
            logPermissionSetChange(oldRole, changedBy, "createPermissions",
                    oldRole.getCreatePermissions(), new HashSet<>(updates.getCreatePermissions()));
        }

        // View permissions
        if (updates.getViewPermissions() != null) {
            logPermissionSetChange(oldRole, changedBy, "viewPermissions",
                    oldRole.getViewPermissions(), new HashSet<>(updates.getViewPermissions()));
        }

        // View other permissions
        if (updates.getViewOtherPermissions() != null) {
            logPermissionSetChange(oldRole, changedBy, "viewOtherPermissions",
                    oldRole.getViewOtherPermissions(), new HashSet<>(updates.getViewOtherPermissions()));
        }

        // Edit other permissions
        if (updates.getEditOtherPermissions() != null) {
            logPermissionSetChange(oldRole, changedBy, "editOtherPermissions",
                    oldRole.getEditOtherPermissions(), new HashSet<>(updates.getEditOtherPermissions()));
        }

        // Delete other permissions
        if (updates.getDeleteOtherPermissions() != null) {
            logPermissionSetChange(oldRole, changedBy, "deleteOtherPermissions",
                    oldRole.getDeleteOtherPermissions(), new HashSet<>(updates.getDeleteOtherPermissions()));
        }
    }

    private void logPermissionSetChange(Role role, OwnUser changedBy, String fieldName,
            Set<PermissionEntity> oldSet, Set<PermissionEntity> newSet) {
        // Find added permissions
        for (PermissionEntity permission : newSet) {
            if (!oldSet.contains(permission)) {
                logFieldChange(role, changedBy, fieldName, null, permission.toString(), "PERMISSION_ADDED");
            }
        }

        // Find removed permissions
        for (PermissionEntity permission : oldSet) {
            if (!newSet.contains(permission)) {
                logFieldChange(role, changedBy, fieldName, permission.toString(), null, "PERMISSION_REMOVED");
            }
        }
    }

    private void logFieldChange(Role role, OwnUser changedBy, String fieldName,
            String oldValue, String newValue, String changeType) {
        RoleAuditLog log = RoleAuditLog.builder()
                .role(role)
                .changedBy(changedBy)
                .changeType(changeType)
                .fieldName(fieldName)
                .oldValue(oldValue)
                .newValue(newValue)
                .description(String.format("Field '%s' changed from '%s' to '%s'",
                        fieldName, oldValue, newValue))
                .changedAt(new Date())
                .build();
        roleAuditLogRepository.save(log);
    }

    public Page<RoleAuditLog> getAuditLogsByRole(Role role, Pageable pageable) {
        return roleAuditLogRepository.findByRole(role, pageable);
    }

    public List<RoleAuditLog> getAuditLogsByRole(Role role) {
        return roleAuditLogRepository.findByRoleOrderByChangedAtDesc(role);
    }

    public Page<RoleAuditLog> getAuditLogsByRoleAndDateRange(
            Role role, Date startDate, Date endDate, Pageable pageable) {
        return roleAuditLogRepository.findByRoleAndChangedAtBetween(role, startDate, endDate, pageable);
    }

    public Page<RoleAuditLog> getAuditLogsByDateRange(
            Date startDate, Date endDate, Pageable pageable) {
        return roleAuditLogRepository.findByChangedAtBetween(startDate, endDate, pageable);
    }
}
