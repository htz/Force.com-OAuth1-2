trigger OAuthServiceTrigger on OAuthService__c (before insert, before update) {
    URL base = System.URL.getSalesforceBaseUrl();
    for (OAuthService__c s : Trigger.new) {
        if (s.Redirect_URL__c == null) continue;
        Integer substring_index = 0;
        System.debug(s.Redirect_URL__c);
        if (!s.Redirect_URL__c.startsWith('/')) continue;
        s.Redirect_URL__c = base.getProtocol() + '://' + base.getHost () + s.Redirect_URL__c;
    }
}