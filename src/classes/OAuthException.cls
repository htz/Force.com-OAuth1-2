public virtual class OAuthException extends Exception {
    public HttpResponse response { get; set; }

    public OAuthException(String message, HttpResponse response) {
        this(message);
        this.response = response;
    }

    protected virtual String getWWWAuthenticateHeader() {
        return this.response.getHeader('WWW-Authenticate');
    }
}