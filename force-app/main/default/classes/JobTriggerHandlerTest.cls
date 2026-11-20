@IsTest
private class JobTriggerHandlerTest {
    private static Job__c makeJob(String jobName, Date openDate, Date closeDate) {
        return new Job__c(
            Name = jobName,
            Open_Date__c = openDate,
            Close_Date__c = closeDate,
            Location__c = 'San Francisco',
            Employment_Type__c = 'Full Time',
            Experience_Required__c = 1,
            Status__c = 'Open'
        );
    }

    @IsTest
    static void acceptsValidDatesOnInsertAndBulkUpdate() {
        List<Job__c> jobs = new List<Job__c>();
        Date firstOpenDate = Date.newInstance(2026, 1, 1);
        for (Integer i = 0; i < 200; i++) {
            jobs.add(makeJob('Valid Job ' + i, firstOpenDate.addDays(i), firstOpenDate.addDays(i + 30)));
        }

        Test.startTest();
        insert jobs;
        for (Job__c job : jobs) {
            job.Close_Date__c = job.Open_Date__c.addDays(45);
        }
        update jobs;
        Test.stopTest();

        System.assertEquals(200, [SELECT count() FROM Job__c]);
    }

    @IsTest
    static void allowsCloseDateEqualToOpenDate() {
        Date sameDay = Date.newInstance(2026, 5, 10);
        Job__c job = makeJob('Same Day Job', sameDay, sameDay);

        insert job;
        System.assertEquals(sameDay, job.Close_Date__c);
    }

    @IsTest
    static void rejectsCloseDateBeforeOpenDateOnInsert() {
        Date openDate = Date.newInstance(2026, 6, 10);
        Job__c job = makeJob('Invalid Insert Job', openDate, openDate.addDays(-1));

        Database.SaveResult result = Database.insert(job, false);
        System.assertEquals(false, result.isSuccess());
        System.assert(result.getErrors()[0].getMessage().contains('Close Date'));
    }

    @IsTest
    static void rejectsCloseDateBeforeOpenDateOnUpdate() {
        Date openDate = Date.newInstance(2026, 7, 10);
        Job__c job = makeJob('Invalid Update Job', openDate, openDate.addDays(1));
        insert job;

        job.Close_Date__c = openDate.addDays(-1);
        Database.SaveResult result = Database.update(job, false);
        System.assertEquals(false, result.isSuccess());
        System.assert(result.getErrors()[0].getMessage().contains('Close Date'));
    }
}