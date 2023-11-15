public with sharing class SetAutomaticSendDates implements Queueable {
    
    List<Contact> incomingList;
    Date incomingDate;
    
    //Constructor to Set the Parameters
    public SetAutomaticSendDates(List<Contact> contactGroup, Date dateToSet) {    
        incomingList = contactGroup;
        incomingDate = dateToSet;
    }

    public void execute(QueueableContext context){
        List<Contact> nextBatch = new List<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Integer> indexToRemove = new List<Integer>();
        Integer counter = 0;
        for(Contact con: incomingList){
            if(counter >= 100){
                break;
            }else {
                con.Automated_Missing_Information_Send_On__c = incomingDate;
                contactsToUpdate.add(con);
                indexToRemove.add(counter);
                counter++;
            }
        }
        for(Contact con : contactsToUpdate){
            incomingList.remove(incomingList.indexOf(con));
        }
        System.debug(incomingList);
        System.debug(contactsToUpdate);
        update contactsToUpdate;
        if(!incomingList.isEmpty()){
            SetAutomaticSendDates updateDateJob = new SetAutomaticSendDates(incomingList, incomingDate);
            System.enqueueJob(updateDateJob);
        }
    }
}

/* to enque a job run a SOQL query getting at least the Id and Automatic QOL Send On date 
where the send date is null....
then pass that List and Date into the method with however many records you want to have updated.
Below apex anon will do roughly 7000 records at a time.

Date startDate = Date.newInstance(2024, 1, 1);
List<Contact> contactsList1 = [SELECT Id, Automated_Missing_Information_Send_On__c
                         FROM Contact
                         WHERE Automated_Missing_Information_Send_On__c = null
                         LIMIT 1000];
List<Contact> contactsList2 = [SELECT Id, Automated_Missing_Information_Send_On__c
                         FROM Contact
                         WHERE Automated_Missing_Information_Send_On__c = null AND
                               Id not in:contactsList1
                         LIMIT 1000];
List<Contact> contactsList3 = [SELECT Id, Automated_Missing_Information_Send_On__c
                         FROM Contact
                         WHERE Automated_Missing_Information_Send_On__c = null AND
                               Id not in:contactsList2 AND
                               Id not in:contactsList1
                         LIMIT 1000];
List<Contact> contactsList4 = [SELECT Id, Automated_Missing_Information_Send_On__c
                         FROM Contact
                         WHERE Automated_Missing_Information_Send_On__c = null AND
                               Id not in:contactsList3 AND
                               Id not in:contactsList1 AND
                               Id not in:contactsList2
                         LIMIT 1000];
List<Contact> contactsList5 = [SELECT Id, Automated_Missing_Information_Send_On__c
                         FROM Contact
                         WHERE Automated_Missing_Information_Send_On__c = null AND
                               Id not in:contactsList4 AND
                               Id not in:contactsList1 AND
                               Id not in:contactsList2 AND
                               Id not in:contactsList3
                         LIMIT 1000];
List<Contact> contactsList6 = [SELECT Id, Automated_Missing_Information_Send_On__c
                         FROM Contact
                         WHERE Automated_Missing_Information_Send_On__c = null AND
                               Id not in:contactsList5 AND
                               Id not in:contactsList1 AND
                               Id not in:contactsList2 AND
                               Id not in:contactsList3 AND
                               Id not in:contactsList4
                         LIMIT 1000];
List<Contact> contactsList7 = [SELECT Id, Automated_Missing_Information_Send_On__c
                         FROM Contact
                         WHERE Automated_Missing_Information_Send_On__c = null AND
                               Id not in:contactsList6 AND
                               Id not in:contactsList1 AND
                               Id not in:contactsList2 AND
                               Id not in:contactsList3 AND
                               Id not in:contactsList4 AND
                               Id not in:contactsList5
                         LIMIT 1000];
if(!contactsList1.isEmpty()){
	Date dateToSet = startDate;
	SetAutomaticSendDates updateJob = new SetAutomaticSendDates(contactsList1 , dateToSet);
	System.enqueueJob(updateJob);
}
if(!contactsList2.isEmpty()){
	Date dateToSet = startDate + 1; 
	SetAutomaticSendDates updateJob = new SetAutomaticSendDates(contactsList2 , dateToSet);
	System.enqueueJob(updateJob);
}
if(!contactsList3.isEmpty()){
	Date dateToSet = startDate +2; 
	SetAutomaticSendDates updateJob = new SetAutomaticSendDates(contactsList3 , dateToSet);
	System.enqueueJob(updateJob);
}
if(!contactsList4.isEmpty()){
	Date dateToSet = startDate +3; 
	SetAutomaticSendDates updateJob = new SetAutomaticSendDates(contactsList4 , dateToSet);
	System.enqueueJob(updateJob);
}
if(!contactsList5.isEmpty()){
	Date dateToSet = startDate + 4; 
	SetAutomaticSendDates updateJob = new SetAutomaticSendDates(contactsList5 , dateToSet);
	System.enqueueJob(updateJob);
}
if(!contactsList6.isEmpty()){
	Date dateToSet = startDate + 5; 
	SetAutomaticSendDates updateJob = new SetAutomaticSendDates(contactsList6 , dateToSet);
	System.enqueueJob(updateJob);
}
if(!contactsList7.isEmpty()){
	Date dateToSet = startDate + 6; 
	SetAutomaticSendDates updateJob = new SetAutomaticSendDates(contactsList7 , dateToSet);
	System.enqueueJob(updateJob);
}
*/
