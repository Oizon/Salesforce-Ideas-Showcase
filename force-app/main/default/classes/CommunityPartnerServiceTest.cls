@isTest
private class CommunityPartnerServiceTest {

    @isTest
    private static void testGetRecords() {
        //Create test Data
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i<5; i++){
            Account acc = new Account(
                Name = 'Test Account ' + i,
                BillingStreet = 'Test Street ' +i,
                BillingCity = 'Test City ' + i,
                BillingState = 'Test State ' + i,
                BillingPostalCode = 'Test Postal Code ' + i,
                Working_with_The_Network__c = 'Yes',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community Partner').getRecordTypeId()
            );
            testAccounts.add(acc);
        }
        insert testAccounts;

        Test.startTest();

        //Call the method to be tested
        List<Account> results = CommunityPartnerService.getRecords();

        Test.stopTest();

        //Assert the results
        Assert.areEqual(5, results.size(),'Incorrect number of records retrieved');

        for (Integer i = 0; i < 5; i++) {
            Account acc = results[i];
            System.assertEquals('Test Account ' + i, acc.Name, 'Incorrect account name');
            Assert.areEqual('Test Street ' + i, acc.BillingStreet, 'Incorrect billing street');
            Assert.areEqual('Test City ' + i, acc.BillingCity, 'Incorrect billing city');
            Assert.areEqual('Test State ' + i, acc.BillingState, 'Incorrect billing state');
            Assert.areEqual('Test Postal Code ' + i, acc.BillingPostalCode, 'Incorrect billing postal code');
        }
    }
}