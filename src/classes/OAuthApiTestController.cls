public class OAuthApiTestController {
    public String body { get; set; }
    public String postParam { get; set; }
    public String url { get; set; }
    public String message { get; set; }
    public String debug { get;set; }

    public OAuthApiTestController() {
        debug = '';
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
                        (Select Id, Name, url__c, body__c, isform__c, method__c From Saved_URLs__r) 
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
            url = '';
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

    private Map<Id, Saved_URL__c> serviceUrls {
        get {
            if (serviceUrls == null) {
                serviceUrls = new Map<Id, Saved_URL__c>();
                if(service != null) {
                    for(Saved_URL__c u : services.get(service).saved_urls__r) {
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
            url = value;
        }
    }
    public List<SelectOption> serviceUrlOptions {
        get {
            List<SelectOption> options = new List<SelectOption>{new SelectOption('', '')};
            if(service != null) {
                for(Saved_URL__c u : serviceUrls.values()) {
                    options.add(new SelectOption(u.Id, u.Name));
                }
            }
            return options;
        }
    }

    public PageReference execute() {
        addDebug('Method: ' + method + ', Service: ' + service + ', URL: ' + url);
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(url);
        if(method == 'POST' || method == 'PUT') {
            if(postParam !=null & postParam != '') {
                req.setBody(postParam);
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            } else {
                req.setBody(body);
            }
        }
        Id serviceId = service;
        try {
            OAuth oa = OAuth.newInstance(serviceId);
            addDebug('Sending request...');
            HttpResponse res = oa.rest(req);
            body = res.getBody();
            message = '';
        } catch (OAuthException e) {
            message = e.getMessage();
        }
        return null;
    }

    public PageReference saveURL() {
        if (service != null) {
            Saved_URL__c s = new Saved_URL__c(
                oauth_service__c = service,
                url__c = url,
                method__c = method
            );
            if(postParam !=null && postParam != '') {
                s.body__c = postParam;
                s.isform__c = true;
            } else {
                s.body__c = body;
                s.isform__c = false;
            }
            insert s;
            serviceUrls = null;
        }
        return null;
    }

    public PageReference loadURL() {
        Saved_URL__c serviceUrlObj = serviceUrls.get(serviceUrl);
        if (serviceUrlObj != null) {
            url = serviceUrlObj.url__c;
            method = serviceUrlObj.method__c;
            if(serviceUrlObj.isform__c) {
                postParam = serviceUrlObj.body__c;
            } else {
                body = serviceUrlObj.body__c;
            }
        }
        return null;
    }

    private void addDebug(String str) {
        System.debug('============' + str);
        debug += str;
    }
}