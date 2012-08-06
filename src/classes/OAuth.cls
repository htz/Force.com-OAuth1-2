public virtual class OAuth {
    protected OAuthService__c service;
    public String message { get; set; }

    public OAuth() {}

    public OAuth(OAuthService__c service) {
        this.service = service;
        if (service == null) {
            System.debug('Couldn\'t find Oauth Service');
            this.message = 'Service was not found in the local configuration';
        }
    }

    public static OAuth newInstance(OAuthService__c service) {
        OAuth oa = null;
        Schema.DescribeSObjectResult d = Schema.SObjectType.OAuthService__c;
        Map<String, Schema.RecordTypeInfo> rti = d.getRecordTypeInfosByName();

        try {
            if (service.RecordTypeId == rti.get('OAuth1').getRecordTypeId()) {
                oa = new OAuth1(service.Id);
            } else if (service.RecordTypeId == rti.get('OAuth2').getRecordTypeId()) {
                oa = new OAuth2(service.Id);
            }
        } catch (OAuthException e) {
        }

        return oa;
    }
    public static OAuth newInstance(Id serviceId) {
        OAuthService__c service = [Select RecordTypeId From OAuthService__c Where Id = :serviceId Limit 1];
        return newInstance(service);
    }
    public static OAuth newInstance(String name) {
        OAuthService__c service = [Select RecordTypeId From OAuthService__c Where Name = :name Limit 1];
        return newInstance(service);
    }

    public virtual PageReference authorization() {
        return null;
    }

    public virtual Boolean isCompleteUrl() {
        PageReference current = ApexPages.currentPage();
        if (current != null) {
            String host = current.getHeaders().get('Host');
            String url = 'https://' + host + current.getUrl();
            if (url.startsWith(service.Redirect_URL__c)) {
                return true;
            }
        }
        return false;
    }

    public virtual Boolean complete(Map<String, String> parameters) {
        return false;
    }
    public virtual Boolean complete() {
        return complete(ApexPages.currentPage().getParameters());
    }

    protected Map<String, String> splitParameters(String value) {
        if (value == null || value == '') {
            return new Map<String, String>();
        }
        PageReference tmp = new PageReference('http://localhost/?' + value);
        return tmp.getParameters();
    }

    protected Map<String, String> getJsonParameters(String value) {
        Map<String, String> parameters = null;
        JSONParser parser = JSON.createParser(value);
        if (parser.nextToken() == JSONToken.START_OBJECT) {
            parameters = new Map<String, String>();
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                String key = parser.getText();
                parser.nextToken();
                if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                    parameters.put(key, parser.getText());
                } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                    parameters.put(key, '' + parser.getIntegerValue());
                } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_FLOAT) {
                    parameters.put(key, '' + parser.getDoubleValue());
                } else if (parser.getCurrentToken() == JSONToken.VALUE_TRUE || parser.getCurrentToken() == JSONToken.VALUE_FALSE) {
                    parameters.put(key, '' + parser.getBooleanValue());
                } else if (parser.getCurrentToken() == JSONToken.VALUE_NULL) {
                    parameters.put(key, null);
                } else if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    passParser(parser);
                    parameters.put(key, '[Object]');
                } else if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    passParser(parser);
                    parameters.put(key, '[Array]');
                } else {
                    return null;
                }
            }
        }
        return parameters;
    }
    private void passParser(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT && parser.getCurrentToken() != JSONToken.END_ARRAY) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT || parser.getCurrentToken() == JSONToken.START_ARRAY) {
                passParser(parser);
            }
        }
    }

    public virtual Boolean hasToken() {
        return false;
    }

    public virtual HttpResponse rest(HttpRequest req) {
        return null;
    }
    public HttpResponse rest(String method, String url, String body) {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(url);
        if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
            req.setBody(body);
        }
        return rest(req);
    }
    public HttpResponse get(String url) {
        return rest('GET', url, null);
    }
    public HttpResponse head(String url) {
        return rest('HEAD', url, null);
    }
    public HttpResponse del(String url) {
        return rest('DELETE', url, null);
    }
    public HttpResponse post(String url, String body) {
        return rest('POST', url, body);
    }
    public HttpResponse put(String url, String body) {
        return rest('PUT', url, body);
    }
    public HttpResponse patch(String url, String body) {
        return rest('PATCH', url, body);
    }

    protected virtual HttpResponse send(HttpRequest req) {
        return new Http().send(req);
    }
    protected virtual String getResponseBody(HttpResponse res) {
        //'oauth_token=token&oauth_token_secret=token_secret'
        return res.getBody();
    }
    protected virtual Integer getStatusCode(HttpResponse res) {
        return res.getStatusCode();
    }
    protected virtual String getContentType(HttpResponse res) {
        return res.getHeader('Content-Type');
    }
}