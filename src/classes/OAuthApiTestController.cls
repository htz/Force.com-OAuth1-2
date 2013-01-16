public class OAuthApiTestController {
    public OAuthServiceAPI__c api { get; set; }
    public String api_org_url { get; set; }
    public List< OAuthServiceAPIParameter__c> parameters { get; set; }
    public List< OAuthServiceAPIParameter__c> query_parameters { get; set; }
    public List< OAuthServiceAPIParameter__c> header_parameters { get; set; }
    public List<TemplateParameter> template { get; set; }
    public Map<String, String> template_parameters { get; set; }
    public String action_index { get; set; }
    public List<DebugLog> debugs { get; set; }

    public String request_body { get; set; }
    public String response { get; set; }
    public String response_type { get; set; }
    public Map<String, String> response_headers { get; set; }
    public String response_body { get; set; }

    private Pattern p = Pattern.compile('\\{([^\\}]+)\\}');

    public OAuthApiTestController() {
        api = new OAuthServiceAPI__c();
        template = new List<TemplateParameter>();
        query_parameters = new List<OAuthServiceAPIParameter__c>();
        header_parameters = new List<OAuthServiceAPIParameter__c>();
        template_parameters = new Map<String, String>();
        debugs = new List<DebugLog>();
        response_type = '';
    }

    public String method { get;set; }
    public List<SelectOption> methodOptions {
        get {
            if(methodOptions == null) {
                methodOptions = new List<SelectOption>{
                    new SelectOption('GET', 'GET'),
                    //new SelectOption('HEAD', 'HEAD'),
                    new SelectOption('POST', 'POST'),
                    new SelectOption('PUT', 'PUT'),
                    new SelectOption('DELETE', 'DELETE'),
                    //new SelectOption('OPTIONS', 'OPTIONS'),
                    new SelectOption('TRACE', 'TRACE'),
                    //new SelectOption('CONNECT', 'CONNECT'),
                    new SelectOption('PATCH', 'PATCH')
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
                        (Select Name, Url__c, Body__c, Content_Type__c, Method__c From OAuth_Service_APIs__r Order By Name),
                        (Select Name, Value__c From OAuth_Service_Variable__r)
                    From
                        OAuthService__c
                    Order By
                        Name
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
            if (service == value) return;
            serviceAPIs = null;
            if (value == '') value = null;
            service = value;
            loadServiceAPI();
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

    private Map<Id, OAuthServiceAPI__c> serviceAPIs {
        get {
            if (serviceAPIs == null) {
                serviceAPIs = new Map<Id, OAuthServiceAPI__c>();
                if(serviceAPIs != null) {
                    Id serviceId = service;
                    for(OAuthServiceAPI__c u : services.get(service). OAuth_Service_APIs__r) {
                        serviceAPIs.put(u.Id, u);
                    }
                }
            }
            return serviceAPIs;
        }
        set;
    }
    public String serviceAPI { 
        get;
        set {
            if (value == '') value = null;
            serviceAPI = value;
        }
    }
    public List<SelectOption> serviceAPIOptions {
        get {
            List<SelectOption> options = new List<SelectOption>{new SelectOption('', '<keyboard input>')};
            if(service != null) {
                Id serviceId = service;
                for(OAuthServiceAPI__c u : services.get(serviceId).OAuth_Service_APIs__r) {
                    options.add(new SelectOption(u.Id, u.Name));
                }
            }
            return options;
        }
    }

    public PageReference execute() {
        Id serviceId = service;
        OAuth oa = OAuth.newInstance(serviceId);
        if (oa == null) {
            debug('Error: oa = null');
        }
        if (!oa.hasToken()) {
            debug('no token');
            return oa.authorization();
        }

        Boolean check = true;
        // check api
        if (api == null || api.Url__c == null || api.Url__c == '') {
            debug('Error: url = null');
            return null;
        }
        // check template
        for (TemplateParameter p : template) {
            if (p.value == null || p.value == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Template: Required fields has not been inputted <Name = "' + p.key + '">'));
                check = false;
            }
        }
        // create endpoint
        PageReference endpoint = new PageReference(api.Url__c);
        for (OAuthServiceAPIParameter__c p : query_parameters) {
            if (p.Name != null && p.Name != '') {
                if ((p.Value__c == null || p.Value__c == '') && p.Require__c) {
                    check = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Query: Required fields has not been inputted <Name = "' + p.Name + '">'));
                } else if (p.Value__c != null && p.Value__c != '') {
                    endpoint.getParameters().put(p.Name, p.Value__c);
                }
            } else if (p.Value__c != null && p.Value__c != '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Query: Value has been ignored <Value = "' + p.Value__c + '">'));
                check = false;
            }
        }
        String url = endpoint.getUrl();
        // create request
        debug('Method: ' + api.Method__c + ', Service: ' + service + ', URL: ' + url);
        HttpRequest req = new HttpRequest();
        req.setMethod(api.Method__c);
        req.setEndpoint(url);
        if(api.Method__c == 'POST' || api.Method__c == 'PUT') {
            req.setBody(api.Body__c);
            if (api.Content_Type__c != null) {
                req.setHeader('Content-Type', api.Content_Type__c);
            }
        }
        // set header
        for (OAuthServiceAPIParameter__c p : header_parameters) {
            if (p.Name != null && p.Name != '') {
                if ((p.Value__c == null || p.Value__c == '') && p.Require__c) {
                    check = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Header: Required fields has not been inputted <Name = "' + p.Name + '">'));
                } else if (p.Value__c != null && p.Value__c != '') {
                    req.setHeader(p.Name, p.Value__c);
                }
            } else if (p.Value__c != null && p.Value__c != '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Header: Value has been ignored <Value = "' + p.Value__c + '">'));
                check = false;
            }
        }
        if (!check) return null;

        try {
            HttpResponse res = null;
            res = System.currentPageReference().getParameters().containsKey('@test') ? new HttpResponse() : oa.rest(req);
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
            String type = res.getHeader('Content-Type');
            if (type != null) {
                if (type.startsWith('application/json') || type.startsWith('text/javascript')) {
                    response_type = 'json';
                    response_body = res.getBody();
                } else if (type.startsWith('application/xml') || type.startsWith('text/xml')) {
                    response_type ='xml';
                    response_body = res.getBody();
                } else if (type.startsWith('image/')) {
                    response_type = 'image';
                    String response_body_b64 = EncodingUtil.base64Encode(res.getBodyAsBlob());
                    response_body = 'data:' + type + ';base64,' + response_body_b64;
                } else {
                    response_type = 'plain';
                    response_body = res.getBody();
                }
            } else {
                response_type = 'plain';
                response_body = res.getBody();
            }
    }

    private Map<String, String> getResponseHeaders(HttpResponse res) {
        Map<String, String> headers = new Map<String, String>();
        for (String key : res.getHeaderKeys()) {
            if (key == null) continue;
            headers.put(key, res.getHeader(key));
        }
        return headers;
    }

    public PageReference loadServiceAPI() {
        debug('@loadServiceAPI');
        Id serviceId = service;
        api = serviceAPIs.get(serviceAPI);
        query_parameters.clear();
        header_parameters.clear();
        template.clear();
        if (api != null) {
            parameters = [
                Select
                    Name, Value__c, Type__c, Require__c, Read_Only__c
                From
                    OAuthServiceAPIParameter__c
                Where
                    OAuth_Service_API__c = :api.Id
                Order By
                    Require__c DESC,
                    Name
            ];
            for (OAuthServiceAPIParameter__c p : parameters) {
                if (p.Type__c == 'Query String') query_parameters.add(p);
                else if (p.Type__c == 'Request Header') header_parameters.add(p);
            }

            String url = api.Url__c;
            for (OAuthServiceVariable__c v : services.get(serviceId).OAuth_Service_Variable__r) {
                url = url.replaceFirst('\\{' + Pattern.quote(v.Name) + '\\}', v.Value__c);
            }
            api_org_url = url;
            Matcher m = p.matcher(url);
            while(m.find()) {
                TemplateParameter tp = new TemplateParameter();
                tp.key = m.group(1);
                tp.value = template_parameters.get(tp.key);
                if (tp.value == null) {
                    tp.value = '';
                    template_parameters.put(tp.key, tp.value);
                }
                template.add(tp);
            }
            applyRequest();
        } else {
            api = new OAuthServiceAPI__c();
            api_org_url = null;
        }
        if (api.Content_Type__c == null || api.Content_Type__c == '') {
            api.Content_Type__c  = 'application/x-www-form-urlencoded; charset=utf-8';
        }

        return null;
    }

    public PageReference applyRequest() {
        debug('@applyRequest');
        String url = api_org_url;
        // template
        for (TemplateParameter t : template) {
            template_parameters.put(t.key, t.value);
            if (t.value != null && t.value != '') {
                url = url.replaceFirst('\\{' + Pattern.quote(t.key) + '\\}', t.value);
                debug(t.key + ' => ' + t.value);
            }
        }
        api.Url__c = url;
        debug('url : ' + api.Url__c);

        return null;
    }

    public PageReference add_query() {
        debug('@add_query');
        query_parameters.add(new OAuthServiceAPIParameter__c(Read_Only__c = false));
        return null;
    }

    public PageReference delete_query() {
        debug('@delete_query(' + action_index + ')');
        if (action_index == null || action_index == '') return null;
        Integer index = Integer.valueOf(action_index);
        if (index >= 0 && index < query_parameters.size()) {
            query_parameters.remove(index);
        }
        return null;
    }

    public PageReference add_header() {
        debug('@add_header');
        header_parameters.add(new OAuthServiceAPIParameter__c(Read_Only__c = false));
        return null;
    }

    public PageReference delete_header() {
        debug('@delete_header(' + action_index + ')');
        if (action_index == null || action_index == '') return null;
        Integer index = Integer.valueOf(action_index);
        if (index >= 0 && index < header_parameters.size()) {
            header_parameters.remove(index);
        }
        return null;
    }

    public PageReference clearDebug() {
        debugs.clear();
        return null;
    }

    private void debug(String str) {
        System.debug(str);
        String tmp = new OAuthException('').getStackTraceString().split(', ')[1];
        Integer index = tmp.indexOf('Class.');
        if (index >= 0) {
            tmp = tmp.substring(index + 6);
        }
        List<String> class_line = tmp.split(': line ');
        debugs.add(new DebugLog(class_line[0], class_line[1], str));
    }

    public class TemplateParameter {
        public String key { get; set; }
        public String value { get; set; }
    }

    public class DebugLog {
        public String klass { get; set; }
        public String line { get; set; }
        public String message { get; set; }

        public DebugLog(String klass, String line, String message) {
            this.klass = klass;
            this.line = line;
            this.message = message;
        }
    }
}