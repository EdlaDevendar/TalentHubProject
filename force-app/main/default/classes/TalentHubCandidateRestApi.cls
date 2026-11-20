@RestResource(urlMapping='/talenthub/candidates')
global with sharing class TalentHubCandidateRestApi {

    @HttpGet
    global static void getCandidate() {
        String email = RestContext.request.params.get('email');

        if (!isValidEmail(email)) {
            writeResponse(
                400,
                new ApiResponse(false, 'A valid email parameter is required.', null)
            );
            return;
        }

        try {
            List<Candidate__c> matches = [
                SELECT Candidate_Number__c, Name, Expected_CTC__c, Email__c
                FROM Candidate__c
                WHERE Email__c = :email
                WITH USER_MODE
                LIMIT 2
            ];

            if (matches.isEmpty()) {
                writeResponse(
                    404,
                    new ApiResponse(false, 'Candidate not found.', null)
                );
                return;
            }

            if (matches.size() > 1) {
                writeResponse(
                    409,
                    new ApiResponse(false, 'More than one candidate matches this email.', null)
                );
                return;
            }

            Candidate__c foundCandidate = matches[0];

            CandidateData data = new CandidateData();
            data.candidateNumber = foundCandidate.Candidate_Number__c;
            data.firstName = foundCandidate.Name;
            data.email = foundCandidate.Email__c;
            data.expectedCTC = foundCandidate.Expected_CTC__c;

            writeResponse(200, new ApiResponse(true, null, data));

        } catch (QueryException ex) {
            writeResponse(
                403,
                new ApiResponse(false, 'Insufficient access to candidate information.', null)
            );
        }
    }

    @HttpPost
    global static void createCandidate() {
        String requestBody = RestContext.request.requestBody == null
            ? null
            : RestContext.request.requestBody.toString();

        if (String.isBlank(requestBody)) {
            writeResponse(
                400,
                new ApiResponse(false, 'A JSON request body is required.', null)
            );
            return;
        }

        CandidateCreateRequest input;

        try {
            input = (CandidateCreateRequest) JSON.deserialize(
                requestBody,
                CandidateCreateRequest.class
            );
        } catch (Exception ex) {
            writeResponse(
                400,
                new ApiResponse(false, 'The request body is not valid JSON.', null)
            );
            return;
        }

        if (input == null
            || String.isBlank(input.firstName)
            || String.isBlank(input.lastName)
            || String.isBlank(input.highestQualification)
            || !isValidEmail(input.email)) {
            writeResponse(
                400,
                new ApiResponse(
                    false,
                    'Provide firstName, lastName, a valid email, and highestQualification.',
                    null
                )
            );
            return;
        }

        Candidate__c newCandidate = new Candidate__c(
            Name = input.firstName,
            Last_Name__c = input.lastName,
            Highest_Qualification__c = input.highestQualification,
            Email__c = input.email,
            Expected_CTC__c = input.expectedCTC
        );

        try {
            insert as user newCandidate;
            writeResponse(201, new ApiResponse(true, null, null));

        } catch (DmlException ex) {
            writeResponse(
                400,
                new ApiResponse(
                    false,
                    'Candidate could not be created. Check required fields and allowed values.',
                    null
                )
            );
        }
    }

    private static Boolean isValidEmail(String email) {
        return !String.isBlank(email)
            && email.length() <= 254
            && Pattern.matches(
                '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$',
                email
            );
    }

    private static void writeResponse(Integer statusCode, ApiResponse body) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(body));
    }

    global class ApiResponse {
        global Boolean success;
        global String error;
        global CandidateData candidate;

        global ApiResponse(Boolean success, String error, CandidateData candidate) {
            this.success = success;
            this.error = error;
            this.candidate = candidate;
        }
    }

    global class CandidateData {
        global String candidateNumber;
        global String firstName;
        global String email;
        global Decimal expectedCTC;

        global CandidateData() {}
    }

    global class CandidateCreateRequest {
        global String firstName;
        global String lastName;
        global String email;
        global Decimal expectedCTC;
        global String highestQualification;
    }
}