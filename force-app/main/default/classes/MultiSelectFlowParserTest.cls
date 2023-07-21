@isTest
public class MultiSelectFlowParserTest {
    
    @isTest
    static void testCheckValues(){
        List<String> inputList = new List<String>{'Option 1;Option 2;Option 3'};
        List<List<String>> expectedOutput = new List<List<String>>{
            new List<String>{'Option 1', 'Option 2', 'Option 3'}
        };
        
        // Test case 1: Valid multi-select picklist values
        List<List<String>> actualOutput = MultiSelectFlowParser.CheckValues(inputList);
        System.assertEquals(expectedOutput, actualOutput, 'Test case 1 failed');
        
        // Test case 2: Empty multi-select picklist values
        inputList = new List<String>();
        expectedOutput = null;
        actualOutput = MultiSelectFlowParser.CheckValues(inputList);
        System.assertEquals(expectedOutput, actualOutput, 'Test case 2 failed');    
    }
}