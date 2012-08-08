public with sharing class OAuthCompleteController {
    public Boolean authSuccess { get; set; }
    public String message { get; set; }

    public PageReference complete() {
        Map<String, String> parameters = ApexPages.currentPage().getParameters();
        // success OAuth1.0
        if (parameters.containsKey('oauth_token')) {
            String oauth_token = parameters.get('oauth_token');
            OAuth oa = OAuth1.newInstanceByToken(oauth_token);
            if (!parameters.containsKey('@test')) this.authSuccess = oa.complete(parameters);
        // success OAuth2.0 (state=serviceId)
        } else if (parameters.containsKey('state')) {
            Id serviceId = parameters.get('state');
            OAuth oa = OAuth.newInstance(serviceId);
            if (!parameters.containsKey('@test')) this.authSuccess = oa.complete(parameters);
        // error
        } else {
            this.authSuccess = false;
            this.message = 'OAuth1 error: oauth_token = null';
        }
        return null;
    }
}