public with sharing class OAuthAuthorizeController {
    private OAuthService__c service;

    public OAuthAuthorizeController(ApexPages.StandardController controller) {
        service = (OAuthService__c)controller.getRecord();
    }

    public PageReference init() {
        try {
            OAuth oa = OAuth.newInstance(service);
            return oa.authorization();
        } catch (OAuthException e) {
            return new PageReference('/' + service.Id);
        }
    }
}