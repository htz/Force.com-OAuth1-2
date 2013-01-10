public class OAuthJSON {
    public enum ValueType {
        INTEGER_VALUE,
        DECIMAL_VALUE,
        DOUBLE_VALUE,
        BOOLEAN_VALUE,
        STRING_VALUE,
        ARRAY_VALUE,
        HASH_VALUE,
        NULL_VALUE
    }

    public ValueType value_type {get;set;}
    public Integer integer_value {get;set;}
    public Decimal decimal_value {get;set;}
    public Double double_value {get;set;}
    public Boolean boolean_value {get;set;}
    public String string_value {get;set;}
    public List<OAuthJSON> array_value {get;set;}
    public Map<String, OAuthJSON> hash_value {get;set;}

    private OAuthJSON() {
    }

    public OAuthJSON(Integer integer_value) {
        this();
        this.value_type = ValueType.INTEGER_VALUE;
        this.integer_value = integer_value;
    }

    public OAuthJSON(Decimal decimal_value) {
        this();
        this.value_type = ValueType.DECIMAL_VALUE;
        this.decimal_value = decimal_value;
    }

    public OAuthJSON(Double double_value) {
        this();
        this.value_type = ValueType.DOUBLE_VALUE;
        this.double_value = double_value;
    }

    public OAuthJSON(String string_value) {
        this();
        this.value_type = ValueType.STRING_VALUE;
        this.string_value = string_value;
    }

    public OAuthJSON(Boolean boolean_value) {
        this();
        this.value_type = ValueType.BOOLEAN_VALUE;
        this.boolean_value = boolean_value;
    }

    // Null
    public static OAuthJSON newNullInstance() {
        OAuthJSON instance = new OAuthJSON();
        instance.value_type = ValueType.NULL_VALUE;
        return instance;
    }

    // Array
    public static OAuthJSON newArrayInstance() {
        OAuthJSON instance = new OAuthJSON();
        instance.value_type = ValueType.ARRAY_VALUE;
        instance.array_value = new List<OAuthJSON>();
        return instance;
    }

    public OAuthJSON add(OAuthJSON value) {
        if (value_type != ValueType.ARRAY_VALUE) throw new OAuthJSONException(this);
        array_value.add(value);
        return this;
    }

    public OAuthJSON get(Integer index) {
        if (value_type != ValueType.ARRAY_VALUE) throw new OAuthJSONException(this);
        return array_value.get(index);
    }

    public OAuthJSON remove(Integer index) {
        if (value_type != ValueType.ARRAY_VALUE) throw new OAuthJSONException(this);
        return array_value.remove(index);
    }

    public OAuthJSON join() {
        return join('');
    }
    public OAuthJSON join(String sep) {
        if (value_type != ValueType.ARRAY_VALUE) throw new OAuthJSONException(this);
        String str = '';
        Integer i = 0;
        for (; i < size() - 1; i++) {
            str += array_value[i].to_s() + sep;
        }
        str += array_value[i].to_s();
        return new OAuthJSON(str);
    }

    // Hash
    public static OAuthJSON newHashInstance() {
        OAuthJSON instance = new OAuthJSON();
        instance.value_type = ValueType.HASH_VALUE;
        instance.hash_value = new Map<String, OAuthJSON>();
        return instance;
    }

    public OAuthJSON put(String key, OAuthJSON value) {
        if (value_type != ValueType.HASH_VALUE) throw new OAuthJSONException(this);
        hash_value.put(key, value);
        return this;
    }

    public OAuthJSON putAll(Map<String, OAuthJSON> value_map) {
        if (value_type != ValueType.HASH_VALUE) throw new OAuthJSONException(this);
        hash_value.putAll(value_map);
        return this;
    }

    public OAuthJSON get(String key) {
        if (value_type != ValueType.HASH_VALUE) throw new OAuthJSONException(this);
        return hash_value.get(key);
    }

    public OAuthJSON remove(String key) {
        if (value_type != ValueType.HASH_VALUE) throw new OAuthJSONException(this);
        return hash_value.remove(key);
    }

    public Set<String> keySet() {
        if (value_type != ValueType.HASH_VALUE) throw new OAuthJSONException(this);
        return hash_value.keySet();
    }

    public Boolean containsKey(String key) {
        if (value_type != ValueType.HASH_VALUE) throw new OAuthJSONException(this);
        return hash_value.containsKey(key);        
    }

    // Array, Hash
    public OAuthJSON clear() {
        if (value_type == ValueType.ARRAY_VALUE) {
            array_value.clear();
            return this;
        }
        if (value_type == ValueType.HASH_VALUE) {
            hash_value.clear();
            return this;
        }
        throw new OAuthJSONException(this);
    }

    public Integer size() {
        if (value_type == ValueType.ARRAY_VALUE) return array_value.size();
        if (value_type == ValueType.HASH_VALUE) return hash_value.size();
        throw new OAuthJSONException(this);
    }

    public Boolean isEmpty() {
        if (value_type == ValueType.ARRAY_VALUE) return array_value.isEmpty();
        if (value_type == ValueType.HASH_VALUE) return hash_value.isEmpty();
        throw new OAuthJSONException(this);
    }

    public List<OAuthJSON> values() {
        if (value_type == ValueType.ARRAY_VALUE) return array_value;
        if (value_type == ValueType.HASH_VALUE) return hash_value.values();
        throw new OAuthJSONException(this);
    }

    public String to_s() {
        String str = null;

        if (value_type == ValueType.NULL_VALUE) {
            str = '';
        } else if (value_type == ValueType.INTEGER_VALUE) {
            str = String.valueOf(integer_value);
        } else if (value_type == ValueType.DECIMAL_VALUE) {
            str = String.valueOf(decimal_value);
        } else if (value_type == ValueType.DOUBLE_VALUE) {
            str = String.valueOf(double_value);
        } else if (value_type == ValueType.BOOLEAN_VALUE) {
            str = String.valueOf(boolean_value);
        } else if (value_type == ValueType.STRING_VALUE) {
            str = string_value;
        } else if (value_type == ValueType.ARRAY_VALUE) {
            Integer i = 0;
            str = '';
            for (OAuthJSON v : values()) {
                str += v.to_s();
            }
            str += ']';
        } else {
            str = inspect();
        }

        return str;
    }

    public String inspect() {
        String str = null;

        if (value_type == ValueType.NULL_VALUE) {
            str = 'null';
        } else if (
            value_type == ValueType.INTEGER_VALUE ||
            value_type == ValueType.DECIMAL_VALUE ||
            value_type == ValueType.DOUBLE_VALUE ||
            value_type == ValueType.BOOLEAN_VALUE
        ) {
            str = to_s();
        } else if (value_type == ValueType.STRING_VALUE) {
            str = '"' + String.escapeSingleQuotes(string_value) + '"';
        } else if (value_type == ValueType.ARRAY_VALUE) {
            str = '[';
            if (size() > 0) {
                Integer i = 0;
                for (; i < size() - 1; i++) {
                    str += array_value[i].inspect() + ', ';
                }
                str += array_value[i].inspect();
            }
            str += ']';
        } else if (value_type == ValueType.HASH_VALUE) {
            str = '{';
            if (size() > 0) {
                List<String> keys = new List<String>();
                for (String key : keySet()) keys.add(key);
                Integer i = 0;
                for (; i < keys.size() - 1; i++) {
                    str += '"' + String.escapeSingleQuotes(keys[i]) + '": ' + get(keys[i]).inspect() + ', ';
                }
                str += '"' + String.escapeSingleQuotes(keys[i]) + '": ' + get(keys[i]).inspect();
            }
            str += '}';
        } else {
            str = '<#Error>';
        }

        return str;
    }

    public static OAuthJSON newInstance(String value) {
        return newInstance(JSON.createParser(value));
    }

    public static OAuthJSON newInstance(JSONParser parser) {
        parser.nextToken();
        return parse(parser);
    }

    public static OAuthJSON parse(JSONParser parser) {
        OAuthJSON val = null;
        if (parser.getCurrentToken() == JSONToken.VALUE_NULL) {
            val = OAuthJSON.newNullInstance();
            val.string_value = '';
        } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
            try {
                val = new OAuthJSON(parser.getIntegerValue());
                val.decimal_value = parser.getDecimalValue();
            } catch (JSONException e) {
                val = new OAuthJSON(parser.getDecimalValue());
            }
            val.string_value = parser.getText();
        } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_FLOAT) {
            val = new OAuthJSON(parser.getDoubleValue());
            val.decimal_value = parser.getDecimalValue();
            val.string_value = parser.getText();
        } else if (parser.getCurrentToken() == JSONToken.VALUE_TRUE || parser.getCurrentToken() == JSONToken.VALUE_FALSE) {
            val = new OAuthJSON(parser.getBooleanValue());
            val.string_value = parser.getText();
        } else if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
            val = new OAuthJSON(parser.getText());
        } else if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
            val = OAuthJSON.newHashInstance();
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                String key = parser.getText();
                parser.nextToken();
                val.put(key, parse(parser));
            }
        } else if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            val = OAuthJSON.newArrayInstance();
            while (parser.nextToken() != JSONToken.END_ARRAY) {
                val.add(parse(parser));
            }
        } else {
            throw new OAuthJSONException('parse error');
        }
        return val;
    }
}