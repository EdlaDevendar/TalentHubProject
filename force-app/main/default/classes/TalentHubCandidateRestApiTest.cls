@IsTest
private class TalentHubCandidateRestApiTest {
@IsTest static void invalidEmailReturns400() {
RestRequest r=new RestRequest();
r.requestUri='/services/apexrest/talenthub/candidates'; r.httpMethod='GET';
r.addParameter('email','bad'); RestContext.request=r; RestContext.response=new RestResponse();
TalentHubCandidateRestApi.getCandidate();
System.assertEquals(400,RestContext.response.statusCode);
}
@IsTest static void missingCandidateReturns404() {
RestRequest r=new RestRequest();
r.requestUri='/services/apexrest/talenthub/candidates'; r.httpMethod='GET';
r.addParameter('email','missing@example.com'); RestContext.request=r; RestContext.response=new RestResponse();
TalentHubCandidateRestApi.getCandidate();
System.assertEquals(404,RestContext.response.statusCode);
}
}