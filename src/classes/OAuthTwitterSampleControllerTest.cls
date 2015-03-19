@isTest
private class OAuthTwitterSampleControllerTest {
    public static OAuthService__c createTestService() {
        OAuthService__c s = new OAuthService__c(
            Name = 'Twitter',
            Consumer_Key__c = 'consumerkey',
            Consumer_Secret__c = 'consumersecret',
            Request_Token_URL__c = 'https://api.twitter.com/oauth/request_token',
            Authorization_URL__c = 'https://api.twitter.com/oauth/authorize',
            Access_Token_URL__c = 'https://api.twitter.com/oauth/access_token',
            Redirect_URL__c = 'https://localhost/oauth1/done',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = OAuthUtil.getOAuthServiceRecordTypeId('OAuth1'),
            Scope__c = 'full',
            Authorization_Type__c = 'Request Header (Authorization: Bearer)'
        );
        insert s;
        return s;
    }

    public static OAuth_Token__c createTestToken(OAuthService__c  s, Boolean isAccess) {
        OAuth_Token__c t = new OAuth_Token__c(
            OAuth_Service__c = s.Id,
            OAuth_Token__c = 'token',
            OAuth_Token_Secret__c = 'secret',
            Owner__c = s.OwnerId,
            isAccess__c = isAccess
        );
        insert t;
        return t;
    }

    public static testMethod void testInit() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService();
        OAuthTwitterSampleController t = new OAuthTwitterSampleController();

        Test.startTest();
        t.init();
        Test.stopTest();
    }

    public static testMethod void testInitComplete() {
        PageReference completePage = new PageReference('/oauth1/done?oauth_token=token');
        completePage.getHeaders().put('Host', 'localhost');
        Test.setCurrentPage(completePage);
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService();
        createTestToken(s1, false);
        OAuthTwitterSampleController t = new OAuthTwitterSampleController();

        Test.startTest();
        t.init();
        Test.stopTest();
    }

    public static testMethod void testInitToken() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService();
        createTestToken(s1, true);
        OAuthTwitterSampleController t = new OAuthTwitterSampleController();

        Test.startTest();
        t.init();
        Test.stopTest();
    }

    public static testMethod void testTwitter() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        System.currentPageReference().getParameters().put('@test', 'test');
        OAuthService__c s1 = createTestService();
        createTestToken(s1, true);
        OAuthTwitterSampleController t = new OAuthTwitterSampleController();

        Test.startTest();
        t.getFeed();
        t.status = 'test';
        t.post();
        Test.stopTest();
    }
}