public with sharing class TalentHubJobService {
    private final String OPEN_STATUS = 'Open';

    public List<Job__c> getOpenJobs() {
        return searchOpenJobs(null, null);
    }

    public List<Job__c> searchOpenJobs(String department, String location) {
        String soql = 'SELECT Id, Name, Status__c, Department__c, Location__c, ' +
                      'Open_Date__c, Close_Date__c ' +
                      'FROM Job__c WHERE Status__c = :openStatus';
        Map<String, Object> binds = new Map<String, Object>{ 'openStatus' => OPEN_STATUS };

        if (String.isNotBlank(department)) {
            soql += ' AND Department__c = :department';
            binds.put('department', department.trim());
        }
        if (String.isNotBlank(location)) {
            soql += ' AND Location__c = :location';
            binds.put('location', location.trim());
        }

        soql += ' ORDER BY Open_Date__c DESC NULLS LAST, Name LIMIT 200';
        return (List<Job__c>) Database.queryWithBinds(soql, binds, AccessLevel.USER_MODE);
    }

    @AuraEnabled(cacheable=true)
    public static List<Job__c> searchOpenJobsForLwc(String department, String location) {
        return new TalentHubJobService().searchOpenJobs(department, location);
    }
}