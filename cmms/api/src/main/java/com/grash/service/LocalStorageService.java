package com.grash.service;

import com.grash.exception.CustomException;
import com.grash.model.File;
import com.grash.utils.Helper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@Service
@RequiredArgsConstructor
public class LocalStorageService implements StorageService {

    @Value("${storage.local.path:uploads}")
    private String uploadPath;

    @Value("${api.host:http://localhost:8080}")
    private String apiHost;

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(Paths.get(uploadPath));
        } catch (IOException e) {
            throw new CustomException("Could not initialize storage location", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public String upload(MultipartFile file, String folder) {
        Helper helper = new Helper();
        String filename = helper.generateString() + "_" + file.getOriginalFilename();
        Path folderPath = Paths.get(uploadPath, folder);

        try {
            if (!Files.exists(folderPath)) {
                Files.createDirectories(folderPath);
            }

            Path destinationFile = folderPath.resolve(filename);
            try (var inputStream = file.getInputStream()) {
                Files.copy(inputStream, destinationFile, StandardCopyOption.REPLACE_EXISTING);
            }

            return folder + "/" + filename;
        } catch (IOException e) {
            throw new CustomException("Failed to store file " + filename, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public byte[] download(String filePath) {
        try {
            Path file = Paths.get(uploadPath, filePath);
            if (Files.exists(file) && Files.isReadable(file)) {
                return Files.readAllBytes(file);
            } else {
                throw new CustomException("Could not read file: " + filePath, HttpStatus.NOT_FOUND);
            }
        } catch (IOException e) {
            throw new CustomException("Could not read file: " + filePath, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    public byte[] download(File file) {
        // Assuming file.getPath() stores the relative path like "folder/filename"
        return download(file.getPath());
    }

    @Override
    public String generateSignedUrl(File file, long expirationMinutes) {
        // For local storage, we just return a direct URL to the file endpoint
        // Assuming there is an endpoint like /api/files/download?path=...
        // Or we can just return the path if the frontend handles it
        return apiHost + "/api/files/download?path=" + file.getPath();
    }

    @Override
    public String generateSignedUrl(String filePath, long expirationMinutes) {
        return apiHost + "/api/files/download?path=" + filePath;
    }
}
