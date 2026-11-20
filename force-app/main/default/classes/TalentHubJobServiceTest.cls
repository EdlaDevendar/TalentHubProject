@IsTest
private class TalentHubJobServiceTest {
@TestSetup
static void setup() {
    // Job__c validation requires Name, Open_Date__c, and Close_Date__c for Open status
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
                Status__c= 'Closed',
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
        ),
        new Job__c(
            Name = 'Filled Role',
            Status__c = 'Closed',
            Department__c = 'IT',
            Location__c = 'Hyderabad',
            Open_Date__c = Date.today().addDays(-30),
            Close_Date__c = Date.today().addDays(-1),
            Employment_Type__c = 'Full Time',
            Experience_Required__c = 3
        )
    };
}

@IsTest
static void getOpenJobs_returnsOnlyOpenJobs() {
    List<Job__c> result = TalentHubJobService.getOpenJobs();
    System.assertEquals(2, result.size(), 'Only the 2 open jobs should be returned');
    for (Job__c j : result) {
        System.assertEquals('Open', j.Status__c, 'No non-open job should be returned');
    }
}

@IsTest
static void search_byDepartment_excludesClosedJobs() {
    List<Job__c> result = TalentHubJobService.searchOpenJobs('IT', null);
    System.assertEquals(1, result.size(), 'Closed, On Hold, and Filled IT jobs must not be returned');
    System.assertEquals('Salesforce Developer', result[0].Name);
}

@IsTest
static void search_byLocation() {
    List<Job__c> result = TalentHubJobService.searchOpenJobs(null, 'Chennai');
    System.assertEquals(1, result.size());
    System.assertEquals('HR Executive', result[0].Name);
}

@IsTest
static void search_byDepartmentAndLocation() {
    List<Job__c> result = TalentHubJobService.searchOpenJobs('IT', 'Hyderabad');
    System.assertEquals(1, result.size());
    System.assertEquals('Salesforce Developer', result[0].Name);
}

@IsTest
static void search_noResults_returnsEmptyList() {
    List<Job__c> result = TalentHubJobService.searchOpenJobs('Finance', null);
    System.assertNotEquals(null, result, 'Result must never be null');
    System.assertEquals(0, result.size(), 'No match should return an empty list');
}

@IsTest
static void search_blankFilters_returnsAllOpenJobs() {
    List<Job__c> result = TalentHubJobService.searchOpenJobs(' ', '');
    System.assertEquals(2, result.size(), 'Blank or whitespace filters should return all open jobs');
}
}