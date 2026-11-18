@isTest
private class CarObjectTest {

    // Verify CRUD: Create, Read, Update, Delete on Car__c
    @isTest
    static void testCarCRUD() {
        // Check CRUD permissions
        Schema.DescribeSObjectResult carDescribe = Schema.SObjectType.Car__c;

        System.assert(carDescribe.isCreateable(), 'Car__c should be createable');
        System.assert(carDescribe.isAccessible(), 'Car__c should be accessible (readable)');
        System.assert(carDescribe.isUpdateable(), 'Car__c should be updateable');
        System.assert(carDescribe.isDeletable(), 'Car__c should be deletable');

        // Create
        Car__c car = new Car__c(Name = 'Test Car');
        insert car;
        System.assertNotEquals(null, car.Id, 'Car should be inserted with an Id');

        // Read
        Car__c queriedCar = [SELECT Id, Name FROM Car__c WHERE Id = :car.Id LIMIT 1];
        System.assertEquals('Test Car', queriedCar.Name, 'Car name should match');

        // Update
        queriedCar.Name = 'Updated Car';
        update queriedCar;
        Car__c updatedCar = [SELECT Id, Name FROM Car__c WHERE Id = :car.Id LIMIT 1];
        System.assertEquals('Updated Car', updatedCar.Name, 'Car name should be updated');

        // Delete
        delete updatedCar;
        List<Car__c> deletedCars = [SELECT Id FROM Car__c WHERE Id = :car.Id ALL ROWS];
        System.assertEquals(1, deletedCars.size(), 'Deleted car should be in recycle bin');
    }

    // Verify FLS: Name field is accessible and updateable
    @isTest
    static void testCarFLS() {
        Schema.DescribeFieldResult nameField = Schema.SObjectType.Car__c.fields.Name;

        System.assert(nameField.isAccessible(), 'Car__c.Name should be accessible');
        System.assert(nameField.isCreateable(), 'Car__c.Name should be createable');
        System.assert(nameField.isUpdateable(), 'Car__c.Name should be updateable');
    }

    // Verify object metadata: label, plural label, sharing model
    @isTest
    static void testCarObjectMetadata() {
        Schema.DescribeSObjectResult carDescribe = Schema.SObjectType.Car__c;

        System.assertEquals('Car', carDescribe.getLabel(), 'Car__c label should be Car');
        System.assertEquals('Cars', carDescribe.getLabelPlural(), 'Car__c plural label should be Cars');
        System.assert(carDescribe.isQueryable(), 'Car__c should be queryable');
        System.assert(carDescribe.isSearchable(), 'Car__c should be searchable');
    }
}
