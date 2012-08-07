public with sharing class OAuthAuthorizeController {
    private OAuthService__c service;

    public OAuthAuthorizeController(ApexPages.StandardController controller) {
        service = (OAuthService__c)controller.getRecord();
    }

    public PageReference init() {
        PageReference redirect = new PageReference('/' + service.Id);
        try {
            OAuth oa = OAuth.newInstance(service);
            redirect = oa.authorization();
        } catch (OAuthException e) {
        }
        return redirect;
    }
}