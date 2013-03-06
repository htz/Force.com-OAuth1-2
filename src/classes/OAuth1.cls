public virtual class OAuth1 extends OAuth {
    private OAuth_Token__c token;

    public OAuth1() {
    }
    public OAuth1(Id serviceId, Id userId) {
        this();
        try {
            service = [
                Select
                    Name,
                    Request_Token_URL__c, Authorization_URL__c, Access_Token_URL__c, Redirect_URL__c,
                    Consumer_Key__c, Consumer_Secret__c, Signature_Method__c,
                    (Select OAuth_Token__c, OAuth_Token_Secret__c, isAccess__c FROM OAuth_Tokens__r WHERE Owner__c = :userId Order By CreatedDate DESC Limit 1)
                From
                    OAuthService__c
                WHERE
                    Id = :serviceId
                Limit 1
            ];
            if (service.OAuth_Tokens__r.size() > 0) {
                token = service.OAuth_Tokens__r.get(0);
            }
        } catch (Exception e) {
            throw new OAuth1Exception('no service');
        }
    }
    public OAuth1(Id serviceId) {
        this(serviceId, UserInfo.getUserId());
    }

    public static OAuth1 newInstanceByToken(String token) {
        System.debug('Completing authorization for request token ' + token);
        try {
            Id userId = UserInfo.getUserId();
            OAuth_Token__c t = [Select Id, Oauth_Service__r.Id From OAuth_Token__c Where Owner__c = :userId And OAuth_Token__c = :token Order By CreatedDate DESC Limit 1];
            return new OAuth1(t.Oauth_Service__r.Id);
        } catch (System.QueryException e) {
            throw new OAuth1Exception('no token');
        }
    }

    public override PageReference authorization(Map<String, String> parameters) {
        token = null;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(service.Request_Token_URL__c);
        req.setBody('');
        if (service.Redirect_URL__c == null) {
            service.Redirect_URL__c = 'oob';
        }
        HttpResponse res = signSend(req, new Map<String, String>{'oauth_callback' => service.Redirect_URL__c});
        System.debug('Response from request token request: (' + getStatusCode(res) + ')' + getResponseBody(res));
        if (getStatusCode(res) > 299) {
            throw new OAuth1Exception(res);
        }

        Map<String, String> rp = splitParameters(getResponseBody(res));
        OAuth_Token__c t = new OAuth_Token__c(
            Owner__c = UserInfo.getUserId(),
            OAuth_Service__c = service.Id,
            OAuth_Token__c = rp.get('oauth_token'),
            OAuth_Token_Secret__c = rp.get('oauth_token_secret'),
            isAccess__c = false
        );
        insert t;

        PageReference redirect = new PageReference(service.Authorization_URL__c);
        redirect.getParameters().put('oauth_token', t.OAuth_Token__c);
        redirect.getParameters().put('oauth_consumer_key', service.Consumer_Key__c);
        if (service.Redirect_URL__c != null) {
            redirect.getParameters().put('oauth_callback', service.Redirect_URL__c);
        }
        return redirect;
    }

    public override Boolean isCompleteUrl() {
        PageReference current = currentPage();
        if (super.isCompleteUrl() && current.getParameters().containsKey('oauth_token')) {
            return true;
        }
        return false;
    }

    public override Boolean complete(Map<String, String> parameters) {
        String oauth_token = parameters.get('oauth_token');
        String oauth_verifier = parameters.get('oauth_verifier');
        if (oauth_token == null) {
            throw new OAuthException();
        }
        return getAccessToken(oauth_verifier);
    }

    public Boolean getAccessToken(String verifier) {
        if (verifier == null) {
            verifier = '';
        }
        System.debug('Completing authorization for request verifier = ' + verifier);

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(service.Access_Token_URL__c);
        req.setBody('');
        HttpResponse res = signSend(req, new Map<String, String>{'oauth_verifier' => verifier});
        System.debug('Response from request token request: (' + getStatusCode(res) + ')' + getResponseBody(res));
        if (getStatusCode(res) > 299) {
            throw new OAuth1Exception(res);
        }

        String res_body = getResponseBody(res);
        Map<String, String> rp = splitParameters(res_body);
        token.OAuth_Token__c = rp.get('oauth_token');
        token.OAuth_Token_Secret__c = rp.get('oauth_token_secret');
        token.isAccess__c = true;

        List<OAuth_Token_Variable__c> variables = new List<OAuth_Token_Variable__c>();
        for (String key : rp.keySet()) {
            if (key == 'oauth_token' || key == 'oauth_token_secret') continue;
            variables.add(new OAuth_Token_Variable__c(
                Name = key,
                OAuth_Token__c = token.Id,
                Value__c = rp.get(key)
            ));
        }
        upsert variables;

        update token;

        return true;
    }

    private static final String NONCE_CHARS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    private static final Integer NONCE_LENGTH = 42;
    private String generateNonce() {
        List<String> chars = NONCE_CHARS.split(''); /* index 0 is empty */
        String nonce = '';
        for (Integer i = 0; i < NONCE_LENGTH; i++) {
            nonce += chars[Math.floor(Math.random() * (chars.size() - 1)).intValue() + 1];
        }
        return nonce;
    }

    private Map<String, String> getSignParameters() {
        Map<String, String> parameters = new Map<String, String>();
        parameters.put('oauth_consumer_key', service.Consumer_Key__c);
        if (token != null && token.OAuth_Token__c != null) {
            parameters.put('oauth_token', token.OAuth_Token__c);
        }
        parameters.put('oauth_signature_method', service.Signature_Method__c);
        parameters.put('oauth_timestamp', String.valueOf(DateTime.now().getTime() / 1000));
        parameters.put('oauth_nonce', generateNonce());
        parameters.put('oauth_version', '1.0');
        return parameters;
    }

    public HttpResponse signSend(HttpRequest req) {
        return signSend(req, null);
    }
    public HttpResponse signSend(HttpRequest req, Map<String, String> parameters) {
        String method = req.getMethod();
        if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
            if (req.getHeader('Content-Type') == null || req.getHeader('Content-Type') == '') {
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded; charset=utf-8');
            }
        }
        Map<String, String> sign_parameters = getSignParameters();
        OAuthSign sign = new OAuthSign(sign_parameters);
        sign.put(parameters);
        String header = sign.getAuthorizationHeader(req, service.Consumer_Secret__c, (token != null && token.OAuth_Token_Secret__c != null ? token.OAuth_Token_Secret__c : ''));
        System.debug('Authorization: ' + header);
        req.setHeader('Authorization', header);
        return send(req);
    }

    public override Boolean hasToken() {
        return this.token != null && this.token.isAccess__c;
    }

    public override HttpResponse rest(HttpRequest req) {
        return signSend(req);
    }
}