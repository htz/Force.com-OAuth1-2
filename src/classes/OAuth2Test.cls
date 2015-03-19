@isTest
private class OAuth2Test {
    public static OAuthService__c createTestService(String authorizationType) {
        OAuthService__c s = new OAuthService__c(
            Name = 'test1234',
            Consumer_Key__c = 'consumerkey',
            Consumer_Secret__c = 'consumersecret',
            Access_Token_URL__c = 'https://test/oauth2/token',
            Authorization_URL__c = 'https://test/oauth2/auth',
            Redirect_URL__c = 'https://localhost/oauth2/done',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = OAuthUtil.getOAuthServiceRecordTypeId('OAuth2'),
            Scope__c = 'full',
            Authorization_Type__c = authorizationType
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
            Owner__c = s.OwnerId,
            ResponseBody__c = '{}'
        );
        insert t;
        return t;
    }

    public static testMethod void testNewService() {
        OAuthService__c s = createTestService('Request Header (Authorization: Bearer)');
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

    public static testMethod void testOAuth_code() {
        PageReference completePage = new PageReference('/oauth2/done?code=code');
        completePage.getHeaders().put('Host', 'localhost');
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('Request Header (Authorization: Bearer)');

        Test.startTest();
        OAuth2 o1 = new OAuth2(s1.Id);
        o1.authorization(new Map<String, String>{
            'state' => 'test'
        });
        System.assert(!o1.isCompleteUrl());
        Test.setCurrentPage(completePage);
        System.assert(o1.isCompleteUrl());
        o1.complete(new Map<String, String> {
            'code' => 'code'
        });
        Test.stopTest();
    }

    public static testMethod void testOAuth_idpw() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('Request Header (Authorization: Bearer)');

        Test.startTest();
        OAuth2 o1 = new OAuth2(s1.Id);
        o1.getAccessTokenAuthorizationPassword('id', 'password');
        Test.stopTest();
    }

    public static testMethod void testOAuth_refresh() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('Request Header (Authorization: Bearer)');

        OAuth2 o1 = new OAuth2(s1.Id);
        o1.getAccessTokenRefreshToken();
        OAuth2_Token__c token = createTestToken(s1);
        OAuth2_Token__c token2 = createTestToken(s1);
        o1 = new OAuth2(s1.Id);
        System.assert(o1.hasToken());

        Test.startTest();
        o1.getAccessTokenRefreshToken();
        Test.stopTest();
    }

    public static testMethod void testOAuth_rest1() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('Request Header (Authorization: Bearer)');
        OAuth2_Token__c token = createTestToken(s1);
        OAuth2 o1 = new OAuth2(s1.Id);

        Test.startTest();
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://example/test?page=1&max=100&a=100');
        req.setMethod('POST');
        req.setBody('a=b&c=d');
        OAuthJSON json = o1.json(req);
        json.inspect();
        Test.stopTest();
    }

    public static testMethod void testOAuth_rest2() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('Request Header (Authorization: OAuth)');
        OAuth2_Token__c token = createTestToken(s1);
        OAuth2 o1 = new OAuth2(s1.Id);

        Test.startTest();
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://example/test?page=1&max=100&a=100');
        req.setMethod('POST');
        req.setBody('a=b&c=d');
        OAuthJSON json = o1.json(req);
        json.inspect();
        Test.stopTest();
    }

    public static testMethod void testOAuth_rest3() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('URI Query Parameter');
        OAuth2_Token__c token = createTestToken(s1);
        OAuth2 o1 = new OAuth2(s1.Id);

        Test.startTest();
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://example/test?page=1&max=100&a=100');
        req.setMethod('POST');
        req.setBody('a=b&c=d');
        OAuthJSON json = o1.json(req);
        json.inspect();
        Test.stopTest();
    }

    public static testMethod void testOAuth_resterror() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('Request Header (Authorization: Bearer)');
        OAuth2_Token__c token = createTestToken(s1);
        OAuth2 o1 = new OAuth2(s1.Id);

        Test.startTest();
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://example/error/400');
        req.setMethod('POST');
        req.setBody('a=b&c=d');
        OAuthJSON json = o1.json(req);
        Test.stopTest();
    }

    public static testMethod void testException() {
        HttpResponse res = new HttpResponse();
        res.setHeader('WWW-Authenticate', 'OAuth error="error", error-desc="desc", error-uri="http://error/", scope="full"');
        OAuth2Exception e1 = new OAuth2Exception(res);
        OAuth2Exception e2 = new OAuth2Exception(new Map<String, String>{
            'test' => 'test'
        });
        OAuth2Exception e3 = new OAuth2Exception(new Map<String, String>{
            'test' => 'test'
        }, res);
        OAuth2Exception e4 = new OAuth2Exception('error', 'desc', 'http://error/', 'full', 'test');
    }
}