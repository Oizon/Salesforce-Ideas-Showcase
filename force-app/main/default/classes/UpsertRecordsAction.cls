public with sharing class UpsertRecordsAction {
    /**
     * This method extends upsert to invocable context.
     * When this was made upsert was not avilable for flow or other declarative actions. 
     * @param request a list of UpsertRequest including a required List<Sobject> to upsert, external Id Field, and requested access level.
     * @return a list of UpsertResults including the list of upserted records and the first or single record upserted. 
     */
    @InvocableMethod(
        label='Upsert Records'
        description ='Updates existing records (or inserts them if they do not exist).'
        category= 'Custom Action')
    public static List<UpsertResults> upsertRecord(List<UpsertRequest> request){
        List<SObject> records = new List<SObject>();
        String externalIdFieldName;
        AccessLevel accessMode = AccessLevel.USER_MODE;

        for(UpsertRequest req: request){
            externalIdFieldName = req.externalIDField;
            if(req.systemMode == true){
                accessMode = AccessLevel.SYSTEM_MODE;
            }
            records.addAll(req.records);
        }

        List<UpsertResults> results = new List<UpsertResults>();
        UpsertResults res = new UpsertResults();

        Schema.SObjectType sObjectType = records.get(0).getSObjectType();
        SObjectField externalIDField = getUpsertKeyField(sObjectType, externalIdFieldName);
        if(sObjectType != null){
            List<SObject> castRecords = (List<SObject>)Type.forName('List<' + sObjectType + '>').newInstance();
            castRecords.addAll(records);
            if(externalIDField == null){
                Database.upsert(castRecords, accessMode);
            }else{
                Database.upsert(castRecords, externalIDField, accessMode);
            }
            res.results = castRecords;
            res.result = castRecords[0];
            results.add(res);
        }
        return results;
    }
    //Gets the API name of the indicated field.
    private static SObjectField getUpsertKeyField(Schema.SObjectType objectType, string fieldName){
        if(String.isBlank(fieldName)){
            return null;
        }
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        return objectFields.get(fieldName);
    }
    public class UpsertRequest{
        @InvocableVariable(label='Records to Upsert' required=true)
        public List<SObject> records;
        @InvocableVariable(label='External ID Field (Optional)')
        public String externalIDField;
        @InvocableVariable(label='Upsert as System? (Optional)')
        public Boolean systemMode;
    }
    public class UpsertResults{
        @InvocableVariable(label='Upserted Records')
        public List<SObject> results;
        @InvocableVariable(label='First or Single Upserted Record')
        public SObject result;
    }
}