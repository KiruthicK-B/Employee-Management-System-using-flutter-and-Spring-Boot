package ems.employeemanagement.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.transaction.support.ResourceTransactionManager;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@ResponseBody
public class Home_controller {


    @GetMapping("/home")
    public String HomePage(){
        return "Wolcom to Home page";
    }

    @GetMapping("/dashboard")
    public String dashboard(){return "Login successfull";}
}
