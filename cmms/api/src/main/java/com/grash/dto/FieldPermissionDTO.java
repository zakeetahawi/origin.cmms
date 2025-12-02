package com.grash.dto;

import com.grash.model.FieldPermission;
import com.grash.model.enums.PermissionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FieldPermissionDTO {
    private Long id;
    private Long roleId;
    private String entityType;
    private String fieldName;
    private PermissionType permissionType;

    public static FieldPermissionDTO fromEntity(FieldPermission fp) {
        return FieldPermissionDTO.builder()
                .id(fp.getId())
                .roleId(fp.getRole() != null ? fp.getRole().getId() : null)
                .entityType(fp.getEntityType())
                .fieldName(fp.getFieldName())
                .permissionType(fp.getPermissionType())
                .build();
    }
}
