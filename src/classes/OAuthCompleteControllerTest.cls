@isTest
private class OAuthCompleteControllerTest {
    public static OAuthService__c createTestService1() {
        Schema.DescribeSObjectResult d = Schema.SObjectType.OAuthService__c;
        Map<String, Schema.RecordTypeInfo> rti = d.getRecordTypeInfosByName();
        OAuthService__c s = new OAuthService__c(
            Name = 'test1234',
            Consumer_Key__c = 'consumerkey',
            Consumer_Secret__c = 'consumersecret',
            Access_Token_URL__c = 'https://test/oauth/token',
            Authorization_URL__c = 'https://test/oauth/auth',
            Redirect_URL__c = 'https://localhost/oauth/done',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = rti.get('OAuth 1.0').getRecordTypeId(),
            Request_Token_Url__c = 'https://test/oauth/request_token',
            Authorization_Type__c = 'Request Header (Authorization: OAuth)'
        );
        insert s;
        return s;
    }

    public static OAuth_Token__c createToken1(OAuthService__c s) {
        OAuth_Token__c t = new OAuth_Token__c(
            OAuth_Service__c = s.Id,
            OAuth_Token__c = 'token',
            OAuth_Token_Secret__c = 'secret',
            Owner__c = s.OwnerId,
            isAccess__c = false
        );
        insert t;
        return t;
    }

    public static OAuthService__c createTestService2() {
        Schema.DescribeSObjectResult d = Schema.SObjectType.OAuthService__c;
        Map<String, Schema.RecordTypeInfo> rti = d.getRecordTypeInfosByName();
        OAuthService__c s = new OAuthService__c(
            Name = 'test1234',
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

    public static testMethod void testAll() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        OAuthCompleteController t = new OAuthCompleteController();
        parameters.put('@test', 'test');

        OAuthService__c s1 = createTestService1();
        OAuth_Token__c t1 = createToken1(s1);
        t.complete();
        parameters.put('oauth_token', t1.OAuth_Token__c);
        t.complete();
        parameters.remove('oauth_token');

        OAuthService__c s2 = createTestService2();
        t.complete();
        parameters.put('state', s2.Id);
        t.complete();
    }
}