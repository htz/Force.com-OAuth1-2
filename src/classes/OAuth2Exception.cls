public virtual class OAuth2Exception extends OAuthException {
    public String error { get; set; }
    public String error_uri { get; set; }
    public String scope { get; set; }
    public String state { get; set; }

    public OAuth2Exception(String error, String error_description, String error_uri, String scope, String state, HttpResponse response) {
        super(error_description, response);
        this.error = error;
        this.error_uri = error_uri;
        this.scope = scope;
        setWwwAuthenticate();
    }
    public OAuth2Exception(String error, String error_description, String error_uri, String scope, String state) {
        this(error, error_description, error_uri, scope, state, null);
    }
    public OAuth2Exception(Map<String, String> parameters, HttpResponse response) {
        this(
            parameters.get('error'),
            parameters.get('error_description'),
            parameters.get('error_uir'),
            parameters.get('scope'),
            parameters.get('state'),
            response
        );
    }
    public OAuth2Exception(Map<String, String> parameters) {
        this(
            parameters.get('error'),
            parameters.get('error_description'),
            parameters.get('error_uir'),
            parameters.get('scope'),
            parameters.get('state')
        );
    }
    public OAuth2Exception(HttpResponse response) {
        this(new Map<String, String>(), response);
    }

    private void setWwwAuthenticate() {
        if (this.response != null) {
            String header = getWWWAuthenticateHeader();
            System.debug('WWW-Authenticate = ' + header);
            if (header != null) {
                String error = header.replaceAll('.*error="([^"]*)".*', '$1');
                String error_desc = header.replaceAll('.*error-desc="([^"]*)".*', '$1');
                String error_uri = header.replaceAll('.*error-uri="([^"]*)".*', '$1');
                String scope = header.replaceAll('.*scope="([^"]*)".*', '$1');
                if (this.error == null) {
                    this.error = error;
                }
                if (this.getMessage() == null) {
                    this.setMessage(error_desc);
                }
                if (this.error_uri == null) {
                    this.error_uri = error_uri;
                }
                if (this.scope == null) {
                    this.scope = scope;
                }
            }
        }
    }
}