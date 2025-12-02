package com.grash.service;

import org.springframework.boot.actuate.health.*;
import org.springframework.stereotype.Component;

@Component
public class CustomHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        // Simple health check without circular dependency
        return Health.up()
                .withDetail("status", "Application is running")
                .build();
    }
}
