@isTest
private class OAuth1Test {
    public static OAuthService__c createTestService(String signature_method) {
        Schema.DescribeSObjectResult d = Schema.SObjectType.OAuthService__c;
        Map<String, Schema.RecordTypeInfo> rti = d.getRecordTypeInfosByName();
        OAuthService__c s = new OAuthService__c(
            Name = 'test1234',
            Consumer_Key__c = 'consumerkey',
            Consumer_Secret__c = 'consumersecret',
            Signature_Method__c = signature_method,
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

    public static testMethod void testHmacSha1OAuth() {
        OAuthService__c s1 = createTestService('HMAC-SHA1');
        Test.startTest();
        // success
        OAuth1Tester o1 = new OAuth1Tester(s1);
        o1.authorization();
        PageReference complete_page = new PageReference('/oauth/done?oauth_token=token');
        complete_page.getHeaders().put('Host', 'localhost');
        OAuth1Tester o2 = new OAuth1Tester(s1, complete_page);      
        System.assert(o2.isCompleteUrl());  
        o2.complete(new Map<String, String> {
            'oauth_token' => 'token'
        });
        OAuth1Tester o3 = new OAuth1Tester(s1, new OAuth1Tester.Response('{}', 200));
        System.assert(o3.hasToken());
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://example/test?page=1&max=100&a=100');
        req.setMethod('POST');
        req.setBody('a=b&c=d');
        OAuthJSON json = o3.json(req);
        json.inspect();
        // error
        try {
            OAuth1Tester oe1 = new OAuth1Tester(s1, new OAuth1Tester.Response('', 500));
            oe1.authorization();
            System.assert(false);
        } catch (OAuthException e) {
        }
        Test.stopTest();
    }

    public static testMethod void testPlaintextOAuth() {
        OAuthService__c s1 = createTestService('PLAINTEXT');
        Test.startTest();
        // success
        OAuth1Tester o1 = new OAuth1Tester(s1);
        o1.authorization();
        PageReference complete_page = new PageReference('/oauth/done?oauth_token=token');
        complete_page.getHeaders().put('Host', 'localhost');
        OAuth1Tester o2 = new OAuth1Tester(s1, complete_page);      
        System.assert(o2.isCompleteUrl());  
        o2.complete(new Map<String, String> {
            'oauth_token' => 'token'
        });
        OAuth1Tester o3 = new OAuth1Tester(s1, new OAuth1Tester.Response('{}', 200));
        System.assert(o3.hasToken());
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://example/test?page=1&max=100&a=100');
        req.setMethod('POST');
        req.setBody('a=b&c=d');
        OAuthJSON json = o3.json(req);
        json.inspect();
        // error
        try {
            OAuth1Tester oe1 = new OAuth1Tester(s1, new OAuth1Tester.Response('', 500));
            oe1.authorization();
            System.assert(false);
        } catch (OAuthException e) {
        }
        Test.stopTest();
    }

    public static testMethod void testException() {
        OAuth1TesterException e1 = new OAuth1TesterException(new HttpResponse());
        OAuth1TesterException e2 = new OAuth1TesterException('error', 'error');
    }
}