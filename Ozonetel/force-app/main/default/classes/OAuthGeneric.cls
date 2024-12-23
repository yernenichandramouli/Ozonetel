global class OAuthGeneric {
    public Map<String,String> parameters = new Map<String,String>();
    public String nonce;
    public String timestamp;
    public String signature;
    public String consumerKey='MCycaVxF6XVV0ImKgqFPBAncx0prPp';
    public String consumerSecret='5f0lpy9heMvXNQ069lQPNMomysX6rt';
    public String token;
    public String tokenSecret;
    public Boolean isAccess = false;
    public String verifier;
    public OAuth_Keys__mdt oauthObj;
    
    
    
    public string sign(HttpRequest req,string transType) {
        if(transType=='Amazon'){
        oauthObj=[select id,Consumer_Key__c,Consumer_Secret__c from OAuth_Keys__mdt where DeveloperName='B2B_Amazon'];
        consumerKey=oauthObj.Consumer_Key__c;
        consumerSecret=oauthObj.Consumer_Secret__c;
        }else if(transType=='IRCTC'){
        oauthObj=[select id,Consumer_Key__c,Consumer_Secret__c from OAuth_Keys__mdt where DeveloperName='B2B_IRCTC'];
        consumerKey=oauthObj.Consumer_Key__c;
        consumerSecret=oauthObj.Consumer_Secret__c;
        }
        
        
        nonce = String.valueOf(crypto.getRandomLong());
        timestamp = String.valueOf(DateTime.now().getTime()/1000);
        
        refreshParameters();
        
        String s = createBaseString(parameters, req);
        
        System.debug('Signature base string: '+s);
        
        Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(s), 
                                      Blob.valueOf(consumerSecret+'&'+
                                                   (tokenSecret!=null ? tokenSecret : '')));
        signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
        System.debug('Signature: '+signature);
        
        String header = '';
        for (String key : parameters.keySet()) {
            header = header + key +'='+parameters.get(key)+'&';
        }
        header = header + 'oauth_signature='+signature+'';
        System.debug('Authorization: '+header);
        req.setHeader('Authorization',header);
        return header;
    }   
    
    public void refreshParameters() {
        parameters.clear();
        parameters.put('oauth_consumer_key',consumerKey);
        if(token!=null) {
            parameters.put('oauth_token',token);
        }
        if(verifier!=null) {
            parameters.put('oauth_verifier',verifier);
        }
        parameters.put('oauth_signature_method','HMAC-SHA1');
        parameters.put('oauth_timestamp',timestamp);
        parameters.put('oauth_nonce',nonce);
        // parameters.put('oauth_callback',callbackUrl);
    }
    
    public String createBaseString(Map<String,String> oauthParams, HttpRequest req) {
        Map<String,String> p = oauthParams.clone();
        if(req.getMethod().equalsIgnoreCase('post') && req.getBody()!=null && 
           req.getHeader('Content-Type')=='application/x-www-form-urlencoded') {
               p.putAll(getUrlParams(req.getBody()));
           }
        String host = req.getEndpoint();
        Integer n = host.indexOf('?');
        if(n>-1) {
            p.putAll(getUrlParams(host.substring(n+1)));
            host = host.substring(0,n);
        }
        List<String> keys = new List<String>();
        keys.addAll(p.keySet());
        keys.sort();
        String s = keys.get(0)+'='+p.get(keys.get(0));
        for(Integer i=1;i<keys.size();i++) {
            s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
        }
        
        // According to OAuth spec, host string should be lowercased, but Google and LinkedIn
        // both expect that case is preserved.
        return req.getMethod().toUpperCase()+ '&' + 
            EncodingUtil.urlEncode(host, 'UTF-8') + '&' +
            EncodingUtil.urlEncode(s, 'UTF-8');
    }
    
    public Map<String,String> getUrlParams(String value) {
        
        Map<String,String> res = new Map<String,String>();
        if(value==null || value=='') {
            return res;
        }
        for(String s : value.split('&')) {
            System.debug('getUrlParams: '+s);
            List<String> kv = s.split('=');
            if(kv.size()>1) {
                // RFC 5849 section 3.4.1.3.1 and 3.4.1.3.2 specify that parameter names 
                // and values are decoded then encoded before being sorted and concatenated
                // Section 3.6 specifies that space must be encoded as %20 and not +
                String encName = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[0], 'UTF-8'), 'UTF-8').replace('+','%20');
                String encValue = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[1], 'UTF-8'), 'UTF-8').replace('+','%20');
                System.debug('getUrlParams:  -> '+encName+','+encValue);
                res.put(encName,encValue);
            }
        }
        return res;
    }
    
}