package ems.employeemanagement.customuserdetails;

import ems.employeemanagement.entity.UserEntity;
import ems.employeemanagement.repository.Employee_Interface;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

public class CustomUserDetails implements UserDetailsService {


    private Employee_Interface employeeInterface;
  //  private String Username;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        //we have to fetch the users from db
        UserEntity user = employeeInterface.findByEmployee_Name(username).orElseThrow(()-> new UsernameNotFoundException("User with this name not found"));

       return  new User(user.getEmployee_Name(),user.getEmployee_password(),null) ;
    }
}
