@isTest
public class PhoneFormatterTest {

    //Create list of fields to iterate over
    private static final List<String> CONTACT_PHONE_FIELDS = new List<String> { 
        'phone', 'AssistantPhone', 'MobilePhone', 'OtherPhone', 
        'HomePhone', 'warrior_serve__Emergency_Contact_Phone__c', 
        'Other_Contact_Phone_Number__c', 'Reference_s_Phone_Number__c', 'npe01__WorkPhone__c'};

    //Create list of fields to iterate over
    private static final List<String> LEAD_PHONE_FIELDS = new List<String> { 
        'phone', 'MobilePhone' , 'Warrior_s_Home_Phone__c', 'Warrior_s_Mobile_Phone__c'};

    //Create list of fields to iterate over
    private static final List<String> ACCOUNT_PHONE_FIELDS = new List<String> { 
        'phone', 'Contact_Phone__c', 'npo02__HouseholdPhone__c', 'npsp__Matching_Gift_Phone__c'};
    
    //Test method to test the beforeInsert method of the ContactTriggerHandler class
    @isTest
    static void testContactBeforeInsert() {
        // Create an account record to link the test contacts
        Account testAccount = new Account(name='Mars');
        //Insert the test account into the database 
        insert(testAccount);
        // Create a list of test contacts
        List<Contact> testContacts = new List<Contact> {
            new Contact(lastName='Man', firstName='Hugh',
                        phone = '+1 (555) 555-5555', AssistantPhone = '555-555-5555', 
                        MobilePhone = '(555)555-5555', AccountId=testAccount.Id),
            new Contact(lastName='Earthman', firstName='Areal',
                        phone='555+555+5555',
                        OtherPhone = '555.555.5555', HomePhone = '555 555 5555', 
                        warrior_serve__Emergency_Contact_Phone__c = '555-555-5555', AccountId=testAccount.Id)
        };

        //Insert the test contact into the database
        Test.startTest();
        insert(testContacts);
        Test.stopTest();

        //Verify that the phone numbers have been formatted correctly
        List<Contact> checkContacts = [SELECT phone, AssistantPhone, MobilePhone, OtherPhone, 
        HomePhone, warrior_serve__Emergency_Contact_Phone__c, 
        Other_Contact_Phone_Number__c, Reference_s_Phone_Number__c, npe01__WorkPhone__c FROM Contact];
        for (Contact con : checkContacts) {
            for (String field : CONTACT_PHONE_FIELDS) {
                // Iterate through each phone field in the list
                if ((String)con.get(field) != null) {
                    // Check if the field value is not null
                    String formatted = (String)con.get(field);
                    System.assertEquals('(555) 555-5555', formatted , 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
            }
        }
    }
        
    @isTest
    // Test the beforeUpdate method
    static void testContactBeforeUpdate() {
        // Create an account record to link the test contacts
        Account testAccount = new Account(name='Mars');
        insert(testAccount);
        // Create a list of test contacts
        List<Contact> testContacts = new List<Contact> {
            new Contact(lastName='Man', firstName='Hugh',
                        phone = '+1 (555) 555-5555', AssistantPhone = '555-555-5555', 
                        MobilePhone = '(555)555-5555', AccountId=testAccount.Id),
            new Contact(lastName='Earthman', firstName='Areal',
                        phone='1555+555+5555',
                        OtherPhone = '+1555.555.5555', HomePhone = '555 555 5555', 
                        warrior_serve__Emergency_Contact_Phone__c = '555-555-5555', AccountId=testAccount.Id)
        };
        //Insert the test contact into the database
        insert(testContacts);
        //Update the test contacts
        Test.startTest();
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact con : testContacts){
            con.Phone = '+1 (444) 444-4444';
            con.AssistantPhone ='444-444-4444';
            con.MobilePhone = '(444)444-4444';
            con.OtherPhone ='444.444.4444';
            con.HomePhone = '444 444 4444';
            con.warrior_serve__Emergency_Contact_Phone__c = '444+444+4444';
            contactsToUpdate.add(con);
        }
        update(contactsToUpdate);
        Test.stopTest();
        // Verify that the phone numbers have been formatted correctly
        List<Contact> checkContacts = [SELECT phone, AssistantPhone, MobilePhone, OtherPhone, 
        HomePhone, warrior_serve__Emergency_Contact_Phone__c, 
        Other_Contact_Phone_Number__c, Reference_s_Phone_Number__c, npe01__WorkPhone__c FROM Contact];
        for (Contact con : checkContacts) {
            // Iterate through each phone field in the list
            for (String field : CONTACT_PHONE_FIELDS) {
                if ((String)con.get(field) != null) {
                    // Check if the field value is not null
                    String formatted = (String)con.get(field);
                    System.assertEquals(formatted, '(444) 444-4444' , 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
            }
        }
    }
    @isTest 
    static void testLeadBeforeInsert() {
        //Create a lead record
        Lead testLead = new Lead(
            firstName ='Hugh',
            lastName = 'Man',
            phone='311,222-4444',
            MobilePhone ='311!222$4444',
            Warrior_s_Home_Phone__c = '1+311*222#4444',
            Warrior_s_Mobile_Phone__c ='1%311(222*4444',
            Company ='Earth'
        );
        //Insert the test account into the database
        test.startTest();
        database.insert(testLead);
        test.stopTest();
        //Verify that the phone numbers have been formatted correctly
        List<Lead> checkLead = [SELECT phone, MobilePhone, Warrior_s_Home_Phone__c, Warrior_s_Mobile_Phone__c 
        FROM Lead];
        for (Lead ld : checkLead) {
            for (String field : LEAD_PHONE_FIELDS) {
                // Iterate through each phone field in the list
                if ((String)ld.get(field) != null) {
                    // Check if the field value is not null
                    String formatted = (String)ld.get(field);
                    System.assertEquals('(311) 222-4444', formatted , 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
            }
        }
    }
    @isTest 
    static void testLeadBeforeUpdate() {
        //Create an lead record
        Lead testLead = new Lead(
            firstName ='Hugh',
            lastName = 'Man',
            phone='911,222-4444',
            MobilePhone ='911!222$4444',
            Warrior_s_Home_Phone__c = '911*222#4444',
            Warrior_s_Mobile_Phone__c ='%911(222*4444',
            Company ='Earth'
        );
        Database.insert(testLead);
        //Update the test lead
        Test.startTest();
        testLead.Phone = '922@333@4444';
        testLead.MobilePhone ='922&333:4444';
        testLead.Warrior_s_Home_Phone__c = '^922`333}4444';
        testLead.Warrior_s_Mobile_Phone__c ='1%%%922*333-4444';
        Database.update(testLead);
        Test.stopTest();
        //Verify that the phone numbers have been formatted correctly
        List<Lead> checkLead = [SELECT phone, MobilePhone, Warrior_s_Home_Phone__c, Warrior_s_Mobile_Phone__c 
        FROM Lead];
        for(Lead ld : checkLead){
            for (String field : LEAD_PHONE_FIELDS) {
                // Iterate through each phone field in the list
                if ((String)ld.get(field) != null) {
                    // Check if the field value is not null
                    String formatted = (String)ld.get(field);
                    System.assertEquals('(922) 333-4444', formatted , 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
            }
        }
    }
    @isTest
    static void testAccountBeforeInsert() {
        //Create an account record
        Account testAccount = new Account(
            name='Earth',
            phone='800,222-4444',
            contact_phone__c ='800!222$4444',
            npo02__HouseholdPhone__c = '800*222#4444',
            npsp__Matching_Gift_Phone__c ='%800(222*4444'
        );
        //Insert the test account into the database
        test.startTest();
        database.insert(testAccount);
        test.stopTest();
        //Verify that the phone numbers have been formatted correctly
        List<Account> checkAccount = [SELECT phone, contact_phone__c, npo02__HouseholdPhone__c, npsp__Matching_Gift_Phone__c 
        FROM Account];
        for (Account acct : checkAccount) {
            for (String field : ACCOUNT_PHONE_FIELDS) {
                // Iterate through each phone field in the list
                if ((String)acct.get(field) != null) {
                    // Check if the field value is not null
                    String formatted = (String)acct.get(field);
                    System.assertEquals('(800) 222-4444', formatted , 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
            }
        }
    }
    @isTest 
    static void testAccountBeforeUpdate() {
        //Create an account record
        Account testAccount = new Account(
            name='Earth',
            phone='999,222-4444',
            contact_phone__c ='999!222$4444',
            npo02__HouseholdPhone__c = '999*222#4444',
            npsp__Matching_Gift_Phone__c ='%999(222*4444'
        );
        Database.insert(testAccount);
        //Update the test account
        Test.startTest();
        testAccount.Phone = '888@333@4444';
        testAccount.contact_phone__c ='888&333:4444';
        testAccount.npo02__HouseholdPhone__c = '^888`333}4444';
        testAccount.npsp__Matching_Gift_Phone__c ='8%%%88*333-4444';
        Database.update(testAccount);
        Test.stopTest();
        //Verify that the phone numbers have been formatted correctly
        List<Account> checkAccount = [SELECT phone, contact_phone__c, npo02__HouseholdPhone__c, npsp__Matching_Gift_Phone__c 
        FROM Account];
        for(Account acct : checkAccount){
            for (String field : ACCOUNT_PHONE_FIELDS) {
                // Iterate through each phone field in the list
                if ((String)acct.get(field) != null) {
                    // Check if the field value is not null
                    String formatted = (String)acct.get(field);
                    System.assertEquals('(888) 333-4444', formatted , 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
            }
        }
    }
    @isTest
    static void testNegative() {
        //Create an account record
        Account testAccount = new Account(
            name='Buckingham Palace',
            phone='+44 303 1233 7300',
            contact_phone__c =''
        );
        Test.startTest();
        insert(testAccount);
        Test.stopTest();
        List<Account> checkAccount = [SELECT phone, contact_phone__c, npo02__HouseholdPhone__c, npsp__Matching_Gift_Phone__c 
        FROM Account];
        for (Account acct : checkAccount) {
            for (String field : ACCOUNT_PHONE_FIELDS) {
                // Iterate through each phone field in the list
                // Check if the field value is not null
                String formatted = (String)acct.get(field);
                if(field == 'phone'){
                    System.assertEquals('+44 303 1233 7300', formatted, 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
                if(field == 'contact_phone__c'){
                    System.assertEquals(null, formatted, 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
                if(field == 'npo02__HouseholdPhone__c'){
                    System.assertEquals(null, formatted, 'Unexpected phone number format for ' + field + ': ' + formatted);
                }
            }
        }
    }
}