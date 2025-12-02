package com.grash.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.util.Date;

@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RoleAuditLog {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @ManyToOne
    @NotNull
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private Role role;

    @ManyToOne
    @NotNull
    private OwnUser changedBy;

    @NotNull
    private String changeType; // CREATE, UPDATE, DELETE, PERMISSION_CHANGE

    private String fieldName;

    @Column(columnDefinition = "TEXT")
    private String oldValue;

    @Column(columnDefinition = "TEXT")
    private String newValue;

    @Temporal(TemporalType.TIMESTAMP)
    @NotNull
    private Date changedAt;

    @Column(columnDefinition = "TEXT")
    private String description;

    @PrePersist
    public void prePersist() {
        if (changedAt == null) {
            changedAt = new Date();
        }
    }
}
