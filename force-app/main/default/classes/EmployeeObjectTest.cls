@isTest
private class EmployeeObjectTest {

    // Verify CRUD: Create, Read, Update, Delete on Employee__c
    @isTest
    static void testEmployeeCRUD() {
        // Check CRUD permissions
        Schema.DescribeSObjectResult employeeDescribe = Schema.SObjectType.Employee__c;

        System.assert(employeeDescribe.isCreateable(), 'Employee__c should be createable');
        System.assert(employeeDescribe.isAccessible(), 'Employee__c should be accessible (readable)');
        System.assert(employeeDescribe.isUpdateable(), 'Employee__c should be updateable');
        System.assert(employeeDescribe.isDeletable(), 'Employee__c should be deletable');

        // Create
        Employee__c emp = new Employee__c(Name = 'Test Employee');
        insert emp;
        System.assertNotEquals(null, emp.Id, 'Employee should be inserted with an Id');

        // Read
        Employee__c queriedEmp = [SELECT Id, Name FROM Employee__c WHERE Id = :emp.Id LIMIT 1];
        System.assertEquals('Test Employee', queriedEmp.Name, 'Employee name should match');

        // Update
        queriedEmp.Name = 'Updated Employee';
        update queriedEmp;
        Employee__c updatedEmp = [SELECT Id, Name FROM Employee__c WHERE Id = :emp.Id LIMIT 1];
        System.assertEquals('Updated Employee', updatedEmp.Name, 'Employee name should be updated');

        // Delete
        delete updatedEmp;
        List<Employee__c> deletedEmps = [SELECT Id FROM Employee__c WHERE Id = :emp.Id ALL ROWS];
        System.assertEquals(1, deletedEmps.size(), 'Deleted employee should be in recycle bin');
    }

    // Verify FLS: Name field is accessible and updateable
    @isTest
    static void testEmployeeFLS() {
        Schema.DescribeFieldResult nameField = Schema.SObjectType.Employee__c.fields.Name;

        System.assert(nameField.isAccessible(), 'Employee__c.Name should be accessible');
        System.assert(nameField.isCreateable(), 'Employee__c.Name should be createable');
        System.assert(nameField.isUpdateable(), 'Employee__c.Name should be updateable');
    }

    // Verify object metadata: label, plural label
    @isTest
    static void testEmployeeObjectMetadata() {
        Schema.DescribeSObjectResult employeeDescribe = Schema.SObjectType.Employee__c;

        System.assertEquals('Employee', employeeDescribe.getLabel(), 'Employee__c label should be Employee');
        System.assertEquals('Employees', employeeDescribe.getLabelPlural(), 'Employee__c plural label should be Employees');
        System.assert(employeeDescribe.isQueryable(), 'Employee__c should be queryable');
    }
}
