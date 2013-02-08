public class OAuthTwitterSampleController {
    private OAuth oa;
    public String status { get; set; }

    public OAuthTwitterSampleController() {
        oa = OAuth.newInstance('Twitter');
    }

    public PageReference init() {
        PageReference p = Page.OAuthTwitterSample;
        p.setRedirect(true);
        if (oa.isCompleteUrl()) {
            oa.complete();
        } else if (!oa.hasToken()) {
            p = oa.authorization();
        } else {
            p = null;
        }
        return p;
    }

    public OAuthJSON getFeed() {
        OAuthJSON json = null;
        try {
            HttpResponse res = null;
            String body = null;
            if (!System.currentPageReference().getParameters().containsKey('@test')) {
                res = oa.get('https://api.twitter.com/1.1/statuses/home_timeline.json');
                body = res.getBody();
            } else {
                body = '[]';
            }
            if (body != null && body != '') {
                json = OAuthJSON.newInstance(body);
            }
        } catch (OAuthException e) {
        }
        return json;
    }

    public PageReference post() {
        if (status == null || status == '') return null;
        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://api.twitter.com/1.1/statuses/update.json');
        req.setMethod('POST');
        req.setBody('status=' + EncodingUtil.urlEncode(status, 'UTF-8'));
        try {
            if (!System.currentPageReference().getParameters().containsKey('@test')) {
                oa.rest(req);
            }
            status = '';
        } catch (OAuthException e) {
        }
        return null;      
    }
}