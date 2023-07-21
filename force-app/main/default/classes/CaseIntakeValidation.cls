/* Apex Trigger: PreventCaseCreation
 * 
 * Description:
 * This trigger prevents the creation of a Case if the user does not have a certain profile
 * and a Task titled "Intake" is not connected to the related Contact record.
 * 
 * Trigger Events:
  * This trigger runs before the Case records are inserted (before insert, before update).
 * 
 * Assumptions and Limitations:
 * - The API names of the objects (Case, Contact, and Task) should match the code.
 * - The profile that is allowed to create the Case should be specified by name in the trigger code.
 * - The Task with the title "Intake" should exist on the related Contact for the Case to be created.
 * 
 * Example Usage:
 * - If a user without the allowed profile tries to create a Case, an error is thrown.
 * - If a user with the allowed profile tries to create a Case, but the related Contact does not have a Task titled "Intake", an error is thrown.
 * - If a user with the allowed profile tries to create a Case, and the related Contact has a Task titled "Intake", the Case is created successfully.
 */
              
public with sharing class CaseIntakeValidation {
    public static void validateCase(List<Case> newCases) {
        // Set of allowed profile names
        Set<String> allowedProfileNames = new Set<String>();
        allowedProfileNames.add('System Administrator');
        allowedProfileNames.add('Salesforce API Only System Integrations');

        // Set of allowed profile IDs
        Set<Id> allowedProfileIds = new Set<Id>();
        for(Profile profile : [
            SELECT Id
            FROM Profile
            WHERE Name IN :allowedProfileNames
            WITH SECURITY_ENFORCED
        ]){
            allowedProfileIds.add(profile.Id);
        }
        // Set of valid subject options for Tasks
        Set<String> validSubjectOptions = new Set<String>{
            'Completed Intake, Declined Columbia',
            'Completed Intake'
        };
        // Set of Contact IDs from new Cases
        Set<Id> contactIds = new Set<Id>();
        for(Case newCase : newCases){
            contactIds.add(newCase.ContactId);
        }
        // Set of valid Contact IDs with Tasks having valid subject options
        Set<Id> validContactIds = new Set<Id>();

        for(Task task: [SELECT Id, Subject, WhatId, WhoId 
                        FROM Task 
                        WHERE WhoId IN (
                            SELECT Id
                            FROM Contact
                            WHERE Id IN :contactIds
                        ) 
                        AND Subject IN :validSubjectOptions
                        WITH SECURITY_ENFORCED]){
            validContactIds.add(task.WhoId);
        }
    
    for (Case newCase: newCases){
        // Check if the user has an allowed profile, is not a partner user, and the related contact has an Intake completed
        if(!allowedProfileIds.contains(UserInfo.getProfileId()) &&
            newCase.RecordTypeId != Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IT_Support_Cases').getRecordTypeId() &&
            UserInfo.getUserType() != 'Partner' &&
            !validContactIds.contains(newCase.ContactId)){
                newCase.addError('The related contact must have an Intake completed to create or edit a case.');
            }
        }
    }
}