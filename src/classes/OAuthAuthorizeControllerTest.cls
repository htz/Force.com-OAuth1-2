@isTest
private class OAuthAuthorizeControllerTest {
    public static OAuthService__c createTestService() {
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
        OAuthService__c s = createTestService();
        OAuthAuthorizeController t = new OAuthAuthorizeController(
            new ApexPages.StandardController([Select Id, RecordTypeId From OAuthService__c Where Name = 'test1234'])
        );
        t.init();
    }
}