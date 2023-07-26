public with sharing class PhoneFormatter {
    private static final List<String> ACCOUNT_PHONE_NUMBER_FIELDS = new List<String>{
        'phone', 
        'Contact_Phone__c', 
        'npo02__HouseholdPhone__c', 
        'npsp__Matching_Gift_Phone__c'
        //Add other phone number fields from the Account object
};
    private static final List<String> CONTACT_PHONE_NUMBER_FIELDS = new List<String>{
        'phone', 
        'AssistantPhone', 
        'MobilePhone', 
        'OtherPhone', 
        'HomePhone', 
        'warrior_serve__Emergency_Contact_Phone__c', 
        'Other_Contact_Phone_Number__c', 
        'Reference_s_Phone_Number__c', 
        'npe01__WorkPhone__c'
        //Add other phone number fields from the contact object
    };
    private static final List<String> LEAD_PHONE_NUMBER_FIELDS = new List<String>{
        'phone', 
        'MobilePhone' , 
        'Warrior_s_Home_Phone__c', 
        'Warrior_s_Mobile_Phone__c'  
        //Add other phone number fields from the lead object
    };
    
    public static void formatPhoneNumberBeforeInsert(List<Sobject> triggerDotNew) {
        for(Sobject record : triggerDotNew){
            switch on record {
                when Account a {
                setPhoneFields(record, ACCOUNT_PHONE_NUMBER_FIELDS);
                }
            when Contact c {
                setPhoneFields(record, CONTACT_PHONE_NUMBER_FIELDS);
                }
            when Lead l{
                setPhoneFields(record, LEAD_PHONE_NUMBER_FIELDS);
                }
            }
        }
    }
    public static void formatPhoneNumberBeforeUpdate(Map<Id, Sobject> triggerDotNewMap, Map<Id, Sobject> triggerDotOldMap){
        list<String> phoneNumberFields;
        for(Sobject record : triggerDotNewMap?.values()){
            Sobject oldRecord = triggerDotOldMap?.get(record.Id);
            switch on record {
                when Account a {
                    phoneNumberFields = ACCOUNT_PHONE_NUMBER_FIELDS;
                }
                when Contact c {
                    phoneNumberFields = CONTACT_PHONE_NUMBER_FIELDS;
                }
                when Lead l {
                    phoneNumberFields = LEAD_PHONE_NUMBER_FIELDS;
                }
            }
            for(String field : phoneNumberFields){
                if((String)record.get(field) != (String)oldRecord?.get(field)){
                    record.put(field, formatPhoneNumber((String)record.get(field)));
                }
            }
        }
    }


    private static void setPhoneFields (Sobject s, List<String> phoneNumberFields){
        for (String field : phoneNumberFields) {
            // Check if the field value is not null
            if (String.isNotBlank((String)s.get(field))) {
                // Format the phone number using the TriggerHelper class
                s.put(field, formatphonenumber((String)s.get(field)));
            }
        }
    }
    
    private static String formatPhoneNumber(String phone) {
        String formatted = '';
        if(phone.startsWith('+1')||phone.startsWith('1')|| phone.startsWith('1+')){
            // remove +1 from phone number and remove non-numeric characters
            formatted = phone.replaceAll('\\D','').removeStart('1');
        }else{
            // remove non-numeric characters from phone number
            formatted = phone.replaceAll('\\D','');
        }
        // check if phone number has 10 digits
        if (formatted.length() == 10 && !formatted.startsWith('0') && !formatted.startsWith('1')) {
            // format phone number
            formatted = formatNumber(formatted);
            return formatted;
        } else {
            // return original phone number if it doesn't have 10 digits
            return phone;
        }
    }
    private static String formatNumber (String s) {
        // format phone number in (xxx) xxx-xxxx format
        s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
    }
}