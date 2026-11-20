public with sharing class TalentHubApplicationStartController {
    @AuraEnabled(cacheable=true)
    public static List<Candidate__c> searchCandidates(String searchTerm) {
        String term = String.isBlank(searchTerm) ? null : searchTerm.trim();

        if (term == null) {
            return [
                SELECT Id, Name, Last_Name__c, Email__c
                FROM Candidate__c
                WITH USER_MODE
                ORDER BY Name
                LIMIT 50
            ];
        }

        String matchText = '%' + term + '%';
        return [
            SELECT Id, Name, Last_Name__c, Email__c
            FROM Candidate__c
            WHERE Name LIKE :matchText
                OR Last_Name__c LIKE :matchText
                OR Email__c LIKE :matchText
            WITH USER_MODE
            ORDER BY Name
            LIMIT 50
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Job__c> getOpenJobs() {
        return TalentHubJobService.searchOpenJobsForLwc(null, null);
    }
}