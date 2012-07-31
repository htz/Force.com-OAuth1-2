public class OAuth2 extends OAuth {
    private OAuth2_Token__c token;

    public OAuth2() {
    }
    public OAuth2(Id serviceId) {
        this(serviceId, UserInfo.getUserId());
    }
    public OAuth2(Id serviceId, Id userId) {
        try {
            service = [
                Select
                    Name, Response_Type__c, Consumer_Key__c, Consumer_Secret__c,
                    Authorization_URL__c, Access_Token_URL__c, Redirect_URL__c, Scope__c, State__c,
                    (Select Access_Token__c, Refresh_Token__c, Expires_In__c FROM OAuth2_Tokens__r WHERE Owner__c = :userId Order By CreatedDate DESC Limit 1)
                From
                    OAuthService__c
                WHERE
                    Id = :serviceId
            ];
            if (service.OAuth2_Tokens__r.size() > 0) {
                token = service.OAuth2_Tokens__r.get(0);
            }
        } catch (Exception e) {
            throw new OAuth2Exception('no service');
        }
    }

    public override PageReference authorization() {
        PageReference redirect = new PageReference(service.Authorization_URL__c);
        redirect.getParameters().put('response_type', service.Response_Type__c);
        redirect.getParameters().put('client_id', service.Consumer_Key__c);
        if (service.Redirect_URL__c != null) {
            redirect.getParameters().put('redirect_uri', service.Redirect_URL__c);
        }
        if (service.Scope__c != null) {
            redirect.getParameters().put('scope', service.Scope__c);
        }
        if (service.State__c != null) {
            redirect.getParameters().put('state', service.State__c);
        }
        return redirect;
    }

    public override Boolean isCompleteUrl() {
        PageReference current = ApexPages.currentPage();
        if (super.isCompleteUrl() && current.getParameters().containsKey('code')) {
            return true;
        }
        return false;
    }

    public override Boolean complete(Map<String, String> parameters) {
        // error
        if (parameters.containsKey('error')) {
            throw new OAuth2Exception(parameters);
        }
        String code = parameters.get('code');
        return getAccessTokenAuthorizationCode(code);
    }

    private String getAccessTokenCommonBody(String grant_type, String scope) {
        String body =
            'grant_type=' + grant_type +
            '&client_id=' + EncodingUtil.urlEncode(service.Consumer_Key__c, 'UTF-8');
        if (scope != null) {
            body += '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8');
        }
        return body;
    }
    private String getAccessTokenCommonBody(String grant_type) {
        return getAccessTokenCommonBody(grant_type, null);
    }

    /* grant_type=authorization_code */
    public Boolean getAccessTokenAuthorizationCode(String code) {
        String body =
            getAccessTokenCommonBody('authorization_code', service.Scope__c) + // scope間違い
            '&client_secret=' + EncodingUtil.urlEncode(service.Consumer_Secret__c, 'UTF-8') +
            '&code=' + EncodingUtil.urlEncode(code, 'UTF-8');
        if (service.Redirect_URL__c != null) {
            body += '&redirect_uri=' + EncodingUtil.urlEncode(service.Redirect_URL__c, 'UTF-8');
        }
        token = getAccessToken(body);
        insert token;
        return true;
    }

    /* grant_type=password */
    public Boolean getAccessTokenAuthorizationPassword(String username, String password) {
        String body =
            getAccessTokenCommonBody('password', service.Scope__c) + // scope間違い
            '&client_secret=' + EncodingUtil.urlEncode(service.Consumer_Secret__c, 'UTF-8') +
            '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');
        token = getAccessToken(body);
        insert token;
        return true;
    }

    /* grant_type=assertion */
    public Boolean getAccessTokenAuthorizationAssertion(String assertion_type, String assertion) {
        String body =
            getAccessTokenCommonBody('assertion', service.Scope__c) + // scope間違い
            '&assertion_type=' + EncodingUtil.urlEncode(assertion_type, 'UTF-8') +
            '&assertion=' + EncodingUtil.urlEncode(assertion, 'UTF-8');
        token = getAccessToken(body);
        insert token;
        return true;
    }

    /* grant_type=refresh_token */
    public Boolean getAccessTokenRefreshToken() {
        if (token == null || token.Refresh_Token__c == null) {
            return false;
        }
        String body =
            getAccessTokenCommonBody('refresh_token', service.Scope__c) + // scope間違い
            '&refresh_token=' + EncodingUtil.urlEncode(token.Refresh_Token__c, 'UTF-8');
        OAuth2_Token__c t = getAccessToken(body);
        if (t.Access_Token__c != null) {
            token.Access_Token__c = t.Access_Token__c;
        }
        if (t.Expires_In__c != null) {
            token.Expires_In__c = t.Expires_In__c;
        }
        if (t.Refresh_Token__c != null) {
            token.Refresh_Token__c = t.Refresh_Token__c;
        }
        if (t.Scope__c != null) {
            token.Scope__c = t.Scope__c;
        }
        return true;
    }

    private OAuth2_Token__c getAccessToken(String body) {
        System.debug('getAccessToken body: ' + body);
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setEndpoint(service.Access_Token_URL__c);
        req.setBody(body);
        HttpResponse res = send(req);

        String res_body = getResponseBody(res);
        String res_content_type = getContentType(res);
        System.debug('res_body(' + res_content_type+ ') = ' + res_body);
        if (res_body == null) {
            throw new OAuth2Exception('res_body = null');
        }

        Map<String,String> parameters;
        if (res_content_type != null && res_content_type.startsWith('application/json')) {
            parameters = getJsonParameters(res_body);
        } else {
            parameters = splitParameters(res_body);
        }
        String error = parameters.get('error');
        if (error != null) {
            throw new OAuth2Exception(parameters, res);
        }
        if (!parameters.containsKey('access_token')) {
            throw new OAuth2Exception(null, 'access_toke = null', null, null, null, res);
        }

        String expires_in_str = parameters.get('expires_in');
        Integer expires_in = null;
        if (expires_in_str != null) {
            expires_in = Integer.valueOf(expires_in_str);
        }

        OAuth2_Token__c t = new OAuth2_Token__c(
            Owner__c = UserInfo.getUserId(),
            OAuth_Service__c = service.Id,
            Access_Token__c = parameters.get('access_token'),
            Expires_In__c = expires_in,
            Refresh_Token__c = parameters.get('refresh_token'),
            Scope__c = parameters.get('scope')
        );
        return t;
    }

    public override Boolean hasToken() {
        return this.token != null;
    }

    public override HttpResponse rest(HttpRequest req) {
        if (token != null) {
            req.setHeader('Authorization', 'OAuth ' + token.Access_Token__c);
        }
        HttpResponse res = send(req);
        Integer status_code = res.getStatusCode();
        if (status_code / 100 == 4) {
            OAuth2Exception e = new OAuth2Exception(res); 
            if (/*e.error == 'expired_token' && */getAccessTokenRefreshToken()) {
                req.setHeader('Authorization', 'OAuth ' + token.Access_Token__c);
                res = send(req);
                update token;
                return res;
            }
            throw e;
        }
        return res;
    }
}