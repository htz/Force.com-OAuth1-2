@isTest
private class OAuthTest {
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

    public static testMethod void testNewService1() {
        OAuthService__c s = createTestService1();
        Test.startTest();
        // success
        OAuth o1 = new OAuth(s);
        OAuth o2 = new OAuth(null);
        OAuth o3 = OAuth.newInstance(s);
        OAuth o4 = OAuth.newInstance(s.Id);
        OAuth o5 = OAuth.newInstance(s.Name);
        // error
        delete s;
        OAuth oe1 = OAuth.newInstance(s);
        try {
            OAuth oe2 = Oauth1.newInstanceByToken('xxx');
            System.assert(false);
        } catch (OAuthException e) {
        }
        Test.stopTest();
    }

    public static testMethod void testNewService2() {
        OAuthService__c s = createTestService2();
        Test.startTest();
        // success
        OAuth o1 = new OAuth(s);
        OAuth o2 = new OAuth(null);
        OAuth o3 = OAuth.newInstance(s);
        OAuth o4 = OAuth.newInstance(s.Id);
        OAuth o5 = OAuth.newInstance(s.Name);
        // error
        delete s;
        OAuth oe1 = OAuth.newInstance(s);
        Test.stopTest();
    }

    public static testMethod void testOAuth() {
        OAuthService__c s = createTestService1();
        Test.startTest();
        // success
        PageReference complete_page = new PageReference('/oauth/done?oauth_token=token');
        complete_page.getHeaders().put('Host', 'localhost');
        OAuthTester o1 = new OAuthTester(s, complete_page, new OAuthTester.Response('{}', 200));
        o1.authorization();
        System.assert(o1.isCompleteUrl());
        o1.complete();
        System.assert(!o1.hasToken());
        o1.json(null);
        o1.get('');
        o1.head('');
        o1.del('');
        o1.post('', '');
        o1.put('', '');
        o1.patch('', '');
        Test.stopTest();
    }

    public static testMethod void testOther() {
        OAuthService__c s = createTestService1();
        Test.startTest();
        OAuth.splitParameters('');
        OAuth.splitParameters('test=a');
        OAuth.parseJsonParameters('{"a":1,"b":12345678901234567890123456789012345678901234567890,"c":3.1415926535,"d":"test","e":false,"f":true,"g":[1,2,3],"h":{"z":0},"i":null}');
        Test.stopTest();
    }
}