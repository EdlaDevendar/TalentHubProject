@IsTest
private class WelcomeServiceTest {
    @IsTest
    static void returnsWelcomeMessage() {
        String result = WelcomeService.getMessage('Alex');

        System.assertEquals('Welcome, Alex!', result);
        System.debug(result);
    }
}