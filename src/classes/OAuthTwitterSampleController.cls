public class OAuthTwitterSampleController {
    private OAuth oa;

    public OAuthTwitterSampleController() {
        oa = OAuth.newInstance('Twitter');
    }

    public PageReference init() {
        PageReference p = null;
        if (oa.isCompleteUrl()) {
            oa.complete();
            p = Page.OAuthTwitterSample;
            p.setRedirect(true);
        } else if (!oa.hasToken()) {
            p = oa.authorization();
        }
        return p;
    }

    public String getFeed() {
        try {
            HttpResponse res = oa.get('https://api.twitter.com/1/statuses/home_timeline.json');
            return res.getBody();
        } catch (OAuthException e) {
            return e.getMessage();
        }
    }
}