@isTest
private class OAuthTwitterSampleControllerTest {
    public static OAuthService__c createTestService() {
        Schema.DescribeSObjectResult d = Schema.SObjectType.OAuthService__c;
        Map<String, Schema.RecordTypeInfo> rti = d.getRecordTypeInfosByName();
        OAuthService__c s = new OAuthService__c(
            Name = 'Twitter',
            Consumer_Key__c = 'consumerkey',
            Consumer_Secret__c = 'consumersecret',
            Access_Token_URL__c = 'https://test/oauth/token',
            Authorization_URL__c = 'https://test/oauth/auth',
            Redirect_URL__c = 'https://localhost/oauth/done',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = rti.get('OAuth 2.0').getRecordTypeId(),
            Scope__c = 'full',
            Authorization_Type__c = 'Request Header (Authorization: Bearer)'
        );
        insert s;
        return s;
    }

    public static OAuth2_Token__c createTestToken(OAuthService__c  s) {
        OAuth2_Token__c t = new OAuth2_Token__c(
            OAuth_Service__c = s.Id,
            Access_Token__c = 'token',
            Refresh_Token__c = 'refresh',
            Scope__c = s.Scope__c,
            Token_Type__c = 'type',
            Expires_In__c = 3600,
            Owner__c = s.OwnerId
        );
        insert t;
        return t;
    }

    public static testMethod void testInit() {
        OAuthService__c s1 = createTestService();
        OAuthTwitterSampleController t = new OAuthTwitterSampleController();
        t.init();

        createTestToken(s1);
        t = new OAuthTwitterSampleController();
        t.init();
    }

    public static testMethod void testTwitter() {
        System.currentPageReference().getParameters().put('@test', 'test');
        OAuthService__c s1 = createTestService();
        OAuth2_Token__c t1 = createTestToken(s1);
        OAuthTwitterSampleController t = new OAuthTwitterSampleController();
        t.getFeed();
        t.status = 'test';
        t.post();
    }
}