@isTest
public class CC_InboundSocialPostHandlerImplTest {

    static Map<String, Object> sampleSocialData;
    static CC_InboundSocialPostHandlerImpl handler;

    static {
    	handler = new CC_InboundSocialPostHandlerImpl();
        sampleSocialData = getSampleSocialData('1');
    }
    
    static testMethod void verifyNewRecordCreation() {
        
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        //TODO: Revisar, ahora no hay contacto
        //Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        //System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        //System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }


    static testMethod void verifyNewRecordCreation_ListaBlanca() {
        
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);     

        CC_Administracion_Lista_Blanca__c listaBlancaTest = new CC_Administracion_Lista_Blanca__c(CC_Activo__c = true, CC_Aqumetrix__c = true, CC_Canal_Contacto__c = 'Twitter', Name = 'testhandle', CC_Prioridad__c	= 'High');
        insert listaBlancaTest;
        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        //TODO: Revisar, ahora no hay contacto
        //Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        //System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        //System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }


    static testMethod void verifyNewRecordCreation_ListaBlanca2() {
        
        SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);     

        CC_Administracion_Lista_Blanca__c listaBlancaTest = new CC_Administracion_Lista_Blanca__c(CC_Activo__c = true, CC_Aqumetrix__c = false, CC_Canal_Contacto__c = 'Twitter', Name = 'testhandle', CC_Prioridad__c	= 'High');
        insert listaBlancaTest;
        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        //TODO: Revisar, ahora no hay contacto
        //Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        //System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        //System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }
    
    static testMethod void matchSocialPostRecord() {
        SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
        insert existingPost;
        
        SocialPost post = getSocialPost(sampleSocialData);
        post.R6PostId = existingPost.R6PostId;
        SocialPersona persona = getSocialPersona(sampleSocialData);
        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM SocialPost].size(), 'There should be only 1 post');
    }
    
    static testMethod void matchSocialPersonaRecord() {
    	Contact existingContact = new Contact(LastName = 'LastName');
    	insert existingContact;
    	SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
    	existingPersona.ParentId = existingContact.Id;
    	insert existingPersona;
    	
    	SocialPost post = getSocialPost(sampleSocialData);
        SocialPersona persona = getSocialPersona(sampleSocialData);
        persona.ExternalId = existingPersona.ExternalId;
        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost];
        SocialPersona createdPersona = [SELECT Id, ParentId FROM SocialPersona];
        Contact createdContact = [SELECT Id FROM Contact];
        Case createdCase = [SELECT Id, ContactId FROM Case];
        
        System.assertEquals(createdPost.PersonaId, createdPersona.Id, 'Post is not linked to the Persona.');
        //TODO: Revisar, ahora no hay contacto
        //System.assertEquals(createdPost.WhoId, createdPersona.ParentId, 'Post is not linked to the Contact');
        System.assertEquals(createdPost.ParentId, createdCase.Id, 'Post is not linked to the Case.');
        //System.assertEquals(createdCase.ContactId, createdContact.Id, 'Contact is not linked to the Case.');
    }
    
    static testMethod void matchCaseRecord() {
    	Contact existingContact = new Contact(LastName = 'LastName');
    	insert existingContact;
    	SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
    	existingPersona.ParentId = existingContact.Id;
    	insert existingPersona;
    	Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case', Priority = 'High');
        existingCase.Origin='Twitter';
        existingCase.CC_Canal_Procedencia__c='CaixaBank';
    	insert existingCase;
    	SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
    	existingPost.ParentId = existingCase.Id;
    	existingPost.WhoId = existingContact.Id;
    	existingPost.PersonaId = existingPersona.Id;
    	String recipient = 'scs';
    	existingPost.recipient = recipient;
    	insert existingPost;
        
        existingCase.SourceId = existingPost.Id;
        update existingCase;
    	
    	SocialPost post = getSocialPost(sampleSocialData);
    	post.responseContextExternalId = existingPost.ExternalPostId;
    	post.Recipient = recipient;
        post.ParentId = existingCase.Id;
        
        test.startTest();
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        //TODO: Revisar, ahora no hay contacto
        //System.assertEquals(existingContact.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        System.assertEquals(existingCase.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        //System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
    }
    
    static testMethod void reopenClosedCase() {
    	Contact existingContact = new Contact(LastName = 'LastName');
    	insert existingContact;
    	SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
    	existingPersona.ParentId = existingContact.Id;
    	insert existingPersona;
    	Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case', Status = 'Cerrado');
        existingCase.Origin='Twitter';
        existingCase.CC_Canal_Procedencia__c='CaixaBank';
    	insert existingCase;
    	SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
    	existingPost.ParentId = existingCase.Id;
    	existingPost.WhoId = existingContact.Id;
    	existingPost.PersonaId = existingPersona.Id;
    	String recipient = 'scs';
    	existingPost.recipient = recipient;
    	insert existingPost;

        // Vincular el post al caso.
        existingCase.SourceId = existingPost.Id;
        update existingCase;
    	
    	SocialPost post = getSocialPost(sampleSocialData);
    	post.responseContextExternalId = existingPost.ExternalPostId;
    	post.Recipient = recipient;
        
        test.startTest();
        handler.handleInboundSocialPost(post, existingPersona, sampleSocialData);
        test.stopTest();
        
        SocialPost createdPost = [SELECT Id, PersonaId, ParentId, WhoId FROM SocialPost WHERE R6PostId = :post.R6PostId];
        System.assertEquals(existingPersona.Id, createdPost.PersonaId, 'Post is not linked to the Persona.');
        //TODO: Revisar, ahora no hay contacto
        //System.assertEquals(existingContact.Id, createdPost.WhoId, 'Post is not linked to the Contact');
        //System.assertEquals(existingCase.Id, createdPost.ParentId, 'Post is not linked to the Case.');
        //System.assertEquals(1, [SELECT Id FROM Case].size(), 'There should only be 1 Case.');
        //System.assertEquals(false, [SELECT Id, IsClosed FROM Case WHERE Id = :existingCase.Id].IsClosed, 'Case should be open.');        
    }
    
    static testMethod void getDMTwitter() {
        //SocialPost existingPost = getSocialPostDM(getSampleSocialDataDM('2'));
        //insert existingPost;
        
        Map<String, Object> sampleSocialDataDM = getSampleSocialDataDM('1');
        
        SocialPost post = getSocialPostDM(sampleSocialDataDM);
        //post.R6PostId = existingPost.R6PostId;
        SocialPersona persona = getSocialPersona(sampleSocialDataDM);
        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialDataDM);
        test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM SocialPost].size(), 'There should be only 1 post');
    }
    
    static testMethod void getConstructObj()
    {
        CC_InboundSocialPostHandlerImpl.PostAttachment oTest = new CC_InboundSocialPostHandlerImpl.PostAttachment('a','b');
        
        System.assertEquals(oTest != null, true);
    }
    
    static SocialPost getSocialPost(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
       	post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.Language = String.valueOf(socialData.get('language'));
        post.Handle = String.valueOf(socialData.get('handle'));
        post.IsOutBound = Boolean.valueOf(socialData.get('isOutbound'));
        post.PostTags = 'test01,test02,test03,test04';
        return post;
    }
    
    static SocialPersona getSocialPersona(Map<String, Object> socialData) {
        SocialPersona persona = new SocialPersona();
        persona.Name = String.valueOf(socialData.get('author'));
        persona.RealName = String.valueOf(socialData.get('realName'));
        persona.Provider = String.valueOf(socialData.get('mediaProvider'));
        persona.MediaProvider = String.valueOf(socialData.get('mediaProvider'));
        persona.ExternalId = String.valueOf(socialData.get('externalUserId'));
        persona.Followers = Integer.ValueOf(socialData.get('followers'));
        persona.Following = Integer.ValueOf(socialData.get('following'));
        persona.NumberOfTweets = Integer.ValueOf(socialData.get('tweets'));
        persona.IsVerified = Boolean.ValueOf(socialData.get('verified'));
        persona.Bio = String.ValueOf(socialData.get('bio'));

        return persona;
    }

    static Map<String, Object> getSampleSocialData(String suffix) {
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postLabels', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        
		String sAux = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        sAux = sAux + '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        sAux = sAux + '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        
        socialData.put('content', 'Content' + sAux + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Tweet');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        socialData.put('followers', '25');
        socialData.put('following', '52');
        socialData.put('tweets', '2');
        socialData.put('verified', true);
        socialData.put('bio', 'bioprueba');
        socialData.put('language','Spanish');
        socialData.put('handle','testhandle');
        socialData.put('isOutbound', false);
        return socialData;
    }
    
    static SocialPost getSocialPostDM(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
       	post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.ReviewScore = double.valueOf(socialData.get('ReviewScore'));
        post.Language = String.valueOf(socialData.get('language'));
        post.Handle = String.valueOf(socialData.get('handle'));
        post.PostTags = 'test01,test02,test03,test04';
        return post;
    }
    
    static Map<String, Object> getSampleSocialDataDM(String suffix) {
        
		List<Map<String,Object>> oList = new List<Map<String,Object>>();
        Map<String,Object> oData = new Map<String,Object>();
        oData.put('mediaType','IMAGE');
        oData.put('mediaUrl','http://pbs.twimg.com/media/D6J4GEDWwAAEbXx.jpg');
		oList.add(oData);
        
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postLabels', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        
		String sAux = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        sAux = sAux + '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        sAux = sAux + '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        
        socialData.put('content', 'Content ' + sAux + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Direct');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        socialData.put('ReviewScore',50);
        socialData.put('mediaUrls', oList);
        socialData.put('followers', '25');
        socialData.put('following', '52');
        socialData.put('tweets', '2');
        socialData.put('verified', true);
        socialData.put('bio', 'bioprueba');
        socialData.put('language','Spanish');
        socialData.put('handle','testhandle');
        
        return socialData;
    }
    
    static testMethod void getCuentaCliOrigen()
    {
        List<String> oCuentasGrupo = new List<String>();
        oCuentasGrupo.add('companydemo001');
        String sAux = CC_InboundSocialPostHandlerImpl.getCuentaCliOrigen('@companydemo001 test @cliente', oCuentasGrupo);
        
        System.assertEquals(sAux == 'cliente', true);
    }
    
    static testMethod void validarOtrosMetodos()
    {        
        Integer iNum = handler.getMaxNumberOfDaysClosedToReopenCase();
        
        System.assertEquals(iNum, 5);
        
        Set<String> oSet = handler.getPostLabelsThatCreateCase();
        
        System.assertEquals(oSet.isEmpty(), true);
        
        String sCuenta = handler.getDefaultAccountId();
        
        System.assertEquals(sCuenta, null);
        
        SocialPost post = getSocialPost(sampleSocialData);
        
        String sRes = handler.getDatosTest (post);
        
        System.assertEquals(sRes, 'OK');
    }
    
    static testMethod void doRT() {
    	Contact existingContact = new Contact(LastName = 'LastName');
    	insert existingContact;
        
    	SocialPersona existingPersona = getSocialPersona(getSampleSocialData('2'));
    	existingPersona.ParentId = existingContact.Id;
    	insert existingPersona;
        
    	Case existingCase = new Case(ContactId = existingContact.Id, Subject = 'Test Case', Status = 'Cerrado');
        existingCase.Origin='Twitter';
        existingCase.CC_Canal_Procedencia__c='CaixaBank';
    	insert existingCase;
        
    	SocialPost existingPost = getSocialPost(getSampleSocialData('2'));
    	existingPost.ParentId = existingCase.Id;
    	existingPost.WhoId = existingContact.Id;
    	existingPost.PersonaId = existingPersona.Id;
    	String recipient = 'scs';
    	existingPost.recipient = recipient;
    	insert existingPost;

        // Vincular el post al caso.
        existingCase.SourceId = existingPost.Id;
        update existingCase;
    	
        Map<String, Object> sampleSocialDataRT = getSampleSocialDataRT('1');
        
        SocialPost post = getSocialPostRT(sampleSocialDataRT);
        post.responseContextExternalId = existingPost.ExternalPostId;
        SocialPersona persona = getSocialPersona(sampleSocialDataRT);
        
        test.startTest();
        handler.handleInboundSocialPost(post, persona, sampleSocialDataRT);
        test.stopTest();
        
        System.assertEquals(2, [SELECT Id FROM SocialPost].size(), 'There should be only 2 posts');      
    }
    
    static Map<String, Object> getSampleSocialDataRT(String suffix) {
        
		List<Map<String,Object>> oList = new List<Map<String,Object>>();
        Map<String,Object> oData = new Map<String,Object>();
        oData.put('mediaType','IMAGE');
        oData.put('mediaUrl','http://pbs.twimg.com/media/D6J4GEDWwAAEbXx.jpg');
		oList.add(oData);
        
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postLabels', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        
		String sAux = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        sAux = sAux + '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        sAux = sAux + '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        
        socialData.put('content', 'Content ' + sAux + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Retweet');
        socialData.put('source', 'Source' + suffix);
        socialData.put('externalPostId', 'RTExternalPostId' + suffix);
        socialData.put('replyToExternalPostId', 'ExternalPostId' + suffix);
        socialData.put('realName', 'Real Name');
        socialData.put('ReviewScore',50);
        socialData.put('mediaUrls', oList);
        socialData.put('followers', '25');
        socialData.put('following', '52');
        socialData.put('tweets', '2');
        socialData.put('verified', true);
        socialData.put('bio', 'bioprueba');
        socialData.put('language','Spanish');
        socialData.put('handle','testhandle');
        
        return socialData;
    }
    
    static SocialPost getSocialPostRT(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
       	post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.ReviewScore = double.valueOf(socialData.get('ReviewScore'));
        post.Language = String.valueOf(socialData.get('language'));
        post.Handle = String.valueOf(socialData.get('handle'));
        post.PostTags = 'test01,test02,test03,test04';
        return post;
    }
}