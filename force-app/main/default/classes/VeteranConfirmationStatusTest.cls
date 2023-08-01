@IsTest
public class VeteranConfirmationStatusTest {

    @IsTest
    static void testMakeHTTPCallout_ValidInput() {
        // Prepare test data
        Veteran_Confirmation_Status__c customSetting = new Veteran_Confirmation_Status__c();
        customSetting.API_Key__c = 'valid_api_key';
        customSetting.Endpoint__c = 'https://sandbox-api.you.thought.you.would.find.something.useful...BUT.IT.WAS.ME.DIO!';
        insert customSetting;

        List<VeteranConfirmationStatus.FlowInputData> inputDataList = new List<VeteranConfirmationStatus.FlowInputData>();
        VeteranConfirmationStatus.FlowInputData inputData = new VeteranConfirmationStatus.FlowInputData();
        inputData.firstName = 'John';
        inputData.lastName = 'Doe';
        inputData.birthDate = '19851231';
        inputData.gender = 'M';
        inputData.streetAddressLine1 = '123 Main St';
        inputData.city = 'Anytown';
        inputData.zipCode = '12345';
        inputData.state = 'CA';
        inputData.country = 'USA';
        inputDataList.add(inputData);

        Test.setMock(HttpCalloutMock.class, new VeteranConfirmationStatusMock());

        // Make the callout
        Test.startTest();
        List<VeteranConfirmationStatus.FlowOutputData> outputDataList = VeteranConfirmationStatus.makeHTTPCallout(inputDataList);
        Test.stopTest();

        // Assert the results
        VeteranConfirmationStatus.FlowOutputData outputData = outputDataList[0];
        System.assertEquals(200, outputData.statusCode, 'Expected a status code of 200.');
        System.assertNotEquals(null, outputData.veteranStatus, 'Expected a confirmed status code.');
        System.assertEquals(null, outputData.notConfirmedReason, 'Expect this to be null as the Warrior is confirmed.');
        System.assertEquals(null, outputData.error, 'This should not have caused an error.');
    }

    @IsTest
    static void testMakeHTTPCallout_InvalidInput() {
        // Prepare test data
        Veteran_Confirmation_Status__c customSetting = new Veteran_Confirmation_Status__c();
        customSetting.API_Key__c = 'valid_api_key';
        customSetting.Endpoint__c = 'https://sandbox-api.you.thought.you.would.find.something.useful...BUT.IT.WAS.ME.DIO!';
        insert customSetting;

        List<VeteranConfirmationStatus.FlowInputData> inputDataList = new List<VeteranConfirmationStatus.FlowInputData>();
        VeteranConfirmationStatus.FlowInputData inputData = new VeteranConfirmationStatus.FlowInputData();
        inputData.firstName = '';
        inputData.lastName = 'Person';
        // Missing birthDate, gender, and address fields intentionally to trigger an error

        inputDataList.add(inputData);

        Test.setMock(HttpCalloutMock.class, new VeteranConfirmationStatusMock());

        // Make the callout
        Test.startTest();
        List<VeteranConfirmationStatus.FlowOutputData> outputDataList = VeteranConfirmationStatus.makeHTTPCallout(inputDataList);
        Test.stopTest();

        // Assert the results
        VeteranConfirmationStatus.FlowOutputData outputData = outputDataList[0];
        System.assertEquals(400, outputData.statusCode, 'Expected a status code of 400.');
        System.assertEquals('The required parameter \'firstName\', is missing', outputData.error, 'Expected an error message for missing first name.');
        System.assertEquals(null, outputData.veteranStatus, 'Expected null for veteran status.');
        System.assertEquals(null, outputData.notConfirmedReason, 'Expected null for not confirmed reason.');
     }

    @IsTest
    static void testMakeHTTPCallout_CustomSettingMissing() {
        // No custom setting record created intentionally to trigger a "bad API key" error

        List<VeteranConfirmationStatus.FlowInputData> inputDataList = new List<VeteranConfirmationStatus.FlowInputData>();
        VeteranConfirmationStatus.FlowInputData inputData = new VeteranConfirmationStatus.FlowInputData();
        inputData.firstName = 'John';
        inputData.lastName = 'Doe';
        inputData.birthDate = '19851231';
        inputData.gender = 'M';
        inputData.streetAddressLine1 = '123 Main St';
        inputData.city = 'Anytown';
        inputData.zipCode = '12345';
        inputData.state = 'CA';
        inputData.country = 'USA';
        inputDataList.add(inputData);

        // Make the callout
        Test.startTest();
        List<VeteranConfirmationStatus.FlowOutputData> outputDataList = VeteranConfirmationStatus.makeHTTPCallout(inputDataList);
        Test.stopTest();

        // Assert the results
        VeteranConfirmationStatus.FlowOutputData outputData = outputDataList[0];
        System.assertEquals(null, outputData.veteranStatus, 'Expected null for veteran status.');
        System.assertEquals(null, outputData.notConfirmedReason, 'Expected null for not confirmed reason.');
        System.assertEquals('Bad API key or API Key Missing.', outputData.error, 'Expected an error message for missing API key.');
        System.assertEquals(null, outputData.statusCode, 'Expected null for status code.');
    }
    public class VeteranConfirmationStatusMock implements HttpCalloutMock{

        public HTTPResponse respond(HttpRequest req) {
            try {
                if (req.getEndpoint() == 'https://sandbox-api.you.thought.you.would.find.something.useful...BUT.IT.WAS.ME.DIO!' && req.getBody().contains('"firstName":""')) {
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{"errors":[{"title":"Missing parameter","detail":"The required parameter \'firstName\', is missing","code":"108","status":"400"}]}');
                    res.setStatusCode(400);
                    return res;
                }else {
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{"id": "1012667145V762142","veteran_status": "confirmed","not_confirmed_reason": null}');
                    res.setStatusCode(200);
                    return res;
                }
            } catch (Exception ex) {
                System.debug('ERROR Message>>>' + ex.getMessage() + 'Error Line Number>>>' + ex.getLineNumber());
            }
            return null;
        }
    }
}