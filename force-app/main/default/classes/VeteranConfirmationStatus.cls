public class VeteranConfirmationStatus {

    @InvocableMethod(label='Veteran Confirmation API Callout' 
                    description='Performs an HTTP callout to verify veteran status using external VA Lighthouse API.'
                    category = 'External Services')
    public static List<FlowOutputData> makeHTTPCallout(List<FlowInputData> inputDataList) {
        List<FlowOutputData> outputDataList = new List<FlowOutputData>();
        
        // Retrieve the custom setting record
        Veteran_Confirmation_Status__c customSetting = Veteran_Confirmation_Status__c.getInstance();
        
        // Ensure the custom setting record and API key field exist
        if (customSetting != null && customSetting.API_Key__c != null && customSetting.Endpoint__c != null) {
            String endpoint = customSetting.Endpoint__c;
            FlowOutputData outputData = new FlowOutputData();
            for (FlowInputData inputData : inputDataList) {
                try {
                    HttpResponse response = makeHttpRequest(endpoint, customSetting.API_Key__c, inputData);
                    processResponse(response, outputData);
                    outputDataList.add(outputData);
                } catch (Exception e) {
                    outputData.error = 'Error occurred during HTTP callout: ' + e.getMessage();
                    outputDataList.add(outputData);
                }
            }
        } else {
            FlowOutputData outputData = new FlowOutputData();
            outputData.error = 'Bad API key or API Key Missing.';
            outputDataList.add(outputData);
        }
        return outputDataList;
    }

    private static HttpResponse makeHttpRequest(String endpoint, String apiKey, FlowInputData inputData) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('apiKey', apiKey);
        request.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'firstName' => inputData.firstName,
            'lastName' => inputData.lastName,
            'birthDate' => inputData.birthDate,
            'middleName' => inputData.middleName,
            'gender' => inputData.gender,
            'streetAddressLine1' => inputData.streetAddressLine1,
            'city' => inputData.city,
            'zipCode' => inputData.zipCode,
            'state' => inputData.state,
            'country' => inputData.country,
            'homePhoneNumber' => inputData.homePhoneNumber,
            'mothersMaidenName' => inputData.mothersMaidenName,
            'birthPlaceCity' => inputData.birthPlaceCity,
            'birthPlaceState' => inputData.birthPlaceState,
            'birthPlaceCountry' => inputData.birthPlaceCountry
        };
        String requestBodyJSON = JSON.serialize(requestBodyMap);
        request.setBody(requestBodyJSON);
        
        Http http = new Http();
        return http.send(request);
    }

    private static void processResponse(HttpResponse response, FlowOutputData outputData) {
        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        
        Integer statusCode = response.getStatusCode();
        outputData.statusCode = statusCode;

        if (statusCode != 200) {
            List<Object> errors = (List<Object>)responseMap.get('errors');
            Map<String, Object> errorMap = (Map<String, Object>)errors[0];
            outputData.error = (String)errorMap.get('detail');
        } else {
            outputData.id = (String)responseMap.get('id');
            outputData.veteranStatus = (String)responseMap.get('veteran_status');
            outputData.notConfirmedReason = (String)responseMap.get('not_confirmed_reason');
        }
    }

    // Define a wrapper class for the output data
    public class FlowOutputData {
        @InvocableVariable
        public String id;

        @InvocableVariable
        public String veteranStatus;

        @InvocableVariable
        public String notConfirmedReason;

        @InvocableVariable
        public String error;

        @InvocableVariable
        public Integer statusCode;
    }

    // Define a wrapper class for the input data
    public class FlowInputData {
        @InvocableVariable(required=true)
        public String firstName;

        @InvocableVariable(required=true)
        public String lastName;

        @InvocableVariable(required=true)
        public String birthDate;

        @InvocableVariable
        public String middleName;

        @InvocableVariable
        public String gender;

        @InvocableVariable
        public String streetAddressLine1;

        @InvocableVariable
        public String city;

        @InvocableVariable
        public String zipCode;

        @InvocableVariable
        public String state;

        @InvocableVariable
        public String country;

        @InvocableVariable
        public String homePhoneNumber;

        @InvocableVariable
        public String mothersMaidenName;

        @InvocableVariable
        public String birthPlaceCity;

        @InvocableVariable
        public String birthPlaceState;

        @InvocableVariable
        public String birthPlaceCountry;
    }
}