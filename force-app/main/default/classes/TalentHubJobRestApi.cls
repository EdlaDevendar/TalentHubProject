@RestResource(urlMapping='/talenthub/jobs')
global with sharing class TalentHubJobRestApi {
    @HttpGet
    global static void getJobs() {
        Map<String, String> params = RestContext.request.params;

        if (params == null) {
            params = new Map<String, String>();
        }

        for (String key : params.keySet()) {
            if (key != 'department' && key != 'location') {
                sendResponse(400, new Map<String, Object>{
                    'success' => false,
                    'error' => 'Unsupported parameter: ' + key
                });
                return;
            }
        }

        String department = params.get('department');
        String location = params.get('location');

        if (department != null) department = department.trim();
        if (location != null) location = location.trim();

        if ((department != null && department.length() > 100) ||
            (location != null && location.length() > 100)) {
            sendResponse(400, new Map<String, Object>{
                'success' => false,
                'error' => 'Department and location must be 100 characters or fewer.'
            });
            return;
        }

        try {
            List<Job__c> jobs =
                new TalentHubJobService().searchOpenJobs(department, location);

            sendResponse(200, new Map<String, Object>{
                'success' => true,
                'data' => jobs
            });
        } catch (QueryException e) {
            sendResponse(403, new Map<String, Object>{
                'success' => false,
                'error' => 'Access denied. Check the API user’s job permissions.'
            });
        } catch (Exception e) {
            sendResponse(500, new Map<String, Object>{
                'success' => false,
                'error' => 'Unable to retrieve open jobs.'
            });
        }
    }

    private static void sendResponse(
        Integer statusCode,
        Object responseData
    ) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody =
            Blob.valueOf(JSON.serialize(responseData));
    }
}