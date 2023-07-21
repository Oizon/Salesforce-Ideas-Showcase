import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CONTACT_RECORDTYPE_FIELD from '@salesforce/schema/Contact.RecordType.Name';

// Fields to retrieve from the Contact record
const FIELDS = ['Contact.Phone', 'Contact.MobilePhone', 
                'Contact.Email', 'Contact.MailingStreet', 
                'Contact.warrior_serve__Service_Record_Count__c', 
                'Contact.warrior_serve__Has_QOL__c',
                'Contact.MailingPostalCode',
                'Contact.MailingCity',
                'Contact.MailingState',
                CONTACT_RECORDTYPE_FIELD];

export default class ContactPhoneNumber extends LightningElement {
    @api recordId;
    contactRecord;
    missingDetails = '';
    score = 0;
    isContactDetailsComplete = false;
    recordTypeName = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.contactRecord = data;
            this.recordTypeName = data.fields.RecordType.value.fields.Name.value;
            this.calculateMissingDetails();
        } else if (error) {
            console.error('Error loading contact record', error);
        }
    }

    calculateMissingDetails() {
        this.isContactDetailsComplete = true;// Assume all details are complete
        this.score = 100;
        this.missingDetails ='';
        if(this.recordTypeName === 'Warrior'){
            if (!this.contactRecord.fields.warrior_serve__Has_QOL__c.value) {
                this.missingDetails += ' QOL Survey,';
                this.isContactDetailsComplete = false;
                this.score -= 20;
            }
            if (this.contactRecord.fields.warrior_serve__Service_Record_Count__c.value === 0) {
                this.missingDetails += ' Service Dates,';
                this.isContactDetailsComplete = false;
                this.score -= 20;
            }
        }
        if (!this.contactRecord.fields.Phone.value) {
            this.missingDetails += ' Phone,';
            this.isContactDetailsComplete = false;
            if(this.recordTypeName === 'Warrior'){
                this.score -= 10;
            }else{
                this.score -= 25;
            }
        }
        if (!this.contactRecord.fields.MobilePhone.value) {
            this.missingDetails += ' Mobile Phone,';
            this.isContactDetailsComplete = false;
            if(this.recordTypeName === 'Warrior'){
                this.score -= 10;
            }else{
                this.score -= 25;
            }
        }
        if (!this.contactRecord.fields.Email.value) {
            this.missingDetails += ' Email,';
            this.isContactDetailsComplete = false;
            if(this.recordTypeName === 'Warrior'){
                this.score -= 20;
            }else{
                this.score -= 25;
            }
        }
        if (!this.contactRecord.fields.MailingStreet.value || 
            !this.contactRecord.fields.MailingPostalCode.value ||
            !this.contactRecord.fields.MailingCity.value ||
            !this.contactRecord.fields.MailingState.value) {
            this.missingDetails += ' Complete Address,';
            this.isContactDetailsComplete = false;
            if(this.recordTypeName === 'Warrior'){
                this.score -= 20;
            }else{
                this.score -= 25;
            }
        }
        this.missingDetails = this.missingDetails.substring(0, this.missingDetails.length -1);
    }
}