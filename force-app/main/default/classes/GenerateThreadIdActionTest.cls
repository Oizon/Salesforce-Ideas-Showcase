@isTest
public with sharing class GenerateThreadIdActionTest {
    @isTest
    public static void testWithFakeCaseId() {
        List<Id> caseIds = new List<Id>();
        Id caseId = Id.valueOf('500xx000000bpkTAAQ');
        caseIds.add(caseId);
        List<GenerateThreadIdAction.ThreadIdResults> results = GenerateThreadIdAction.getThreadIdForCase(caseIds);
        GenerateThreadIdAction.ThreadIdResults result = results[0];
        Assert.areEqual(true, result.threadId.startsWith('thread::'), 'Thread Id is expected to start with "thread::".');
        Assert.areEqual(true, result.threadId.endsWith('::'), 'Thread Id is expected to end with "::".');
    }
}