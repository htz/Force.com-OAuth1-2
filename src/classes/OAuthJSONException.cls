public class OAuthJSONException extends OAuthException {
    public OAuthJSON json { get; set; }

    public OAuthJSONException(OAuthJSON json) {
        super();
        this.json = json;
    }
}