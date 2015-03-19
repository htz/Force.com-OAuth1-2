@isTest
private class OAuth1Test {
    public static OAuthService__c createTestService(String signature_method) {
        OAuthService__c s = new OAuthService__c(
            Name = 'test1234',
            Consumer_Key__c = 'consumerkey',
            Consumer_Secret__c = 'consumersecret',
            Signature_Method__c = signature_method,
            Access_Token_URL__c = 'https://test/oauth1/token',
            Authorization_URL__c = 'https://test/oauth1/auth',
            Redirect_URL__c = 'https://localhost/oauth1/done',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = OAuthUtil.getOAuthServiceRecordTypeId('OAuth1'),
            Request_Token_Url__c = 'https://test/oauth/request_token',
            Authorization_Type__c = 'Request Header (Authorization: OAuth)'
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

    public static testMethod void testNewService() {
        OAuthService__c s = createTestService('HMAC-SHA1');
        OAuth_Token__c t = createTestToken(s, true);
        Test.startTest();
        // success
        s.Redirect_URL__c = '/oauth/request_token';
        update s;
        OAuth1 o1 = new OAuth1(s.Id);
        OAuth1 o2 = OAuth1.newInstanceByToken(t.OAuth_Token__c);
        // error
        delete s;
        try {
            OAuth1 oe1 = new OAuth1(s.Id);
            System.assert(false);
        } catch (OAuthException e) {
        }
        try {
            OAuth1 oe2 = Oauth1.newInstanceByToken('xxx');
            System.assert(false);
        } catch (OAuthException e) {
        }
        Test.stopTest();
    }

    public static testMethod void testHmacSha1OAuth_0() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('HMAC-SHA1');

        Test.startTest();
        // success
        OAuth1 o1 = new OAuth1(s1.Id);
        System.assert(!o1.isCompleteUrl());
        o1.authorization();
        Test.stopTest();
    }

    public static testMethod void testHmacSha1OAuth_1() {
        PageReference completePage = new PageReference('/oauth1/done?oauth_token=token');
        completePage.getHeaders().put('Host', 'localhost');
        Test.setCurrentPage(completePage);
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('HMAC-SHA1');
        OAuth_Token__c token = new OAuth_Token__c(
            Owner__c = UserInfo.getUserId(),
            OAuth_Service__c = s1.Id,
            OAuth_Token__c = 'oauth_token',
            OAuth_Token_Secret__c = 'oauth_token_secret',
            isAccess__c = false
        );
        insert token;
        OAuth1 o2 = new OAuth1(s1.Id);

        Test.startTest();
        System.assert(o2.isCompleteUrl());
        o2.complete(new Map<String, String> {
            'oauth_token' => 'oauth_token',
            'oauth_verifier' => 'oauth_verifier'
        });
        Test.stopTest();
    }

    public static testMethod void testHmacSha1OAuth_2() {
        Test.setMock(HttpCalloutMock.class, new OAuthCalloutMock());
        OAuthService__c s1 = createTestService('HMAC-SHA1');
        OAuth_Token__c token = new OAuth_Token__c(
            Owner__c = UserInfo.getUserId(),
            OAuth_Service__c = s1.Id,
            OAuth_Token__c = 'oauth_token',
            OAuth_Token_Secret__c = 'oauth_token_secret',
            isAccess__c = true
        );
        insert token;
        OAuth_Token__c token2 = new OAuth_Token__c(
            Owner__c = UserInfo.getUserId(),
            OAuth_Service__c = s1.Id,
            OAuth_Token__c = 'oauth_token',
            OAuth_Token_Secret__c = 'oauth_token_secret',
            isAccess__c = true
        );
        insert token2;
        OAuth1 o3 = new OAuth1(s1.Id);

        Test.startTest();
        System.assert(o3.hasToken());
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://example/test?page=1&max=100&a=100');
        req.setMethod('POST');
        req.setBody('a=b&c=d');
        OAuthJSON json = o3.json(req);
        json.inspect();
        Test.stopTest();
    }

    public static testMethod void testException() {
        HttpResponse res = new HttpResponse();
        res.setHeader('WWW-Authenticate', 'OAuth error="error", error-desc="desc", error-uri="http://error/", scope="full"');
        OAuth1Exception e1 = new OAuth1Exception(res);
        OAuth1Exception e2 = new OAuth1Exception('test', 'test');
    }
}