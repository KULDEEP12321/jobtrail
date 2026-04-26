package com.kuldeep.jobtrail;

import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataSeeder {

    @Bean
    CommandLineRunner seedJobApplications(JobApplicationRepository repository) {
        return args -> {
            if (repository.count() > 0) return;
            repository.saveAll(List.of(
                new JobApplication(null, "Google", "SWE",              Status.APPLIED),
                new JobApplication(null, "Meta",   "SWE",              Status.INTERVIEWING),
                new JobApplication(null, "Amazon", "Backend Engineer", Status.SAVED)
            ));
        };
    }
}
