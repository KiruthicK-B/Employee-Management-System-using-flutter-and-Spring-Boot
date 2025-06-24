package ems.employeemanagement.repository;

import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.JpaRepository;

import ems.employeemanagement.entity.UserEntity;

import java.util.Optional;

public interface Employee_Interface extends JpaRepository<UserEntity,Long>{
        Optional <UserEntity> findByEmployee_Name (String Username);
}
