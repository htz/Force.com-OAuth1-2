public virtual class OAuth1Exception extends OAuthException {
    public String oauth_problem { get; set; }

    public OAuth1Exception(String oauth_problem, String message, HttpResponse response) {
        super(message, response);
        this.oauth_problem = oauth_problem;
        setWwwAuthenticate();
    }
    public OAuth1Exception(String oauth_problem, String message) {
        this(oauth_problem, message, null);
    }
    public OAuth1Exception(HttpResponse response) {
        this(null, null, response);
    }

    private void setWwwAuthenticate() {
        if (this.response != null) {
            String header = getWWWAuthenticateHeader();
            System.debug('WWW-Authenticate = ' + header);
            if (header != null) {
                String oauth_problem = header.replaceAll('.*oauth_problem="([^"]*)".*', '$1');
                if (this.oauth_problem == null) {
                    this.oauth_problem = oauth_problem;
                }
            }
        }
    }
}