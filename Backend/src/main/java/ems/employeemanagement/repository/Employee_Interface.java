package ems.employeemanagement.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import ems.employeemanagement.entity.UserEntity;

public interface Employee_Interface extends JpaRepository<UserEntity,Long>{

}
