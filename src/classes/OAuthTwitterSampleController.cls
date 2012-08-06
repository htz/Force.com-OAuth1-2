public class OAuthTwitterSampleController {
    private OAuth oa;
    public String status { get; set; }

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

    public OAuthJSON getFeed() {
        try {
            HttpResponse res = oa.get('https://api.twitter.com/1/statuses/home_timeline.json');
            String body = res.getBody();
            OAuthJSON json = null;
            if (body != null && body != '') {
                json = OAuthJSON.newInstance(body);
            }
            return json;
        } catch (OAuthException e) {
            return null;
        }
    }

    public PageReference post() {
        if (status == null || status == '') return null;
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://api.twitter.com/1/statuses/update.json');
        req.setMethod('POST');
        req.setBody('status=' + EncodingUtil.urlEncode(status, 'UTF-8'));
        try {
            HttpResponse res = oa.rest(req);
            status = '';
        } catch (OAuthException e) {
        }
        return null;      
    }
}