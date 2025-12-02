package com.grash.service;

import com.grash.dto.RolePatchDTO;
import com.grash.exception.CustomException;
import com.grash.mapper.RoleMapper;
import com.grash.model.Role;
import com.grash.model.enums.RoleCode;
import com.grash.repository.RoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RoleService {
    private final RoleRepository roleRepository;
    private final RoleMapper roleMapper;
    private final CompanySettingsService companySettingsService;
    private final RoleAuditLogService roleAuditLogService;

    public Role create(Role role) {
        return roleRepository.save(role);
    }

    public Role createWithAudit(Role role, com.grash.model.OwnUser currentUser) {
        Role savedRole = roleRepository.save(role);
        roleAuditLogService.logRoleCreation(savedRole, currentUser);
        return savedRole;
    }

    public Role update(Long id, RolePatchDTO role) {
        if (roleRepository.existsById(id)) {
            Role savedRole = roleRepository.findById(id).get();
            return roleRepository.save(roleMapper.updateRole(savedRole, role));
        } else
            throw new CustomException("Not found", HttpStatus.NOT_FOUND);
    }

    public Role updateWithAudit(Long id, RolePatchDTO roleDTO, com.grash.model.OwnUser currentUser) {
        if (roleRepository.existsById(id)) {
            Role savedRole = roleRepository.findById(id).get();
            // Log changes before updating
            roleAuditLogService.logRoleUpdate(savedRole, roleDTO, currentUser);
            // Update the role
            Role updatedRole = roleMapper.updateRole(savedRole, roleDTO);
            return roleRepository.save(updatedRole);
        } else
            throw new CustomException("Not found", HttpStatus.NOT_FOUND);
    }

    public Collection<Role> getAll() {
        return roleRepository.findAll();
    }

    public void delete(Long id) {
        roleRepository.deleteById(id);
    }

    public void deleteWithAudit(Long id, com.grash.model.OwnUser currentUser) {
        Optional<Role> roleOpt = roleRepository.findById(id);
        if (roleOpt.isPresent()) {
            Role role = roleOpt.get();
            roleAuditLogService.logRoleDeletion(role, currentUser);
            roleRepository.deleteById(id);
        } else
            throw new CustomException("Not found", HttpStatus.NOT_FOUND);
    }

    public Optional<Role> findById(Long id) {
        return roleRepository.findById(id);
    }

    public Optional<Role> findByName(String name) {
        return roleRepository.findByName(name);
    }

    public Collection<Role> findByCompany(Long id) {
        return roleRepository.findByCompany_Id(id);
    }

    public List<Role> findDefaultRoles() {
        return roleRepository.findDefaultRoles(RoleCode.USER_CREATED);
    }

    public List<Role> saveAll(List<Role> roles) {
        return roleRepository.saveAll(roles);
    }
}
