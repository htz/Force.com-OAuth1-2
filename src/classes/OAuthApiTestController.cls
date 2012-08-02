public class OAuthApiTestController {
    public OAuthServiceAPI__c api { get; set; }
    public List<String> debugs { get; set; }

    public String request_body { get; set; }
    public String response { get; set; }
    public Map<String, String> response_headers { get; set; }
    public String response_body { get; set; }

    public OAuthApiTestController() {
        api = new OAuthServiceAPI__c();
        debugs = new List<String>();
    }

    public String method { get;set; }
    public List<SelectOption> methodOptions {
        get {
            if(methodOptions == null) {
                methodOptions = new List<SelectOption>{
                    new SelectOption('GET', 'GET'),
                    new SelectOption('POST', 'POST'),
                    new SelectOption('PUT', 'PUT'),
                    new SelectOption('DELETE', 'DELETE')
                };
            }
            return methodOptions;
        }
        set;
    }

    private Map<Id, OAuthService__c> services {
        get {
            if(services == null) {
                services = new Map<Id, OAuthService__c>(); 
                for(OAuthService__c o : [
                    Select
                        Name, 
                        (Select Name, Url__c, Body__c, Content_Type__c, Method__c From Saved_URLs__r) 
                    From
                        OAuthService__c
                ]) {
                    services.put(o.Id, o);
                }
            }
            return services;
        }
        set;
    }
    public String service { 
        get;
        set {
            serviceUrls = null;
            if (value == '') value = null;
            service = value;
            api = new OAuthServiceAPI__c();
        }
    }
    public List<SelectOption> serviceOptions {
        get {
            serviceOptions = new List<SelectOption>{new SelectOption('', '')};
            for(OAuthService__c o : services.values()) {
                serviceOptions.add(new SelectOption(o.Id, o.Name));
            }
            return serviceOptions;
        }
        set;
    }

    private Map<Id, OAuthServiceAPI__c> serviceUrls {
        get {
            if (serviceUrls == null) {
                serviceUrls = new Map<Id, OAuthServiceAPI__c>();
                if(service != null) {
                    for(OAuthServiceAPI__c u : services.get(service).saved_urls__r) {
                        serviceUrls.put(u.Id, u);
                    }
                }
            }
            return serviceUrls;
        }
        set;
    }
    public String serviceUrl { 
        get;
        set {
            if (value == '') value = null;
            serviceUrl = value;
        }
    }
    public List<SelectOption> serviceUrlOptions {
        get {
            List<SelectOption> options = new List<SelectOption>{new SelectOption('', '')};
            if(service != null) {
                for(OAuthServiceAPI__c u : serviceUrls.values()) {
                    options.add(new SelectOption(u.Id, u.Name));
                }
            }
            return options;
        }
    }

    public PageReference execute() {
        if (api.Url__c == null || api.Url__c == '') {
            debug('Error: url = null');
            return null;
        }
        debug('Method: ' + api.Method__c + ', Service: ' + service + ', URL: ' + api.Url__c);
        HttpRequest req = new HttpRequest();
        req.setMethod(api.Method__c);
        req.setEndpoint(api.Url__c);
        if(api.Method__c == 'POST' || api.Method__c == 'PUT') {
            req.setBody(api.Body__c);
            req.setHeader('Content-Type', api.Content_Type__c);
        }
        Id serviceId = service;
        try {
            OAuth oa = OAuth.newInstance(serviceId);
            HttpResponse res = oa.rest(req);
            setResult(req, res);
        } catch (OAuthException e) {
            setResult(req, e.response);            
        }
        return null;
    }

    private void setResult(HttpRequest req, HttpResponse res) {
            request_body = req.getBody();
            response = 'HTTP/1.1 ' + res.getStatusCode() + ' ' + res.getStatus();
            response_headers = getResponseHeaders(res);
            response_body = res.getBody();
    }

    private Map<String, String> getResponseHeaders(HttpResponse res) {
        Map<String, String> headers = new Map<String, String>();
        for (String key : res.getHeaderKeys()) {
            if (key == null) continue;
            headers.put(key, res.getHeader(key));
        }
        return headers;
    }

    public PageReference loadURL() {
        api = serviceUrls.get(serviceUrl);
        return null;
    }

    private void debug(String str) {
        debugs.add(str);
    }
}