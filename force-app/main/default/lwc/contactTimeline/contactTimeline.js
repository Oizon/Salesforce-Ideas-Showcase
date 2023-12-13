import { LightningElement, wire , api } from 'lwc';
import CREATED_DATE from '@salesforce/schema/EventLog__c.CreatedDate';
import { refreshApex } from '@salesforce/apex';
import EVENT_NAME_TRIG from '@salesforce/schema/EventLog__c.EventNameTrig__c';
import getEventsList from '@salesforce/apex/EventLogUtility.getEventsList';
const COLUMNS = [
    {
        label: 'Date', 
        fieldName: CREATED_DATE.fieldApiName, 
        type: 'date', 
        typeAttributes: {
            month: "short", 
            day: "2-digit", 
            year: "numeric", 
            hour: "2-digit", 
            minute: "2-digit"},
        editable: false 
    },
    { 
        label: 'Event', 
        fieldName: EVENT_NAME_TRIG.fieldApiName, 
        type: 'text',
        editable: false  
    }
];
export default class ContactTimeline extends LightningElement {
    @api recordId;
    records;
    icon = "utility:refresh";
    columns = COLUMNS;
    @wire(getEventsList, {contactId: '$recordId'})
    records;
    async handleClick(){
        this.icon = "utility:sync";
        await refreshApex(this.records);
        this.icon = "utility:refresh";
    }
}