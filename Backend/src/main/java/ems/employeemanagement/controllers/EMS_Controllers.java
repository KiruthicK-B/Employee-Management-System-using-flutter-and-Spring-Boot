package ems.employeemanagement.controllers;

import java.util.List;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import ems.employeemanagement.entity.UserEntity;
import ems.employeemanagement.exceptions.ResourceNotFound;
import ems.employeemanagement.repository.Employee_Interface;

@RestController
@ResponseBody
public class EMS_Controllers {
    @Autowired
    private Employee_Interface employee_Interface;
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @GetMapping("/fetch")
    public List<UserEntity> getUsers(){
        return employee_Interface.findAll();
    }

    @PostMapping("/insert")
    public UserEntity insertUser(@RequestBody UserEntity User){
        User.setEmployee_password(passwordEncoder.encode(User.getEmployee_password()));
        return employee_Interface.save(User);
    }

    @GetMapping("/find/{id}")
    public UserEntity getUserByID(@PathVariable long id){
        return employee_Interface.findById(id).orElseThrow(()-> new ResourceNotFound("User not found with this id = "+id));
    }
    
    @PutMapping("/update/{id}")
    public UserEntity updateUser(@PathVariable long id,@RequestBody UserEntity user){

        UserEntity userData = employee_Interface.findById(id).orElseThrow(()-> new ResourceNotFound("User not found with this id = "+id));
        userData.setEmployee_Name(user.getEmployee_Name());
        userData.setEmployee_Email(user.getEmployee_Email());
        userData.setEmployee_Age(user.getEmployee_Age());
        userData.setEmployee_Dept(user.getEmployee_Dept());
        userData.setEmployee_Salary(user.getEmployee_Salary());
        return employee_Interface.save(userData);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteUserById(@PathVariable long id){

        UserEntity userData = employee_Interface.findById(id).orElseThrow(()-> new ResourceNotFound("User not found with this id = "+id));
        employee_Interface.delete(userData);

        return ResponseEntity.ok().build();
    }
}
