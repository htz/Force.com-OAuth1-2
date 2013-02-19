public class OAuthSign {
    private Map<String, List<String>> parameters;

    public OAuthSign() {
        this.parameters = new Map<String, List<String>>();
    }

    public OAuthSign(Map<String, String> m) {
        this();
        put(m);
    }

    public OAuthSign(Map<String, List<String>> parameters) {
        this();
        put(parameters);
    }

    public void put(Map<String, List<String>> parameters) {
        if (parameters != null) {
            for (String key : parameters.keySet()) {
                put(key, parameters.get(key));
            }
        }
    }

    public void put(Map<String, String> m) {
        if (m != null) {
            for (String key : m.keySet()) {
                put(key, m.get(key));
            }
        }
    }

    public void put(String key, List<String> l) {
        List<String> values = this.parameters.get(key);
        if (values == null) {
            values = new List<String>();
            this.parameters.put(key, values);
        }
        values.addAll(l);
    }

    public void put(String key, String value) {
        List<String> values = this.parameters.get(key);
        if (values == null) {
            values = new List<String>();
            this.parameters.put(key, values);
        }
        values.add(value);
    }

    private String join(String sep) {
        List<String> key_values = new List<String>();
        for (String key : this.parameters.keySet()) {
            List<String> tmp = this.parameters.get(key).clone();
            tmp.sort();
            for (String value : tmp) {
                key_values.add(join(key, value));
            }
        }
        key_values.sort();
        return join(key_values, sep);
    }

    private String join(String key, String value) {
        return percentEncode(key) + '=' + percentEncode(value);
    }

    private String join(List<String> values, String sep) {
        String str = '';
        if (values.size() > 0) {
            str = values[0];
            for (Integer i = 1; i < values.size(); i++) {
                str += sep + values[i];
            }
        }
        return str;
    }

    private Map<String, String> splitParameters(String value) {
        if (value == null || value == '') {
            return new Map<String, String>();
        }
        PageReference tmp = new PageReference('http://localhost/?' + value);
        return tmp.getParameters();
    }

    private String getNormalizedRequestParameterString() {
        return join('&');
    }

    private String getSignatureBaseString(HttpRequest req) {
        Map<String, List<String>> org = this.parameters.clone();

        if (req.getMethod().equalsIgnoreCase('POST') && req.getBody() != null && (
            req.getHeader('Content-Type').startsWith('application/x-www-form-urlencoded;') ||
            req.getHeader('Content-Type') == 'application/x-www-form-urlencoded'
        )) {
            put(splitParameters(req.getBody()));
        }
        String host = req.getEndpoint();
        Integer n = host.indexOf('?');
        if (n > -1) {
            put(splitParameters(host.substring(n + 1)));
            host = host.substring(0, n);
        }

        String signature = req.getMethod().toUpperCase() +
            '&' + percentEncode(host) +
            '&' + percentEncode(getNormalizedRequestParameterString());

        this.parameters = org;
        return signature;
    }

    private String getSignature(HttpRequest req, String signature_method, String consumer_secret, String token_secret) {
        String str = getSignatureBaseString(req);
        System.debug('Signature base string: ' + str);
        String secret = percentEncode(consumer_secret) + '&';
        if (token_secret != null) {
            secret += percentEncode(token_secret);
        }
        System.debug('signature_method: ' + signature_method);
        if (signature_method == 'HMAC-SHA1') {
            Blob sig = Crypto.generateMac(
                'HmacSHA1',
                Blob.valueOf(str),
                Blob.valueOf(secret)
            );
            return EncodingUtil.base64encode(sig);
        } else if (signature_method == 'PLAINTEXT') {
            return secret;
        }
        return '';
    }

    public String getAuthorizationHeader(HttpRequest req, String consumer_secret, String token_secret) {
        String signature_method = '';
        if (this.parameters.get('oauth_signature_method').size() > 0) {
            signature_method = this.parameters.get('oauth_signature_method')[0];
        }
        String signature = getSignature(req, signature_method, consumer_secret, (token_secret != null ? token_secret : ''));
        System.debug('Signature: ' + signature);
        put('oauth_signature', signature);

        List<String> keys = new List<String>();
        keys.addAll(this.parameters.keySet());
        keys.sort();

        List<String> values = new List<String>{'realm=""'};
        for (String key : keys) {
            List<String> v = this.parameters.get(key);
            if (key.startsWith('oauth_') && v.size() > 0) {
                values.add(percentEncode(key) + '="' + percentEncode(v[0]) + '"');
            }
        }
        return 'OAuth ' + join(values, ', ');
    }

    private String percentEncode(String str) {
        str = EncodingUtil.urlEncode(str, 'UTF-8');
        return str.replaceAll('%7e|%7E', '~').replaceAll('\\+', '%20');
    }
}