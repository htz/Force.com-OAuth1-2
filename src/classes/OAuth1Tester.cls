public class OAuth1Tester extends OAuth1 {
    private static final String DEFAULT_URL = 'http://test/?oauth_token=token';
    public PageReference current { get; set; }
    public List<Response> responses { get; set; }

    public OAuth1Tester(OAuthService__c s, PageReference current, List<Response> responses) {
        super(s.Id);
        this.current = current;
        this.responses = responses;
    }
    public OAuth1Tester(OAuthService__c s, String url, List<Response> responses) {
        this(s, new PageReference(url), responses);
    }
//    public OAuth1Tester(OAuthService__c s, List<Response> responses) {
//        this(s, DEFAULT_URL, responses);
//    }
    public OAuth1Tester(OAuthService__c s, PageReference current, Response response) {
        this(s, current, new List<Response> {response});
    }
//    public OAuth1Tester(OAuthService__c s, String url, Response response) {
//        this(s, new PageReference(url), response);
//    }
    public OAuth1Tester(OAuthService__c s, Response response) {
        this(s, DEFAULT_URL, new List<Response> {response});
    }
    public OAuth1Tester(OAuthService__c s, PageReference current) {
        this(s, current, new Response());
    }
    public OAuth1Tester(OAuthService__c s, String url) {
        this(s, new PageReference(url), new Response());
    }
    public OAuth1Tester(OAuthService__c s) {
        this(s, DEFAULT_URL);
    }

    protected override PageReference currentPage() {
        return current;
    }

    public override HttpResponse send(HttpRequest req) {
        return new HttpResponse();
    }
    public override String getResponseBody(HttpResponse res) {
        String body = 'oauth_token=token&oauth_token_secret=token_secret&test=1';
        if (responses.size() > 0) {
            body = responses[0].body;
        }
        return body;
    }
    public override Integer getStatusCode(HttpResponse res) {
        Integer code = 200;
        if (responses.size() > 0) {
            code = responses[0].code;
        }
        return code;
    }
//    public override String getContentType(HttpResponse res) {
//        String ctype = '';
//        if (responses.size() > 0) {
//            ctype = responses[0].ctype;
//        }
//        return ctype;
//    }
//    public void doneResponse() {
//        if (responses.size() > 0) {
//            responses.remove(0);
//        }
//    }

    public class Response {
        public String body { get; set; }
        public Integer code { get; set; }
        public String ctype { get; set; }

        public Response(String body, Integer code, String ctype) {
            this.body = body;
            this.code = code;
            this.ctype = ctype;
        }
        public Response(String body, Integer code) {
            this(body, code, 'application/x-www-form-urlencoded');
        }
        public Response() {
            this('oauth_token=token&oauth_token_secret=token_secret&test=1', 200);
        }
    }
}