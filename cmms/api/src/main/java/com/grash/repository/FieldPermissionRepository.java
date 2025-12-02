package com.grash.repository;

import com.grash.model.FieldPermission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FieldPermissionRepository extends JpaRepository<FieldPermission, Long> {
    List<FieldPermission> findByRoleId(Long roleId);

    void deleteByRoleId(Long roleId);
}
