package com.grash.service;

import com.grash.dto.CompanyPatchDTO;
import com.grash.exception.CustomException;
import com.grash.mapper.CompanyMapper;
import com.grash.model.Company;
import com.grash.model.OwnUser;
import com.grash.model.enums.RoleType;
import com.grash.repository.CompanyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import java.util.Collection;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CompanyService {
    private final CompanyRepository companyRepository;
    private final CompanyMapper companyMapper;
    private final EntityManager em;

    private final com.grash.repository.FileRepository fileRepository;

    public Company create(Company Company) {
        return companyRepository.save(Company);
    }

    public Company update(Company Company) {
        return companyRepository.save(Company);
    }

    public Collection<Company> getAll() {
        return companyRepository.findAll();
    }

    public void delete(Long id) {
        companyRepository.deleteById(id);
    }

    public Optional<Company> findById(Long id) {
        return companyRepository.findById(id);
    }

    @Transactional
    public Company update(Long id, CompanyPatchDTO company) {
        if (companyRepository.existsById(id)) {
            if (company.getCoverImage() != null && company.getCoverImage().getId() != null) {
                company.setCoverImage(fileRepository.findById(company.getCoverImage().getId()).orElse(null));
            }
            if (company.getLogo() != null && company.getLogo().getId() != null) {
                company.setLogo(fileRepository.findById(company.getLogo().getId()).orElse(null));
            }
            Company savedCompany = companyRepository.findById(id).get();
            Company updatedCompany = companyRepository.saveAndFlush(companyMapper.updateCompany(savedCompany, company));
            em.refresh(updatedCompany);
            return updatedCompany;
        } else throw new CustomException("Not found", HttpStatus.NOT_FOUND);
    }

}
