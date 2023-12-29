@isTest
public with sharing class UpsertRecordsActionTest {
    
    @isTest
    private static void testDefaultBehavior() {
        
        List<UpsertRecordsAction.UpsertRequest> requests = new List<UpsertRecordsAction.UpsertRequest>();
        UpsertRecordsAction.UpsertRequest ur = new UpsertRecordsAction.UpsertRequest();
        Id organizationRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        List<Account> accounts = new List<Account>();
        
        for(Integer i = 0; i < 2; i++){
            accounts.add(new Account(
                Name = 'Clone Factory ' + i, 
                RecordTypeId = organizationRecordType, 
                Working_with_The_Network__c = 'No')
            );
        }

        ur.records = accounts;
        requests.add(ur);

        List<UpsertRecordsAction.UpsertResults> results = UpsertRecordsAction.upsertRecord(requests);

        System.assert(results != null, 'Upsert Results should not be null.');
        System.assertEquals(2, results[0].results.size(), 'Result collection should contain 2 items.');
        System.assertEquals('Clone Factory 0', ((Account)results[0].result).Name, 'First index item should be here.');
    }
    @isTest
    private static void testUpsertUsingAsSystem() {
        List<UpsertRecordsAction.UpsertRequest> requests = new List<UpsertRecordsAction.UpsertRequest>();
        UpsertRecordsAction.UpsertRequest ur = new UpsertRecordsAction.UpsertRequest();
        List<Lead> leads = new List<Lead>();

        for(Integer i = 0; i < 2; i++){
            leads.add(new Lead(
                FirstName = 'Clone',
                LastName = String.valueOf(i),
                Company = 'Evil Empire', 
                Status = 'Open - Not Contacted')
            );
        }

        ur.records = leads;
        ur.systemMode = true;
        requests.add(ur);

        List<UpsertRecordsAction.UpsertResults> results = UpsertRecordsAction.upsertRecord(requests);

        System.assert(results != null, 'Upsert Results should not be null.');
        System.assertEquals(2, results[0].results.size(), 'Result collection should contain 2 items.');
        System.assertEquals('0', ((Lead)results[0].result).LastName, 'First index item should be here.');
    }
    @isTest
    private static void testUpsertUsingExternalIdKey(){
        List<UpsertRecordsAction.UpsertRequest> requests = new List<UpsertRecordsAction.UpsertRequest>();
        UpsertRecordsAction.UpsertRequest ur = new UpsertRecordsAction.UpsertRequest();
        List<Contact> cons = new List<Contact>();
        Id standardNonWarriorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard Non Warrior').getRecordTypeId();
        Id organizationRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();

        Account acc = new Account(
            Name = 'Clone Factory 1', 
            RecordTypeId = organizationRecordType, 
            Working_with_The_Network__c = 'No'
            );
        insert acc;
        Contact con = new Contact(
            FirstName = 'Clone',
            LastName = '1',
            RecordTypeId = standardNonWarriorRecordType,
            Email = '1@clone.space',
            warrior_serve__External_System_ID__c = '1231',
            AccountId = acc.Id
            );
        insert con;
        for(Integer i = 0; i < 2; i++){
            cons.add(new Contact(
                FirstName = 'Clone',
                LastName = String.valueOf(i),
                RecordTypeId = standardNonWarriorRecordType,
                Email = i + '@clone.space',
                warrior_serve__External_System_ID__c = '123' + i,
                AccountId = acc.Id
                ));
        }
        
        ur.records = cons;
        ur.externalIDField = 'warrior_serve__External_System_ID__c';
        requests.add(ur);

        List<UpsertRecordsAction.UpsertResults> results = UpsertRecordsAction.upsertRecord(requests);
        List<Contact> resultCheck = [SELECT Id FROM Contact];

        System.assert(results != null, 'Upsert Results should not be null.');
        System.assertEquals(2, results[0].results.size(), 'Result collection should contain 2 items.');
        System.assertEquals('0', ((Contact)results[0].result).LastName, 'First index item should be here.');
        System.assertEquals(2, resultCheck.size(), 'Only two contacts should exist.');
    }
}