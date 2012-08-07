public with sharing class OAuthAuthorizeTestController {
    public Boolean authSuccess { get; set; }
    public String message { get; set; }

    public PageReference completeAuthorization() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        // success
        if (parameters.containsKey('oauth_token')) {
            String oauth_token = parameters.get('oauth_token');
            OAuth oa = OAuth1.newInstanceByToken(oauth_token);
            if (!parameters.containsKey('@test')) this.authSuccess = oa.complete(parameters);
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
            if (!parameters.containsKey('@test')) this.authSuccess = oa.complete(parameters);
        // error
        } else {
            this.authSuccess = false;
            this.message = 'OAuth2 error: state = null';
        }
        return null;
    }
}