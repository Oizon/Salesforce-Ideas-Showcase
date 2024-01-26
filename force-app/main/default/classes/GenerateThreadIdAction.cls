public with sharing class GenerateThreadIdAction {
    @InvocableMethod(
        label='Generate ThreadId for Case' 
        description='Uses the apex method EmailMessages.getFormattedThreadingToken for flows.'
        iconName='slds:standard:record_lookup'
        category='Email'
        )
    public static List<ThreadIdResults> getThreadIdForCase(List<Id> caseIds) {
        List<ThreadIdResults> results = new List<ThreadIdResults>();
        for(Id caseId: caseIds){
            ThreadIdResults result = new ThreadIdResults();
            result.threadId = EmailMessages.getFormattedThreadingToken(caseId);
            results.add(result);
        }
        return results;
    }
    public class ThreadIdResults{
        @InvocableVariable(label='ThreadId')
        public String threadId;
    }
}