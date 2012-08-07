@isTest
private class OAuthJSONTest {
    public static testMethod void testNew() {
        OAuthJSON j1 = new OAuthJSON(0);
            j1.to_s();
            j1.inspect();
        OAuthJSON j2 = new OAuthJSON(Decimal.valueOf('0'));
            j2.to_s();
            j2.inspect();
        OAuthJSON j3 = new OAuthJSON(3.14);
            j3.to_s();
            j3.inspect();
        OAuthJSON j4 = new OAuthJSON('0');
            j4.to_s();
            j4.inspect();
        OAuthJSON j5 = new OAuthJSON(true);
            j5.to_s();
            j5.inspect();
        OAuthJSON j6 = OAuthJSON.newNullInstance();
            j6.to_s();
            j6.inspect();
        OAuthJSON j7 = OAuthJSON.newArrayInstance();
            j7.add(j1);j7.add(j2);
            j7.get(0);
            j7.join();j7.join(',');
            System.assertEquals(2, j7.size(), '');
            System.assert(!j7.isEmpty());
            j7.values();
            j7.to_s();
            j7.inspect();
            j7.remove(0);
            j7.clear();
        OAuthJSON j8 = OAuthJSON.newHashInstance();
            j8.put('a', j1);
            j8.putAll(new Map<String, OAuthJSON>{'b' => j2});
            j8.get('a');
            j8.keySet();
            j8.containsKey('a');
            System.assertEquals(2, j8.size(), '');
            System.assert(!j8.isEmpty());
            j8.values();
            j8.to_s();
            j8.inspect();
            j8.remove('a');
            j8.clear();
    }

    public static testMethod void testParser() {
        OAuthJSON json = OAuthJSON.newInstance('{"a":1,"b":12345678901234567890123456789012345678901234567890,"c":3.1415926535,"d":"test","e":false,"f":true,"g":[1,2,3],"h":{"z":0},"i":null}');
    }

    public static testMethod void testException() {
        new OAuthJSONException();
        try {
            new OAuthJSON(0).add(null);
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).get(0);
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).remove(0);
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).join();
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).put('a', null);
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).putAll(null);
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).get('a');
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).remove('a');
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).keySet();
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).clear();
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).size();
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).isEmpty();
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
        try {
            new OAuthJSON(0).values();
            System.assert(false);
        } catch (OAuthJSONException e) {
        } catch (Exception e) {
            System.assert(false);
        }
    }
}