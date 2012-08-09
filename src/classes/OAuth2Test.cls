@isTest
private class OAuth2Test {
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

    public static testMethod void testNewService() {
        OAuthService__c s = createTestService();
        createTestToken(s);
        Test.startTest();
        // success
        OAuth2 o1 = new OAuth2(s.Id);
        // error
        delete s;
        try {
            OAuth2 oe1 = new OAuth2(s.Id);
            System.assert(false);
        } catch (OAuthException e) {
        }
        Test.stopTest();
    }

    public static testMethod void testOAuth() {
        OAuthService__c s1 = createTestService();
        Test.startTest();
        // success
        PageReference complete_page = new PageReference('/oauth/done?code=code');
        complete_page.getHeaders().put('Host', 'localhost');
        complete_page.getParameters().put('state', s1.Id);
        OAuth2 o1 = new OAuth2Tester(s1, complete_page);
        o1.authorization();
        System.assert(o1.isCompleteUrl());
        o1.complete(new Map<String, String> {
            'code' => 'code'
        });
        OAuth2 o1_2 = (OAuth2)o1;
        o1_2.getAccessTokenAuthorizationPassword('id', 'password');
        o1_2.getAccessTokenRefreshToken();

        OAuth2 o2 = new OAuth2Tester(s1, new OAuth2Tester.Response('{}', 200));
        System.assert(o2.hasToken());
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://example/test?page=1&max=100&a=100');
        req.setMethod('POST');
        req.setBody('a=b&c=d');
        OAuthJSON json = o2.json(req);
        json.inspect();
        Test.stopTest();
    }

    public static testMethod void testException() {
        OAuth2TesterException e1 = new OAuth2TesterException(new HttpResponse());
        OAuth2TesterException e2 = new OAuth2TesterException(new Map<String, String>());
    }
}