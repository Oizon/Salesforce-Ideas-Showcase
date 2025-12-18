public with sharing class TopNGroupedCountRow {
    @AuraEnabled
    public String groupValue;

    @AuraEnabled
    public Integer recordCount;

    public TopNGroupedCountRow() {
        //Default Constructor
    }
}