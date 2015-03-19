global class OAuthCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        if (req.getEndpoint() == 'https://test/oauth1/token') {
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('oauth_token=token&oauth_token_secret=token_secret&test=1');
            res.setStatusCode(200);
        } else if (req.getEndpoint() == 'https://test/oauth2/token') {
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('access_token=token&tokey_type=test&expires_in=3600&refresh_token=refresh&scope=test');
            res.setStatusCode(200);
        } else if (req.getEndpoint() == 'https://example/error/400') {
            res.setStatusCode(400);
        } else {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(200);
        }
        return res;
    }
}