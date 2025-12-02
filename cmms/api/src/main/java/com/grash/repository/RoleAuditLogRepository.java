package com.grash.repository;

import com.grash.model.Role;
import com.grash.model.RoleAuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Date;
import java.util.List;

public interface RoleAuditLogRepository extends JpaRepository<RoleAuditLog, Long> {

    Page<RoleAuditLog> findByRole(Role role, Pageable pageable);

    List<RoleAuditLog> findByRoleOrderByChangedAtDesc(Role role);

    Page<RoleAuditLog> findByRoleAndChangedAtBetween(
            Role role,
            Date startDate,
            Date endDate,
            Pageable pageable);

    Page<RoleAuditLog> findByChangedAtBetween(
            Date startDate,
            Date endDate,
            Pageable pageable);

    List<RoleAuditLog> findByRoleAndChangeType(Role role, String changeType);
}
