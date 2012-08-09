@isTest
private class OAuthApiTestControllerTest {
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

    public static OAuthServiceAPI__c createServiceAPI(OAuthService__c  s) {
        OAuthServiceAPI__c a = new OAuthServiceAPI__c(
            OAuth_Service__c = s.Id,
            Url__c = 'http://test/{Id}',
            Method__c = 'POST',
            Body__c = 'test=0',
            Content_Type__c = 'application/x-www-url-form-encoded'
        );
        insert a;
        List<OAuthServiceAPIParameter__c> ps = new List<OAuthServiceAPIParameter__c> {
            new OAuthServiceAPIParameter__c(OAuth_Service_API__c = a.Id, Type__c = 'Query String', Value__c = 'a'),
            new OAuthServiceAPIParameter__c(OAuth_Service_API__c = a.Id, Type__c = 'Request Header', Value__c = 'b')
        };
        insert ps;
        return a;
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

    public static testMethod void testAll() {
        System.currentPageReference().getParameters().put('@test', 'test');
        OAuthService__c s = createTestService();
        OAuthServiceAPI__c api = createServiceAPI(s);
        createTestToken(s);

        OAuthApiTestController t = new OAuthApiTestController();
        List<SelectOption> ms = t.methodOptions;
        List<SelectOption> ss = t.serviceOptions;
        t.service = s.Id;
        List<SelectOption> sas = t.serviceAPIOptions;
        t.serviceAPI = api.Id;
        t.loadServiceAPI();
        t.template[0].value = 'test';
        t.applyRequest();
        t.add_query();
        t.add_header();
        t.action_index = '0';
        t.delete_query();
        t.action_index = '0';
        t.delete_header();
        t.clearDebug();
        t.execute();
    }
}