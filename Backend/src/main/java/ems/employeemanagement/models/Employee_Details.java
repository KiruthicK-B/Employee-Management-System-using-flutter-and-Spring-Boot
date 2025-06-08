package ems.employeemanagement.models;

public class Employee_Details {
    private long Employee_ID;
    private String Employee_Name;
    private String Employee_Email;
    private int Employee_Age;
    private String Employee_Dept;
    private long Employee_Salary;
    public long getEmployee_ID() {
        return Employee_ID;
    }
    public Employee_Details() {
        super();
    }
    public void setEmployee_ID(long employee_ID) {
        Employee_ID = employee_ID;
    }
   
    public String getEmployee_Name() {
        return Employee_Name;
    }
    public void setEmployee_Name(String employee_Name) {
        Employee_Name = employee_Name;
    }
    public String getEmployee_Email() {
        return Employee_Email;
    }
    public void setEmployee_Email(String employee_Email) {
        Employee_Email = employee_Email;
    }
    public int getEmployee_Age() {
        return Employee_Age;
    }
    public void setEmployee_Age(int employee_Age) {
        Employee_Age = employee_Age;
    }
    public String getEmployee_Dept() {
        return Employee_Dept;
    }
    public Employee_Details(long employee_ID, String employee_Name, String employee_Email, int employee_Age,
            String employee_Dept, long employee_Salary) {
        Employee_ID = employee_ID;
        Employee_Name = employee_Name;
        Employee_Email = employee_Email;
        Employee_Age = employee_Age;
        Employee_Dept = employee_Dept;
        Employee_Salary = employee_Salary;
    }
    public void setEmployee_Dept(String employee_Dept) {
        Employee_Dept = employee_Dept;
    }
    public long getEmployee_Salary() {
        return Employee_Salary;
    }
    public void setEmployee_Salary(long employee_Salary) {
        Employee_Salary = employee_Salary;
    } 
}
