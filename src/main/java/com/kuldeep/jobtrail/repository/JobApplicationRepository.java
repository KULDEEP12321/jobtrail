package com.kuldeep.jobtrail.repository;

import com.kuldeep.jobtrail.entity.JobApplication;
import org.springframework.data.jpa.repository.JpaRepository;

public interface JobApplicationRepository extends JpaRepository<JobApplication, Long> {
}
