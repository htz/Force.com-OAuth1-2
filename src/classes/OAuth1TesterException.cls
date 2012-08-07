public class OAuth1TesterException extends OAuth1Exception {
    public OAuth1TesterException(String oauth_problem, String message) {
        super(oauth_problem, message);
    }

    public OAuth1TesterException(HttpResponse response) {
        super(response);
    }

    protected override String getWWWAuthenticateHeader() {
        return 'oauth_problem="test error"';
    }
}