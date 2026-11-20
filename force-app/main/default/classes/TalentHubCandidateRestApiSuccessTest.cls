@IsTest
private class TalentHubCandidateRestApiSuccessTest {
@IsTest static void returnsCandidateAndOmitsSensitiveFields() {
Candidate__c c=new Candidate__c(Name='Asha',Last_Name__c='Rao',Email__c='asha.rao@example.com');
insert c;
RestRequest r=new RestRequest();
r.requestUri='/services/apexrest/talenthub/candidates';
r.httpMethod='GET'; r.addParameter('email','asha.rao@example.com');
RestContext.request=r; RestContext.response=new RestResponse();
TalentHubCandidateRestApi.getCandidate();
System.assertEquals(200,RestContext.response.statusCode);
String body=RestContext.response.responseBody.toString();
System.assert(body.contains('asha.rao@example.com'));
System.assert(body.contains('candidateNumber'));
System.assert(!body.contains('Date_Of_Birth__c'));
System.assert(!body.contains('Expected_CTC__c'));
}
}