@isTest
public with sharing class SendAssessmentFormPDFActionTest {
    @isTest
    public static void testSendEmailCorrectly() {
        List<SendAssessmentFormPDFAction.FormsAndRecipients> inputDataList = new List<SendAssessmentFormPDFAction.FormsAndRecipients>();
        SendAssessmentFormPDFAction.FormsAndRecipients request = new SendAssessmentFormPDFAction.FormsAndRecipients();
        Id participantId = [SELECT Id FROM Contact WHERE LastName = '1'].Id;
        List<String> recipents = new List<String>();
        recipents.add('test@mail.fake');
        request.recipients = recipents;
        request.subject = 'Test Mail Subject';
        request.body = 'Test Mail Body';
        List<Assessment_Form__c> formList = [SELECT Participant__c, Id, RecordTypeId FROM Assessment_Form__c WHERE Participant__c = :participantId];
        request.assessmentForms = formList;
        inputDataList.add(request);

        Test.startTest();
        SendAssessmentFormPDFAction.generatePDFAndSendMail(inputDataList);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.areEqual(1, emailInvocations, 'An email should be sent: Email Invocations: '+ emailInvocations);
    }
    @isTest
    public static void testWithoutForms(){
        List<SendAssessmentFormPDFAction.FormsAndRecipients> inputDataList = new List<SendAssessmentFormPDFAction.FormsAndRecipients>();
        SendAssessmentFormPDFAction.FormsAndRecipients request = new SendAssessmentFormPDFAction.FormsAndRecipients();
        List<String> recipents = new List<String>();
        recipents.add('test@mail.fake');
        request.recipients = recipents;
        request.subject = 'Test Mail Subject';
        request.body = 'Test Mail Body';
        List<Assessment_Form__c> formList = [SELECT Participant__c, Id, RecordTypeId FROM Assessment_Form__c WHERE Participant__c = :request.whatId];
        request.assessmentForms = formList;
        inputDataList.add(request);

        Test.startTest();
        SendAssessmentFormPDFAction.generatePDFAndSendMail(inputDataList);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.areEqual(0, emailInvocations, 'An email should not be sent');
    }
    @TestSetup
    static void makeData(){
        List<Contact> cons = new List<Contact>();
        List<Assessment_Form__c> forms = new List<Assessment_Form__c>();
        Id standardNonWarriorRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard Non Warrior').getRecordTypeId();
        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId()
        );
        insert acc;
        for(Integer i = 0; i <= 2; i++){
            cons.add(
                new Contact(
                    FirstName = 'Test',
                    LastName = String.valueOf(i),
                    RecordTypeId = standardNonWarriorRecordType,
                    Email = i + '@test.forms',
                    AccountId = acc.Id
            ));
        }
        insert cons;
        List<Assessment_Form__c> formList = new List<Assessment_Form__c>();
        Map<String, Id> formRecTypeByName = new Map<String, Id>();
        for(RecordType rec: [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Assessment_Form__c']){
            formRecTypeByName.put(rec.Name, rec.Id);
        }
        Id participantId = [SELECT Id FROM Contact WHERE LastName = '1'].Id;
        for(Integer i = 0; i < 200; i++){
            Assessment_Form__c form = new Assessment_Form__c();
            form.RecordTypeId = formRecTypeByName.get('CSSR-S');
            form.Participant__c = participantId;
            formList.add(form);
        }
        insert formList;
    }
}