trigger JobTrigger on Job__c (before insert, before update) {
    JobTriggerHandler.validateJobDates(Trigger.new);
}