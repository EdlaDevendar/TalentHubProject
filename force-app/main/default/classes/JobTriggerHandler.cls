public with sharing class JobTriggerHandler {
    /**
     * Close Date must be the same as or later than Open Date.
     * Null handling remains with the object's existing required-field and validation rules.
     */
    public static void validateJobDates(List<Job__c> jobs) {
        if (jobs == null || jobs.isEmpty()) {
            return;
        }
        for (Job__c job : jobs) {
            if (job.Open_Date__c != null &&
                job.Close_Date__c != null &&
                job.Close_Date__c < job.Open_Date__c) {
                job.addError(
                    Job__c.Close_Date__c,
                    'Close Date must be on or after Open Date.'
                );
            }
        }
    }
}