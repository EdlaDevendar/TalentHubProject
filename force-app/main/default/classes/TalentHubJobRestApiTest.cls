@IsTest
private class TalentHubJobRestApiTest {
    @TestSetup
    static void setup() {
        insert new List<Job__c>{
            new Job__c(
                Name = 'Salesforce Developer',
                Status__c = 'Open',
                Department__c = 'IT',
                Location__c = 'Hyderabad',
                Open_Date__c = Date.today(),
                Close_Date__c = Date.today().addDays(30),
                Employment_Type__c = 'Full Time',
                Experience_Required__c = 3
            ),
            new Job__c(
                Name = 'HR Executive',
                Status__c = 'Open',
                Department__c = 'HR',
                Location__c = 'Chennai',
                Open_Date__c = Date.today(),
                Close_Date__c = Date.today().addDays(30),
                Employment_Type__c = 'Part Time',
                Experience_Required__c = 3
            ),
            new Job__c(
                Name = 'Old IT Role',
                Status__c = 'Closed',
                Department__c = 'IT',
                Location__c = 'Hyderabad',
                Open_Date__c = Date.today().addDays(-60),
                Close_Date__c = Date.today().addDays(-5),
                Employment_Type__c = 'Full Time',
                Experience_Required__c = 3
            ),
            new Job__c(
                Name = 'Paused Role',
                Status__c = 'On Hold',
                Department__c = 'IT',
                Location__c = 'Hyderabad',
                Open_Date__c = Date.today(),
                Close_Date__c = Date.today().addDays(30),
                Employment_Type__c = 'Part Time',
                Experience_Required__c = 3
            )
        };
    }

    private static RestResponse callEndpoint(Map<String, String> parameters) {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/talenthub/jobs';
        request.httpMethod = 'GET';

        if (parameters != null) {
            for (String key : parameters.keySet()) {
                request.addParameter(key, parameters.get(key));
            }
        }

        RestContext.request = request;
        RestContext.response = new RestResponse();

        TalentHubJobRestApi.getJobs();
        return RestContext.response;
    }

    @IsTest
    static void returnsOnlyOpenJobs() {
        RestResponse response = callEndpoint(null);

        System.assertEquals(200, response.statusCode);
        Map<String, Object> body =
            (Map<String, Object>) JSON.deserializeUntyped(
                response.responseBody.toString()
            );
        List<Object> jobs = (List<Object>) body.get('data');

        System.assertEquals(2, jobs.size());
        for (Object item : jobs) {
            Map<String, Object> job = (Map<String, Object>) item;
            System.assertEquals('Open', job.get('Status__c'));
        }
    }

    @IsTest
    static void departmentFilterWorks() {
        RestResponse response = callEndpoint(
            new Map<String, String>{ 'department' => 'IT' }
        );

        Map<String, Object> body =
            (Map<String, Object>) JSON.deserializeUntyped(
                response.responseBody.toString()
            );
        List<Object> jobs = (List<Object>) body.get('data');

        System.assertEquals(200, response.statusCode);
        System.assertEquals(1, jobs.size());
    }

    @IsTest
    static void locationFilterWorks() {
        RestResponse response = callEndpoint(
            new Map<String, String>{ 'location' => 'Chennai' }
        );

        Map<String, Object> body =
            (Map<String, Object>) JSON.deserializeUntyped(
                response.responseBody.toString()
            );
        List<Object> jobs = (List<Object>) body.get('data');

        System.assertEquals(200, response.statusCode);
        System.assertEquals(1, jobs.size());
    }

    @IsTest
    static void unsupportedParameterReturnsBadRequest() {
        RestResponse response = callEndpoint(
            new Map<String, String>{ 'badFilter' => 'value' }
        );

        System.assertEquals(400, response.statusCode);
    }
}