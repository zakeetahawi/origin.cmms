package com.grash.dto;

import com.grash.model.RoleAuditLog;
import lombok.Data;

import java.util.Date;

@Data
public class RoleAuditLogDTO {
    private Long id;
    private Long roleId;
    private String roleName;
    private Long changedById;
    private String changedByName;
    private String changeType;
    private String fieldName;
    private String oldValue;
    private String newValue;
    private Date changedAt;
    private String description;

    public static RoleAuditLogDTO fromEntity(RoleAuditLog log) {
        RoleAuditLogDTO dto = new RoleAuditLogDTO();
        dto.setId(log.getId());
        dto.setRoleId(log.getRole().getId());
        dto.setRoleName(log.getRole().getName());
        dto.setChangedById(log.getChangedBy().getId());
        dto.setChangedByName(log.getChangedBy().getFirstName() + " " + log.getChangedBy().getLastName());
        dto.setChangeType(log.getChangeType());
        dto.setFieldName(log.getFieldName());
        dto.setOldValue(log.getOldValue());
        dto.setNewValue(log.getNewValue());
        dto.setChangedAt(log.getChangedAt());
        dto.setDescription(log.getDescription());
        return dto;
    }
}
