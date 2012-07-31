public with sharing class OAuthAuthorizeTestController {
    public Boolean authSuccess { get; set; }
    public String message { get; set; }
    public String errorUrl { get; set; }

    public String service { get; set; }
    private Map<Id, OAuthService__c> services {
        get {
            if(services == null) {
                services = new Map<Id, OAuthService__c>(); 
                for(OAuthService__c o : [Select Name, RecordTypeId From OAuthService__c]) {
                    services.put(o.Id, o);
                }
            }
            return services;
        }
        set;
    }
    public List<SelectOption> serviceOptions {
        get {
            if (serviceOptions == null) {
                List<OAuthService__c> l = [Select Name, RecordTypeId From OAuthService__c];
                serviceOptions = new List<SelectOption>();
                for (OAuthService__c obj : l) {
                    serviceOptions.add(new SelectOption(obj.Id, obj.Name));
                }
            }
            return serviceOptions;
        }
        set;
    }

    public PageReference authorize() {
        ID serviceId = service;
        try {
            OAuth oa = OAuth.newInstance(serviceId);
            PageReference ret = oa.authorization();
            if (ret == null) {
                this.message = oa.message;
            }
            return ret;
        } catch (OAuthException e) {
            this.message = e.getMessage();
            return null;
        }
    }

    public PageReference completeAuthorization() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        // success
        if (parameters.containsKey('oauth_token')) {
            String oauth_token = parameters.get('oauth_token');
            OAuth oa = OAuth1.newInstanceByToken(oauth_token);
            this.authSuccess = oa.complete(parameters);
        // error
        } else {
            this.authSuccess = false;
            this.message = 'OAuth1 error: oauth_token = null';
        }
        return null;
    }

    public PageReference completeAuthorization2() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        // success
        if (parameters.containsKey('state')) {
            Id serviceId = parameters.get('state');
            OAuth oa = OAuth.newInstance(serviceId);
            this.authSuccess = oa.complete(parameters);
        // error
        } else {
            this.authSuccess = false;
            this.message = 'OAuth2 error: state = null';
        }
        return null;
    }
}