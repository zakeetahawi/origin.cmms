package com.grash.service;

import com.grash.model.FieldPermission;
import com.grash.repository.FieldPermissionRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FieldPermissionService {

    private final FieldPermissionRepository fieldPermissionRepository;

    public FieldPermissionService(FieldPermissionRepository fieldPermissionRepository) {
        this.fieldPermissionRepository = fieldPermissionRepository;
    }

    public List<FieldPermission> getByRoleId(Long roleId) {
        return fieldPermissionRepository.findByRoleId(roleId);
    }

    public FieldPermission save(FieldPermission fieldPermission) {
        return fieldPermissionRepository.save(fieldPermission);
    }

    public void deleteByRoleId(Long roleId) {
        fieldPermissionRepository.deleteByRoleId(roleId);
    }

    public Optional<FieldPermission> findById(Long id) {
        return fieldPermissionRepository.findById(id);
    }
}
