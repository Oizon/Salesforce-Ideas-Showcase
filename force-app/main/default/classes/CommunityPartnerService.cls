/* Author: William Galinat
 * Description: This class retrieves the community partners using SOQL to be used on the map.
 * Last Update: 20230707 by William Galinat
 */

public without sharing class CommunityPartnerService {

    @AuraEnabled(cacheable=true)

    public static List<Account> getRecords(){
        try {
            //Create a list of community partner accounts from a SOQL Query
            List<Account> partners = [
                SELECT 
                Id,
                Name,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                Mission_Statement__c
                FROM Account
                WHERE 
                Working_with_The_Network__c = 'Yes' AND 
                RecordType.Name = 'Community Partner' AND 
                BillingPostalCode != null 
                ORDER BY CreatedDate DESC
            ];
            return partners;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}