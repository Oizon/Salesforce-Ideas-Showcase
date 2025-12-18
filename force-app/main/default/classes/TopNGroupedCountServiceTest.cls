@isTest
public with sharing class TopNGroupedCountServiceTest {
    @isTest
    static void testNormalRun() {
        List<TopNGroupedCountService.Input> inputs = new List<TopNGroupedCountService.Input>();
        TopNGroupedCountService.Input input = new TopNGroupedCountService.Input();
        input.sObjectApiName = 'Account';
        input.groupByFieldApiName = 'Name';
        inputs.add(input);
        List<TopNGroupedCountService.TopNGroupedCountResponse> topAccountName = TopNGroupedCountService.getTopN(inputs);
        Assert.areEqual(topAccountName[0].rowValue[0].groupValue , 'Test Account', 'Should return the correct account name');
    }
    @isTest
    static void testEmptyInputs() {
        List<TopNGroupedCountService.Input> inputs = new List<TopNGroupedCountService.Input>();
        try {
            List<TopNGroupedCountService.TopNGroupedCountResponse> topAccountName = TopNGroupedCountService.getTopN(inputs);
        } catch (IllegalArgumentException e) {
            Assert.isTrue(true, 'Expected IllegalArguementException to be thrown for empty inputs');
        } catch (Exception e) {
            Assert.isTrue(false, 'Expected IllegalArguementException to be thrown for empty inputs');
        }        
    }
    @isTest
    static void testTooManyInputs() {
        List<TopNGroupedCountService.Input> inputs = new List<TopNGroupedCountService.Input>();
        for(Integer i = 0; i < 101; i++) {
            TopNGroupedCountService.Input input = new TopNGroupedCountService.Input();
            input.sObjectApiName = 'Account';
            input.groupByFieldApiName = 'Name';
            inputs.add(input);
        }
        try {
            List<TopNGroupedCountService.TopNGroupedCountResponse> topAccountName = TopNGroupedCountService.getTopN(inputs);
        } catch (IllegalArgumentException e) {
            Assert.isTrue(true, 'Expected IllegalArguementException to be thrown for empty inputs');
        } catch (Exception e) {
            Assert.isTrue(false, 'Expected IllegalArguementException to be thrown for too many inputs');
        }
    }
    @isTest
    static void testWithConditions() {
        List<TopNGroupedCountService.Input> inputs = new List<TopNGroupedCountService.Input>();
        TopNGroupedCountService.Input input = new TopNGroupedCountService.Input();
        input.sObjectApiName = 'Account';
        input.groupByFieldApiName = 'Name';
        input.filterFieldApiName = 'Name';
        input.filterValue = 'Test Account';
        input.additionalWhereClause = 'Name = \'Test Account\'';
        inputs.add(input);
        List<TopNGroupedCountService.TopNGroupedCountResponse> topAccountName = TopNGroupedCountService.getTopN(inputs);
        Assert.areEqual(topAccountName[0].rowValue[0].groupValue , 'Test Account', 'Should return the correct account name');
    }
    @isTest
    static void testWithOnlyAdditionalCondition() {
        List<TopNGroupedCountService.Input> inputs = new List<TopNGroupedCountService.Input>();
        TopNGroupedCountService.Input input = new TopNGroupedCountService.Input();
        input.sObjectApiName = 'Account';
        input.groupByFieldApiName = 'Name';
        input.additionalWhereClause = 'Name = \'Test Account\'';
        inputs.add(input);
        List<TopNGroupedCountService.TopNGroupedCountResponse> topAccountName = TopNGroupedCountService.getTopN(inputs);
        Assert.areEqual(topAccountName[0].rowValue[0].groupValue , 'Test Account', 'Should return the correct account name');
    }
    @TestSetup()
    static void makeData() {
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
    }
}