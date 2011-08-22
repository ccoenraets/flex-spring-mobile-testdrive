package flex.samples.spring.util;

import java.io.File;
import java.net.URLDecoder;

import javax.sql.DataSource;
import javax.xml.parsers.DocumentBuilderFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import flex.samples.employeedirectory.Employee;
import flex.samples.spring.employeedirectory.EmployeeDAO;

/**
 * @author Christophe Coenraets
 */
@Component
public class DatabaseInitializer {

    private final JdbcTemplate template;
    
    private EmployeeDAO employeeDAO;

    @Autowired
    public DatabaseInitializer(DataSource ds, EmployeeDAO employeeDAO) {
    	this.employeeDAO = employeeDAO;
        this.template = new JdbcTemplate(ds);
        createTableEmployee();
        insertEmployees();
    }
    
    public void createTableEmployee()  {
    	System.out.println("Creating table EMPLOYEE...");
    	String sql = "CREATE TABLE IF NOT EXISTS EMPLOYEE (" +
        	"ID INT AUTO_INCREMENT PRIMARY KEY, " +
        	"FIRST_NAME VARCHAR(50), " +
        	"LAST_NAME VARCHAR(50), " + 
        	"TITLE VARCHAR(50), " + 
        	"DEPARTMENT VARCHAR(50), " + 
        	"MANAGER_ID INT, " +
        	"CITY VARCHAR(50), " + 
        	"OFFICE_PHONE VARCHAR(50), " + 
        	"CELL_PHONE VARCHAR(50), " + 
        	"EMAIL VARCHAR(50), " + 
        	"PICTURE VARCHAR(200))";
        this.template.execute(sql);
    }
    
	public void insertEmployees() {
        System.out.println("Inserting sample data in table EMPLOYEE...");
        try {
        	String filePath = URLDecoder.decode(getClass().getClassLoader().getResource("flex/samples/employeedirectory/employees.xml").getFile(), "UTF-8");;
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setValidating(false);
            Document doc = factory.newDocumentBuilder().parse(new File(filePath));
            NodeList nodes = doc.getElementsByTagName("employee");
            int length = nodes.getLength();
            Employee employee;
            Node node;
            for (int i=0; i<length; i++) {
            	node = nodes.item(i);
            	employee = new Employee();
            	employee.setId(getIntValue(node, "id"));
            	employee.setFirstName(getStringValue(node, "firstName"));
            	employee.setLastName(getStringValue(node, "lastName"));
            	employee.setTitle(getStringValue(node, "title"));
            	employee.setDepartment(getStringValue(node, "department"));
            	employee.setCity(getStringValue(node, "city"));
            	employee.setOfficePhone(getStringValue(node, "officePhone"));
            	employee.setCellPhone(getStringValue(node, "cellPhone"));
            	employee.setEmail(getStringValue(node, "email"));
            	employee.setPicture(getStringValue(node, "picture"));
            	int managerId = getIntValue(node, "managerId");
            	if (managerId>0) {
            		Employee manager = new Employee();
            		manager.setId(getIntValue(node, "managerId"));
            		employee.setManager(manager);
            	}
            	employeeDAO.create(employee);
            }
        } catch (Exception e) {
        	e.printStackTrace();
        }
	}
	
	private String getStringValue(Node node, String name) {
		return ((Element) node).getElementsByTagName(name).item(0).getFirstChild().getNodeValue();		
	}

	private int getIntValue(Node node, String name) {
		return Integer.parseInt( getStringValue(node, name) );		
	}
    
}
