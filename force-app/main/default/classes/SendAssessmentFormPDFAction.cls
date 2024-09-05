public with sharing class SendAssessmentFormPDFAction {
    @InvocableMethod(label='Send Assessment Forms as PDF' description='Send a email with all inputted assessment forms.')
    public static void generatePDFAndSendMail(List<FormsAndRecipients> inputDataList) {
        List<Messaging.SingleEmailMessage> emailMessages = New List<Messaging.SingleEmailMessage>();
        Map<Id, RecordType> assessmentFormRecordType = new Map<Id, RecordType> ([SELECT Id, Name FROM RecordType WHERE SobjectType = 'Assessment_Form__c']);
        for(FormsAndRecipients data: inputDataList){
            if(data.assessmentForms.size() == 0 ){
                continue;
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(data.recipients);
            mail.setSubject(data.subject);
            mail.setHtmlBody(data.body);
            mail.setWhatId(data.whatId);
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            for(Assessment_Form__c form: data.assessmentForms){
                String recordTypeName = assessmentFormRecordType.get(form.RecordTypeId).Name;
                attachments.add(generatedPDF(form.Id, recordTypeName));
            }
            mail.setFileAttachments(attachments);
            emailMessages.add(mail);
        }
        if(emailMessages.size() > 0){
            Messaging.sendEmail(emailMessages);
        }
    }
    private static Messaging.EmailFileAttachment generatedPDF(String recordId, String recordTypeName){
        PageReference assessmentFormPDF = new PageReference('/apex/assessmentFormPDFGenerator?id=' + recordId);
        Blob pdfBlob;
        if(Test.isRunningTest()){
            pdfBlob = blob.valueOf('Unit.Test');
        }else{
            pdfBlob = assessmentFormPDF.getContentAsPDF();
        }
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(recordTypeName + '.pdf');
        attachment.setBody(pdfBlob);
        return attachment;
    }

    public class FormsAndRecipients {
        @InvocableVariable(label='Assessment Forms Collection')
        public List<Assessment_Form__c> assessmentForms;
    
        @InvocableVariable(label='Recipients' description='' required=true)
        public List<String> recipients;

        @InvocableVariable(label='Email Subject' required=true)
        public String subject;

        @InvocableVariable(label='Email Body' description='Can be a text template' required=true)
        public String body;

        @InvocableVariable(label='WhatId' description='Id to log the email on.')
        public String whatId;
    }
}