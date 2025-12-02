package com.grash.factory;

import com.grash.model.enums.StorageType;
import com.grash.service.GCPService;
import com.grash.service.MinioService;
import com.grash.service.LocalStorageService;
import com.grash.service.StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class StorageServiceFactory {
    @Value("${storage.type}")
    private StorageType storageType;

    private final GCPService gcpService;
    private final MinioService minioService;
    private final LocalStorageService localStorageService;

    public StorageServiceFactory(GCPService gcpService,
            @org.springframework.context.annotation.Lazy MinioService minioService,
            LocalStorageService localStorageService) {
        this.gcpService = gcpService;
        this.minioService = minioService;
        this.localStorageService = localStorageService;
    }

    public StorageService getStorageService() {
        switch (storageType) {
            case GCP:
                return gcpService;
            case LOCAL:
                return localStorageService;
            default:
                return minioService;
        }
    }
}
