public class OAuth2TesterException extends OAuth2Exception {
    public OAuth2TesterException(Map<String, String> parameters) {
        super(parameters);
    }
    public OAuth2TesterException(HttpResponse response) {
        super(response);
    }

    protected override String getWWWAuthenticateHeader() {
        return 'OAuth error="error", error-desc="desc", error-uri="http://error/", scope="full"';
    }
}