public with Sharing Class CC_ST_GoogleAccountAuthorizeCtrl{
    public Case caseObj {get; set;}
    
    public String clientid{get; set;}
    public String clientsecret{get; set;}
    
    public String commentStr {get; set;}
    public boolean isCommentPosted {get;set;}
    public boolean isCommentNotPosted {get;set;}
    public boolean isCommentEntered {get; set;}
    public boolean isRedirect {get;set;}
    
    public String redirectURI;
    //public final String scope = 'https://www.googleapis.com/auth/youtube.force-ssl https://www.googleapis.com/auth/youtube';
    public final String scope = 'https://www.googleapis.com/auth/androidpublisher';
    
    public final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';
    public final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
    
    public CC_ST_GoogleAccountAuthorizeCtrl() {
        isCommentPosted = false;
        isCommentNotPosted = false;
        isCommentEntered = false;
        isRedirect = false;
        redirectURI = 'https://'+URL.getSalesforceBaseUrl().getHost()+'/apex/DE_GoogleAccountAuthorize';
        
        CC_ST_Google_API_Tokens__c clientIdTok = CC_ST_Google_API_Tokens__c.getValues('Client Id');
        if(clientIdTok != null){
        	clientid = clientIdTok.Token_Value__c;
        }
        CC_ST_Google_API_Tokens__c clientSecTok = CC_ST_Google_API_Tokens__c.getValues('Client Secret');
        if(clientSecTok != null){
            clientsecret = clientSecTok.Token_Value__c;
        }
        
    }
    
    public CC_ST_GoogleAccountAuthorizeCtrl(ApexPages.StandardController stdController) {
        //caseObj = (Case)stdController.getRecord();
        //caseObj = [select id, Youtube_Video_Id__c from Case where id =: caseObj.Id];
    
        isCommentPosted = false;
        isCommentNotPosted = false;
        isCommentEntered = false;
        isRedirect = false;
        redirectURI = 'https://'+URL.getSalesforceBaseUrl().getHost()+'/apex/DE_GoogleAccountAuthorize';
        
        CC_ST_Google_API_Tokens__c clientIdTok = CC_ST_Google_API_Tokens__c.getValues('Client Id');
        if(clientIdTok != null){
        	clientid = clientIdTok.Token_Value__c;
        }
        CC_ST_Google_API_Tokens__c clientSecTok = CC_ST_Google_API_Tokens__c.getValues('Client Secret');
        if(clientSecTok != null){
            clientsecret = clientSecTok.Token_Value__c;
        }
        
    }
    
    public Pagereference authorizeEndpoint(){
        isRedirect = false;
        
        if(clientid != null && clientid != ''){
            CC_ST_Google_API_Tokens__c clientIdTok = CC_ST_Google_API_Tokens__c.getValues('Client Id');
            if(clientIdTok == null){
                clientIdTok = new CC_ST_Google_API_Tokens__c();
                clientIdTok.Name = 'Client Id';
                clientIdTok.Token_Value__c = clientid;
                insert clientIdTok;
                clientid = clientIdTok.Token_Value__c;
            }else{
                clientIdTok.Token_Value__c = clientid;
                update clientIdTok;
                clientid = clientIdTok.Token_Value__c;
            }
        }
        
        if(clientsecret != null && clientsecret != ''){
            CC_ST_Google_API_Tokens__c clientSecTok = CC_ST_Google_API_Tokens__c.getValues('Client Secret');
            if(clientSecTok == null){
                clientSecTok = new CC_ST_Google_API_Tokens__c();
                clientSecTok.Name = 'Client Secret';
                clientSecTok.Token_Value__c = clientsecret;
                insert clientSecTok;
                clientsecret = clientSecTok.Token_Value__c;
            }else{
                clientSecTok.Token_Value__c = clientsecret;
                update clientSecTok;
                clientsecret = clientSecTok.Token_Value__c;
            }
        }
        
        if(clientid != null && clientsecret != null && clientid != '' && clientsecret != ''){
            isRedirect = true;
            String urlStr = OAUTH_CODE_END_POINT_URL+'?response_type=code&client_id='+clientid+'&redirect_uri='+ EncodingUtil.urlEncode(redirectURI, 'UTF-8')+'&scope='+ EncodingUtil.urlEncode(scope, 'UTF-8')+'&access_type=offline';
            Pagereference pageRef = new Pagereference(urlStr);
            return pageRef;
        }else{
            return null;
        }
        
    }
    
    public Pagereference fetchAccessToken(){
        isRedirect = null;
        string codeParam = Apexpages.currentPage().getParameters().get('code');
        CC_ST_Google_API_Tokens__c accTokInitial = CC_ST_Google_API_Tokens__c.getValues('Access Token');
        String accessToken;
        if(accTokInitial == null){
                accTokInitial = new CC_ST_Google_API_Tokens__c();
                accTokInitial.Name = 'Access Token';
                accTokInitial.Token_Value__c = '';
                insert accTokInitial;
                //clientsecret = clientSecTok.Token_Value__c;
            }else{
                accessToken = accTokInitial.Token_Value__c;
            }
        
         
        if(codeParam != null && codeParam != ''){
            String reqbody = 'grant_type=authorization_code&client_id='+clientid+'&client_secret='+clientsecret+'&code='+codeParam+'&redirect_uri='+EncodingUtil.urlEncode(redirectURI, 'UTF-8');
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setBody(reqbody);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setEndpoint(OAUTH_TOKEN_URL);
            HttpResponse res = h.send(req);
            
            GoogleAuthApiResponse jsonVar = (GoogleAuthApiResponse) System.JSON.deserialize(res.getbody(), GoogleAuthApiResponse.class);
            
            CC_ST_Google_API_Tokens__c accTok = CC_ST_Google_API_Tokens__c.getValues('Access Token');
            if(accTok != null){
                accTok.Token_Value__c = jsonVar.access_token;
            	update accTok;
            }else{
                accTok = new CC_ST_Google_API_Tokens__c();
                accTok.Name = 'Access Token';
                accTok.Token_Value__c = jsonVar.access_token;
            	insert accTok;
            }
            isRedirect = true;
            CC_ST_Google_API_Tokens__c refTok = CC_ST_Google_API_Tokens__c.getValues('Refresh Token');
            if(refTok != null){
                refTok.Token_Value__c= jsonVar.refresh_token;
                update refTok;
            }else{
                refTok = new CC_ST_Google_API_Tokens__c();
                refTok.Name = 'Refresh Token';
                refTok.Token_Value__c= jsonVar.refresh_token;
                insert refTok;
            }
        }
        return null;
    }
    
    public Pagereference refreshAccessToken(){
        isRedirect = false;
        CC_ST_Google_API_Tokens__c refTok = CC_ST_Google_API_Tokens__c.getValues('Refresh Token');
        String refreshToken;
        if(refTok != null){
            refreshToken = refTok.Token_Value__c;
        }
        if(refreshToken != null && refreshToken != ''){
            String reqbody = 'grant_type=refresh_token&client_id='+clientid+'&client_secret='+clientsecret+'&refresh_token='+refreshToken;
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setBody(reqbody);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setEndpoint(OAUTH_TOKEN_URL);
            HttpResponse res = h.send(req);
            
            RefreshAccessTokenResponse jsonVar = (RefreshAccessTokenResponse) System.JSON.deserialize(res.getbody(), RefreshAccessTokenResponse.class);
            
            if(jsonVar.access_token != null){
                CC_ST_Google_API_Tokens__c accTok = CC_ST_Google_API_Tokens__c.getValues('Access Token');
                accTok.Token_Value__c = jsonVar.access_token;
                update accTok;
                isRedirect = true;
            }else{
                isRedirect = false;
            }
            
        }
        return null;
    }   
    
   /* public Pagereference postComment(){
        Google_API_Tokens__c accTok = Google_API_Tokens__c.getValues('Access Token');
        String accessToken;
        
        if(accTok != null){
            accessToken = accTok.Token_Value__c;
        }
        
        
        if(commentStr != null && commentStr != '' && accessToken != null && accessToken != '' && caseObj.Youtube_Video_Id__c != null && caseObj.Youtube_Video_Id__c != ''){
          String endPoint = 'https://www.googleapis.com/youtube/v3/commentThreads?part=snippet';
          String jsonstr = '{"snippet": {"topLevelComment": {"snippet": {"textOriginal": "'+commentStr+'"}},"videoId": "'+caseObj.Youtube_Video_Id__c+'"}}';
          Http h2 = new Http();
          HttpRequest req1 = new HttpRequest();
          req1.setHeader('Authorization','Bearer ' + accessToken);
          req1.setHeader('Content-Type','application/json');
          req1.setBody(jsonstr);
          req1.setMethod('POST');
          req1.setEndpoint(endPoint);
          HttpResponse res1 = h2.send(req1);
    
          YTPostCommentParser jsonVar = (YTPostCommentParser) System.JSON.deserialize(res1.getbody(), YTPostCommentParser.class);

          if(jsonVar.id != null && jsonVar.id != ''){
              isCommentPosted = true;
              isCommentNotPosted = false;
              isCommentEntered = false;
              commentStr = '';
          }else{
              isCommentNotPosted = true;
              isCommentPosted = false;
              isCommentEntered = false;
          }
        }else{
            isCommentEntered = true;
            isCommentNotPosted = false;
            isCommentPosted = false;
        }
        return null;
    }
    
    @AuraEnabled
    public static string postYTComment(String commentParam, String caseId){
        Google_API_Tokens__c accTok = Google_API_Tokens__c.getValues('Access Token');
        String accessToken ;
        if(accTok != null){
            accessToken = accTok.Token_Value__c;
        }
        Case caseObjTemp = [select id, Youtube_Video_Id__c from Case where id =: caseId];
        String videoId;
        if(caseObjTemp != null){
           videoId = caseObjTemp.Youtube_Video_Id__c;
        }
        if(commentParam != null && commentParam != '' && accessToken != null && accessToken != '' && videoId != null){
          String endPoint = 'https://www.googleapis.com/youtube/v3/commentThreads?part=snippet';
          String jsonstr = '{"snippet": {"topLevelComment": {"snippet": {"textOriginal": "'+commentParam+'"}},"videoId": "'+videoId+'"}}';
          Http h2 = new Http();
          HttpRequest req1 = new HttpRequest();
          req1.setHeader('Authorization','Bearer ' + accessToken);
          req1.setHeader('Content-Type','application/json');
          req1.setBody(jsonstr);
          req1.setMethod('POST');
          req1.setEndpoint(endPoint);
          HttpResponse res1 = h2.send(req1);
    
          YTPostCommentParser jsonVar = (YTPostCommentParser) System.JSON.deserialize(res1.getbody(), YTPostCommentParser.class);

          if(jsonVar.id != null && jsonVar.id != ''){
              return 'Comment posted sucessfully.';
          }else{
              return 'An error occurred. Please contact administrator.';
          }
        }else{
            return 'Please enter comments or youtube video id.';
        }
        
    }*/
    
    public class GoogleAuthApiResponse {

        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String refresh_token;
        
    }
    
    public class RefreshAccessTokenResponse{
        public string access_token;
        public Integer expires_in;
        public string token_type;
    }
    
    

}