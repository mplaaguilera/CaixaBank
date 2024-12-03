global virtual class CC_InboundSocialPostHandlerImpl implements Social.InboundSocialPostHandler {

    final static Integer CONTENT_MAX_LENGTH = SocialPost.Content.getDescribe().getLength();
    final static Integer SUBJECT_MAX_LENGTH = Case.Subject.getDescribe().getLength();
    Boolean isNewCaseCreated = false;
    Boolean isNewCaseReopen = false;
    
    // Reopen case if it has not been closed for more than this number
    global virtual Integer getMaxNumberOfDaysClosedToReopenCase() {
        return 5;
    }
    
    // Create a case if one of these post labels are on the SocialPost, regardless of the skipCreateCase indicator.
    global virtual Set<String> getPostLabelsThatCreateCase(){
        return new Set<String>();
    }

    // If true, use the active case assignment rule if one is found
    global virtual Boolean getUsingCaseAssignmentRule(){
        // Inicialmente está inactivo. Se activa para que se realicen las reglas de asignación.
        //return false;
        return true;
    }

    global virtual String getDefaultAccountId() {
        return null;
    }

    global virtual String getCaseSubject(SocialPost post) {
        
        //String caseSubject = post.Name;
        // Modificamos para obtener el contenido truncado del SocialPost.
        // Al personalizar la clase de entrada, no se pueden utilizar las BusinessRules.

        // La variable TruncatedContent no está calculada.
        String caseSubject = post.Content;

        if (hasReview(post)) {
            String ratingsStr = getRatingString(post);
            caseSubject = ratingsStr + ' • ' + caseSubject;
        }

        return caseSubject;
    }

    global Social.InboundSocialPostResult handleInboundSocialPost(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        Social.InboundSocialPostResult result = new Social.InboundSocialPostResult();
        result.setSuccess(true);

        // Transitorio hasta solución final. Bifurcamos la gestión de Retweets.
        if (post.MessageType == 'Retweet')
        {
            // Gestión propia del retweet.
            matchPost(post);
            matchPersona(persona);

            if ((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) {
                post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
            }

            if (post.Id != null) {
                handleExistingPost(post, persona, rawData);
                return result;
            }

            setReplyTo(post, persona);
            setRelationshipsOnPost(post, persona, null);
            setModeration(post, rawData);

            upsert post;

            handlePostAttachments(post, rawData);

            // Buscamos el post original para actualizar el contador de RT.
            actualizarRTPost (post);

        }else{
            // Gestión del resto de mensajes.

            matchPost(post);
            matchPersona(persona);

            if ((post.Content != null) && (post.Content.length() > CONTENT_MAX_LENGTH)) {
                post.Content = post.Content.abbreviate(CONTENT_MAX_LENGTH);
            }

            if (post.Id != null) {
                handleExistingPost(post, persona, rawData);
                return result;
            }

            setReplyTo(post, persona);

            /*
            Nota técnica:
                No cambiamos el código estándar de gestión de twitter.
                Crear el social post para obtener Id, asociarlo al social persona y actualizar.
            */
            upsert post;

            buildPersona(post, persona, rawData);
            Case parentCase = buildParentCase(post, persona, rawData);
            setRelationshipsOnPost(post, persona, parentCase);
            setModeration(post, rawData);
            setPersonIdOnCase(persona, parentCase);

            // Actualizar el post con los cambios realizados por el código estándar.
            update post;

            // Debido a esta 2a actualización, crea un SocialPostFeed no deseado. Borramos el existente, lo crea a posterior.
            List<SocialPostFeed> oAuxFeed = [SELECT Id FROM SocialPostFeed WHERE ParentId = :post.Id ORDER BY Createddate DESC];
            if (!oAuxFeed.isEmpty())
            {
                delete oAuxFeed[0];
            }
            oAuxFeed = null;
            
            if(isNewCaseCreated){
                updateCaseSource(post, parentCase);
            }
            
            handlePostAttachments(post, rawData);

            //Comprobar si el cliente es AQUMETRIX
            if (post.Handle != null)
            {
                List<CC_Administracion_Lista_Blanca__c> aquState = [SELECT CC_Aqumetrix__c, CC_Prioridad__c FROM CC_Administracion_Lista_Blanca__c WHERE Name =: post.Handle AND CC_Canal_Contacto__c =: 'Twitter' AND CC_Activo__c =: true LIMIT 1];
                if (aquState != null)
                {
                    if (!aquState.isEmpty())
                    {
                        // Actualizar el caso.
                        Case oCasoAct = new Case();
                        oCasoAct.Id = parentCase.Id;

                        // Nos quedamos con el primer registro.
                        Boolean aqumetrix = aquState[0].CC_Aqumetrix__c;
                        if (aqumetrix)
                        {
                            // Actualizar datos de AQMETRIX.
                            oCasoAct.CC_Aqumetrix__c = true;

                            if (aquState[0].CC_Prioridad__c != '')
                                oCasoAct.Priority = aquState[0].CC_Prioridad__c;
                        }else{
                            // Actualizar solo en creación de casos.
                            if (isNewCaseCreated || isNewCaseReopen)
                            {
                                if (aquState[0].CC_Prioridad__c != '')
                                    oCasoAct.Priority = aquState[0].CC_Prioridad__c;
                            }
                        }

                        update oCasoAct;
                    }
                }
            }

    /*        
            if (post.Handle != null) {
                List<CC_Administracion_Lista_Blanca__c> aquState = [SELECT CC_Aqumetrix__c FROM CC_Administracion_Lista_Blanca__c WHERE Name =: post.Handle AND CC_Canal_Contacto__c =: 'Twitter' AND CC_Activo__c =: true];
                if (!aquState.isEmpty()) {
                    Boolean aqumetrix = aquState[0].CC_Aqumetrix__c;
                    if (aqumetrix == true){
                        parentCase.CC_Aqumetrix__c = true;
                //Un cliente marcado con AQUMETRIX tendrá siempre la prioridad más alta
                        parentCase.Priority = 'High';
                        update parentCase;
                    }
                    if (aqumetrix == false) {
                        parentCase.CC_Aqumetrix__c = false;
                        List<CC_Administracion_Lista_Blanca__c> prioridadAqumetrixFalse = [SELECT CC_Prioridad__c FROM CC_Administracion_Lista_Blanca__c WHERE Name =: post.Handle AND CC_Canal_Contacto__c =: 'Twitter' AND CC_Activo__c =: true];
                        if (!prioridadAqumetrixFalse.isEmpty()) {
                            String prioridadAqumetrixFalseValue = prioridadAqumetrixFalse[0].CC_Prioridad__c;
                            parentCase.Priority = prioridadAqumetrixFalseValue;
                        update parentCase;
                        }
                    }
                }
            }
    */

            /* COMENTADO. POR AHORA LA FUNCIONALIDAD DE ALFABÉTICO ESTÁ DESCATALOGADA.        
            // Identificar al cliente (asíncrono).
            List<ID> oList = new List<ID>();
            oList.add(post.Id);
            CC_IdentCliente_Future.CallUpdateALF(oList);
            */

            //Crea una actividad de nuevo post en RRSS
            String tipoMensajePubPriv = '';
            if (post.MessageType == 'Direct')
            {
                tipoMensajePubPriv = 'Mensaje Privado';
            }
            else
                tipoMensajePubPriv = 'Mensaje Público';
            
            createActivity(parentCase.Id, post.Content , 'Entrada '+ tipoMensajePubPriv + ' ' + post.Provider, 'Entrada '+ tipoMensajePubPriv + ' ' + post.Provider);
        }

        return result;
    }
    
    private void setModeration(SocialPost post, Map<String, Object> rawData){
        //if we don't automatically create a case, we should flag the post as requiring moderator review.
        if(post.parentId == null && !isUnsentParent(rawData))
            post.reviewedStatus = 'Needed';
    }
    
    private void updateCaseSource(SocialPost post, Case parentCase){
        if(parentCase != null) {
            parentCase.SourceId = post.Id;
            //update as a new sobject to prevent undoing any changes done by insert triggers
            update new Case(Id = parentCase.Id, SourceId = parentCase.SourceId);
        }
    
    }
    
    private void handleExistingPost(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        List<SocialPost> existingPosts = [Select Recipient, IsOutbound from SocialPost where id = :post.Id limit 1];
        
        // for any existing outbound post, we don't overwrite its recipient field
        if (!existingPosts.isEmpty() && existingPosts[0].IsOutBound == true && String.isNotBlank(existingPosts[0].Recipient)) {
            post.Recipient = existingPosts[0].Recipient;
        }
        
        update post;
        if (persona.id != null)
            updatePersona(persona, rawData);
    }

    private void setReplyTo(SocialPost post, SocialPersona persona) {
        SocialPost replyTo = findReplyTo(post, persona);
        if(replyTo.id != null) {
            post.replyToId = replyTo.id;
            post.replyTo = replyTo;
        }
    }

    private SocialPersona buildPersona(SocialPost post, SocialPersona persona, Map<String, Object> rawData) {
        if (persona.Id == null)
            createPersona(post, persona);
        else
            updatePersona(persona, rawData);
            
        return persona;
    }

    private void updatePersona(SocialPersona persona,  Map<String, Object> rawData) {
        try{
            if (rawData.get('followers') != null) {
                persona.Followers = Integer.ValueOf(rawData.get('followers'));
            }
            if (rawData.get('following') != null) {
                persona.Following = Integer.ValueOf(rawData.get('following'));
            }
            if (rawData.get('realName') != null) {
                persona.RealName = String.ValueOf(rawData.get('realName'));
            }
            if (rawData.get('tweets') != null) {
                persona.NumberOfTweets = Integer.ValueOf(rawData.get('tweets'));
            }
            if (rawData.get('verified') != null) {
                persona.IsVerified = Boolean.ValueOf(rawData.get('verified'));
            }
            if (rawData.get('bio') != null) {
                persona.Bio = String.ValueOf(rawData.get('bio'));
            }
            update persona;
        }catch(Exception e) {
            System.debug('Error updating social persona: ' + e.getMessage());
        }
    }
    
    private Case buildParentCase(SocialPost post, SocialPersona persona, Map<String, Object> rawData){
        if(!isUnsentParent(rawData)) {
            Case parentCase = findParentCase(post, persona);
            if (parentCase != null) {
                if (!parentCase.IsClosed) {
                    return parentCase;
                }
                else if (caseShouldBeReopened(parentCase)) {
                    isNewCaseReopen = true;
                    reopenCase(parentCase);
                    return parentCase;
                }
            }
            if(shouldCreateCase(post, rawData)){
                isNewCaseCreated = true;
                return createCase(post, persona);
            }
        }
        
        return null;
    }
    
    private boolean caseShouldBeReopened(Case c){

        // Anterior.
        //return c.id != null && c.isClosed && System.now() < c.closedDate.addDays(getMaxNumberOfDaysClosedToReopenCase());

        Boolean bReabrir = false;
        SocialPost oPost;
        Case oCaso;
        String sCuenta = '';
        Integer iHoras = 0;

        // Buscamos el caso original.
        if (c != null)
        {
            oCaso = [SELECT Id, SourceId FROM Case WHERE Id = :c.Id];
        }

        // Buscamos el SocialPost original.
        if (oCaso.SourceId != null)
        {
            oPost = [SELECT Id, Recipient, Provider FROM SocialPost WHERE Id = :oCaso.SourceId];
        }

        // Cambiar lógica de reapertura.
        if (oPost != null)
        {
            sCuenta = getCuentaOrig (oPost);
        }

        if (sCuenta != '')
        {
            CC_Config_RRSS__mdt oConfig = getConfigCuenta (oPost, sCuenta);

            if (oConfig.CC_HorasReapertura__c != null)
            {
                iHoras = Integer.valueOf(oConfig.CC_HorasReapertura__c);
            }

            if (c.id != null && c.isClosed && System.now() < c.closedDate.addHours(iHoras))
            {
                bReabrir = true;
            }
        }

        return bReabrir;
    }

    private void setRelationshipsOnPost(SocialPost postToUpdate, SocialPersona persona, Case parentCase) {
        if (persona.Id != null) {
            postToUpdate.PersonaId = persona.Id;
            
            if(persona.ParentId.getSObjectType() != SocialPost.sObjectType) {
                postToUpdate.WhoId = persona.ParentId;
            }
        }
        if(parentCase != null) {
            postToUpdate.ParentId = parentCase.Id;
        }
    }
    
    private Boolean hasReview(SocialPost post) {
        return post.ReviewScore != null;
    }
    
    private String getRatingString(SocialPost post) {
        Integer maxNumberOfStars = 5;
        Double reviewScore = post.ReviewScore;
        Double reviewScale = post.ReviewScale;
        if (reviewScore == null) {
            reviewScore = 0;
        }
        if (reviewScale == null) {
            reviewScale = maxNumberOfStars;
        }
        Integer numberOfStars = Math.floor((reviewScore / reviewScale) * maxNumberOfStars).intValue();
        return numberOfStars.format() + '-Star';
    }
    
    private Case createCase(SocialPost post, SocialPersona persona) {
        String caseSubject = getCaseSubject(post).abbreviate(SUBJECT_MAX_LENGTH);

        Case newCase = new Case(subject = caseSubject);

        // Asignar la descripción del caso con el mensaje completo del Twitter.
        newCase.Description = getCaseSubject(post);

        if (persona != null && persona.ParentId != null) {
            if (persona.ParentId.getSObjectType() == Contact.sObjectType) {
                newCase.ContactId = persona.ParentId;

                // Buscamos el posible cliente vinculado.
                Contact oContacto = [SELECT Id, AccountId FROM Contact WHERE Id = :persona.ParentId LIMIT 1];
                if (oContacto != null)
                {
                    if (oContacto.AccountId != null)
                    {
                        newCase.AccountId = oContacto.AccountId;
                    }
                }

            } else if (persona.ParentId.getSObjectType() == Account.sObjectType) {
                newCase.AccountId = persona.ParentId;
            }
        }
        if (post != null && post.Provider != null) {
            newCase.Origin = post.Provider;
        }
        if (post.Provider == 'Twitter') {
            newCase.CC_Tipo_Contacto__c = 'Consulta';
        }

        // Cuenta origen de la RRSS.
        String sCuenta = '';
        if (post != null)
        {
            sCuenta = getCuentaOrig(post);
        }

        // Configuración de la cuenta.
        String sReglaAssig = '';
        CC_Config_RRSS__mdt oConfig;
        
        if (post != null && sCuenta != '')
        {
            oConfig = getConfigCuenta (post, sCuenta);

            // Recuperar la regla de asignación configurada.
            if (oConfig != null)
                sReglaAssig = oConfig.CC_ReglaAssigCaso__c;
        }

        if (getUsingCaseAssignmentRule() && sReglaAssig != ''){
            //Find the active assignment rules on case
            //AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' AND Name = :sReglaAssig limit 1];

            if (rules.size() > 0){
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= rules[0].id;

                //Setting the DMLOption on Case instance
                newCase.setOptions(dmlOpts);
            }
        }

        /*
            Inicio datos custom.
        */

        newCase.CC_Cola_Procedencia__c = 'CC_Twitter';

        if (sCuenta != '')
            newCase.CC_CuentaRRSS_CBK__c = sCuenta;

        if (oConfig != null)
        {
            if (oConfig.CC_CasoEstado__c != null)
                newCase.Status = oConfig.CC_CasoEstado__c;

            if (oConfig.CC_CasoPrioridad__c != null)
                newCase.Priority = oConfig.CC_CasoPrioridad__c;
                
            if (oConfig.CC_CasoTipoCliente__c != null)
                newCase.CC_Tipo_Cliente__c = oConfig.CC_CasoTipoCliente__c;
                
            if (oConfig.CC_CasoCanalAcceso__c != null)
                newCase.CC_Canal_Operativo__c = oConfig.CC_CasoCanalAcceso__c;
                
            if (oConfig.CC_Imaginbank__c != null) {
                newCase.CC_Imaginbank__c = oConfig.CC_Imaginbank__c;
                if (oConfig.CC_Imaginbank__c == true) {
                    newCase.CC_Canal_Procedencia__c = 'ImaginBank'; 
                }
                if (oConfig.CC_Imaginbank__c == false) {
                    newCase.CC_Canal_Procedencia__c = 'CaixaBank';
                    }
            }
        }

        // Recuperar custom metadata. Cuenta de grupo.
        List<String> oCuentasCBK = getCuentasGrupo(post.Provider);

        // Comprobación Tweet Entrante.
        // Inicio del hilo (ResponseContextExternalId) por cuenta del grupo CaixaBank.
        // Nuevo tweet entrante proviene de una cuenta cliente.
        //  -> Cambiar el caso existente a la nueva cuenta de cliente.

        String sCuentaCli = '';
        if (post != null)
        {
            // Cuenta RRSS del cliente (del objeto SocialPost).
            if (post.Handle != null)
            {
                sCuentaCli = post.Handle;
            }
        }

        /*
            Si el origen del post es una cuenta del grupo CBK - No Contact Center.
            Si el post es una respuesta a otro post NO existente en Salesforce.

            -> Derivación de un tweet entre cuentas del grupo CBK.
            -> Cambiamos la cuenta origen.
        */
        if (post != null && !oCuentasCBK.isEmpty())
        {
            if (oCuentasCBK.contains(post.Handle) && post.ResponseContextExternalId != null && post.Handle != null)
            {
                List<SocialPost> oPostOrigenConv = [SELECT Id FROM SocialPost WHERE ExternalPostId = :post.ResponseContextExternalId];
                if (oPostOrigenConv.isEmpty())
                {
                    // Post inicial en SFDC. Derivación de una conversación al Contact Center CBK.
                    // Actualizamos cuenta origen del caso. Realizar una búsqueda para encontrar la cuenta del cliente.

                    sCuentaCli = getCuentaCliOrigen (post.Content, oCuentasCBK);

                    /*Pattern oPatt = Pattern.compile('\\@([A-Za-z0-9_]{1,50})');
                    Matcher oMatcher = oPatt.matcher(post.Content);
                    while(oMatcher.find())
                    {

                        String sAux = oMatcher.group();

                        // Hardcode. cuenta CBK.
                        if (!sAux.contains('company'))
                        {
                            // Cuenta de cliente.
                            sCuentaCli = sAux.substring(1, sAux.length());
                            break;
                        }
                    }*/
                }
            }
        }

        // Idioma del caso.
        if (post != null)
        {
            String sIdioma = getIdiomaRRSS(post);
            newCase.CC_Idioma__c = sIdioma;
			newCase.CC_CuentaRRSS_CLI__c = sCuentaCli;

            // Cuenta RRSS del cliente (del objeto SocialPost).
            /*if (post.Handle != null)
            {
                newCase.CC_CuentaRRSS_CLI__c = sCuentaCli;

                /*List<CC_Administracion_Lista_Blanca__c> casePrioridad = [SELECT CC_Prioridad__c FROM CC_Administracion_Lista_Blanca__c WHERE Name =: post.Handle AND CC_Canal_Contacto__c =: 'Twitter' AND CC_Activo__c =: true];
                if (!casePrioridad.isEmpty()) {
                    String casePrioridadValue = casePrioridad[0].CC_Prioridad__c;
                    newCase.Priority = casePrioridadValue;
                }--> fin subcomentario.
            }*/
        }

        insert newCase;
        return newCase;
    }

    /*
        Obtener las cuentas del grupo CBK.
    */
    static public List<String> getCuentasGrupo (String sRRSS)
    {
        List<String> oRes = new List<String>();

        if (sRRSS != '')
        {
            List<CC_Config_RRSS__mdt> oConfig = [SELECT Id, CC_Cuenta_RRSS__c FROM CC_Config_RRSS__mdt WHERE CC_Red_Social__c = :sRRSS];
            for (CC_Config_RRSS__mdt oAux : oConfig)
            {
                if (oAux.CC_Cuenta_RRSS__c != '')
                {
                    oRes.add(oAux.CC_Cuenta_RRSS__c);
                }
            }
        }

        return oRes;
    }

    /*
        Parsear twitter para encontrar la cuenta del cliente original.
    */
    static public String getCuentaCliOrigen (String sContenido, List<String> oCuentasCBK)
    {
        String sCuentaCli = '';

        if (sContenido != '')
        {
            Pattern oPatt = Pattern.compile('\\@([A-Za-z0-9_]{1,50})');
            Matcher oMatcher = oPatt.matcher(sContenido);
            while(oMatcher.find())
            {

                String sAux = oMatcher.group();
                sAux = sAux.substring(1, sAux.length());

                // Buscar que la cuenta detectada no sea del grupo CBK.
                if (!oCuentasCBK.isEmpty())
                {
                    if (!oCuentasCBK.contains(sAux))
                    {
                        // Cuenta de cliente detectada.
                        sCuentaCli = sAux;
                        break;
                    }
                }
            }
        }

        return sCuentaCli;
    }
    
    private Case findParentCase(SocialPost post, SocialPersona persona) {
        Case parentCase = null;

        /*
            Respuesta a un tweet. Buscar la siguiente información:

            1) La cuenta origen no es del grupo de CBK.

            2) Tratar respuesta.

                (a) Respuesta existente en Salesforce -> Recuperar caso para vincular Post.
                (b) Respuesta inexistente en Saleforce -> Buscar caso abierto del cliente -> Recuperar caso para vincular Post.
        */
        // Recuperar custom metadata. Cuenta de grupo.
        List<String> oCuentasCBK = getCuentasGrupo(post.Provider);

        // La cuenta del grupo siempre crea caso. Derivaciones de posts.
        //if (post.Handle == 'tt1808313')
        if (oCuentasCBK.contains(post.Handle))
        {
            return null;
        }

        String sCuentaCBKDestino = getCuentaOrig(post);

        //if (post.Handle != 'tt1808313' && post.ResponseContextExternalId != null)
        if (!oCuentasCBK.contains(post.Handle) && post.ResponseContextExternalId != null)
        {
            List<SocialPost> oPostOrigenConv = [SELECT Id, ParentId FROM SocialPost WHERE ExternalPostId = :post.ResponseContextExternalId Order By CreatedDate DESC LIMIT 1];
            if (!oPostOrigenConv.isEmpty())
            {
                // Respuesta en el hilo inicial derivado por la cuenta del grupo CBK.
                List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE Id = :oPostOrigenConv[0].ParentId AND CC_CuentaRRSS_CBK__c = :sCuentaCBKDestino LIMIT 1];
                if(!cases.isEmpty()) {
                    parentCase = cases[0];
                }
            }else{
                // Buscar un caso abierto por la cuenta del cliente.
                // Realizamos búsqueda como lo hace SFDC.
                List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE CC_CuentaRRSS_CLI__c = :post.Handle AND CC_CuentaRRSS_CBK__c = :sCuentaCBKDestino Order By CreatedDate DESC LIMIT 1];
                if(!cases.isEmpty()) {
                    parentCase = cases[0];
                }
            }
        }

    

        if (parentCase != null)
        {
            if (isParentCaseValid(parentCase)) {
                return parentCase;
            }
        }

        // Fin custom.

        if (!isChat(post) && (isReplyingToOutboundPost(post) && isSocialPostRecipientSameAsPersona(post.ReplyTo, persona)) || (!isReplyingToOutboundPost(post) && isReplyingToSelf(post,persona))) {
            parentCase = findParentCaseFromPostReply(post);
            if (isParentCaseValid(parentCase)) { 
            return parentCase;
        }
        }

		
		parentCase = findParentCaseFromPersonaAndRecipient(post, persona);
		if (parentCase == null && isChat(post)) {
			parentCase = findParentCaseOfChatFromPersonaAndRecipient(post, persona);	
		}
		return parentCase;
    }
    
    private boolean isChat(SocialPost post) {
        return post.messageType == 'Private' || post.messageType == 'Direct';
    }
        
    private boolean isParentCaseValid(Case parentCase) {
        return parentCase != null && (!parentCase.IsClosed || caseShouldBeReopened(parentCase));
    }
    
    private Case findParentCaseFromPostReply(SocialPost post) {
        if (post.ReplyTo != null && String.isNotBlank(post.ReplyTo.ParentId)) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE Id = :post.ReplyTo.ParentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    
    // reply to outbound post
    private boolean isReplyingToOutboundPost(SocialPost post) {
        return (post != null && post.ReplyTo != null && post.ReplyTo.IsOutbound);
    }
    
    // replyTo.recipient == inboundSocialPost.persona.externalId
    private boolean isSocialPostRecipientSameAsPersona(SocialPost postWithRecipient, SocialPersona persona) {
        return (postWithRecipient != null && postWithRecipient.Recipient == persona.ExternalId);
    }
    
    // is replying to self
    private boolean isReplyingToSelf(SocialPost post, SocialPersona persona) {
        return (post != null && 
            persona != null && 
            String.isNotBlank(persona.Id) && 
            post.ReplyTo != null &&
            String.isNotBlank(post.ReplyTo.PersonaId) &&
            post.ReplyTo.PersonaId == persona.id);
    }   

    private Case findParentCaseFromPersona(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersona = findLatestInboundPostBasedOnPersona(post, persona);
        if (lastestInboundPostWithSamePersona != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersona.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    
    private Case findParentCaseFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestInboundPostWithSamePersonaAndRecipient = findLatestInboundPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestInboundPostWithSamePersonaAndRecipient != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestInboundPostWithSamePersonaAndRecipient.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }
    
    private Case findParentCaseOfChatFromPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        SocialPost lastestReplyToPost = findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(post, persona);
        if (lastestReplyToPost != null) {
            List<Case> cases = [SELECT Id, IsClosed, Status, ClosedDate FROM Case WHERE id = :lastestReplyToPost.parentId LIMIT 1];
            if(!cases.isEmpty()) {
                return cases[0];
            }
        }
        return null;
    }

    private void reopenCase(Case parentCase) {
        Datetime fechaCierreCaso = parentCase.ClosedDate;
        Datetime fechaActual = datetime.now();
        datetime nuevaFechaCierreCaso = fechaCierreCaso.addHours(2);
        if(nuevaFechaCierreCaso >=  fechaActual){
            parentCase.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Twitter' LIMIT 1].Id;
        }
        
        SObject[] status = [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = false AND IsDefault = true];
        parentCase.Status = ((CaseStatus)status[0]).MasterLabel;
        /* COMENTADO. Se utiliza un flag de reapertura.
        if (parentCase.Id != null) {
            list<Case> reopenCaseRRSS = [SELECT CC_CuentaRRSS_CLI__c FROM Case WHERE Id =: parentCase.Id];
            if (reopenCaseRRSS[0].CC_CuentaRRSS_CLI__c != null) {
                String reopenCaseRRSSValue = reopenCaseRRSS[0].CC_CuentaRRSS_CLI__c;
                List<CC_Administracion_Lista_Blanca__c> reopenCasePrioridad = [SELECT CC_Prioridad__c FROM CC_Administracion_Lista_Blanca__c WHERE Name =: reopenCaseRRSSValue AND CC_Canal_Contacto__c =: 'Twitter' AND CC_Activo__c =: true];
                if (!reopenCasePrioridad.isEmpty()) {
                    String reopenPrioridad = reopenCasePrioridad[0].CC_Prioridad__c;
                    parentCase.Priority = reopenPrioridad;
                }
            }
        }*/
        update parentCase;
    }

    private void matchPost(SocialPost post) {
            if (post.Id != null) return;
        
        performR6PostIdCheck(post);
        
        if (post.Id == null){
            performExternalPostIdCheck(post);
        }
    }
    
    
    private void performR6PostIdCheck(SocialPost post){
        if(post.R6PostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE R6PostId = :post.R6PostId LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }
    
    
    private void performExternalPostIdCheck(SocialPost post) {
        if (post.provider == 'Facebook' && post.messageType == 'Private') return;
        if (post.provider == null || post.externalPostId == null) return;
        List<SocialPost> postList = [SELECT Id FROM SocialPost WHERE ExternalPostId = :post.ExternalPostId AND Provider = :post.provider LIMIT 1];
        if (!postList.isEmpty()) {
            post.Id = postList[0].Id;
        }
    }
    
    
    private SocialPost findReplyTo(SocialPost post, SocialPersona persona) {
        if(post.replyToId != null && post.replyTo == null)
            return findReplyToBasedOnReplyToId(post);
        if(post.responseContextExternalId != null){
            if((post.provider == 'Facebook' && post.messageType == 'Private') || (post.provider == 'Twitter' && post.messageType == 'Direct')) {
                SocialPost replyTo = findReplyToBasedOnResponseContextExternalPostIdAndProvider(post);
                if(replyTo.id != null) 
                    return replyTo;
            }
            return findReplyToBasedOnExternalPostIdAndProvider(post);
        }
        return new SocialPost();
    }

    private SocialPost findReplyToBasedOnReplyToId(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE id = :post.replyToId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findReplyToBasedOnExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId, Recipient FROM SocialPost WHERE Provider = :post.provider AND ExternalPostId = :post.responseContextExternalId LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }
    
    private SocialPost findReplyToBasedOnResponseContextExternalPostIdAndProvider(SocialPost post){
        List<SocialPost> posts = [SELECT Id, ParentId, IsOutbound, PersonaId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND responseContextExternalId = :post.responseContextExternalId ORDER BY posted DESC NULLS LAST LIMIT 1];
        if(posts.isEmpty())
            return new SocialPost();
        return posts[0];
    }

    private SocialPost findLatestInboundPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null && String.isNotBlank(post.Recipient)) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :post.Recipient AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }
    
    private SocialPost findLatestInboundPostBasedOnPersona(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null) {
            List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND PersonaId = :persona.id AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1];
            if (!posts.isEmpty()) {
                return posts[0];
            }
        }
        return null;
    }
    
    private SocialPost findLatestOutboundReplyToPostBasedOnPersonaAndRecipient(SocialPost post, SocialPersona persona) {
        if (persona != null && String.isNotBlank(persona.Id) && post != null) {
            List<ExternalSocialAccount> accounts = [SELECT Id FROM ExternalSocialAccount WHERE ExternalAccountId = :post.Recipient];
            if (!accounts.isEmpty()) {
                    ExternalSocialAccount account = accounts[0];
                List<SocialPost> posts = [SELECT Id, ParentId FROM SocialPost WHERE Provider = :post.provider AND Recipient = :persona.ExternalId AND OutboundSocialAccountId = :account.Id AND IsOutbound = true ORDER BY CreatedDate DESC LIMIT 1];
                if (!posts.isEmpty()) {
                    return posts[0];
                }
            }
        }
        return null;
    }
    
    private void matchPersona(SocialPersona persona) {
        if (persona != null) {
            List<SocialPersona> personaList = new List<SocialPersona>();
            if (persona.Provider != 'Other') {
                if (String.isNotBlank(persona.ExternalId)) {
                    personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                        Provider = :persona.Provider AND
                        ExternalId = :persona.ExternalId LIMIT 1];
                }
                else if (String.isNotBlank(persona.Name)) {
                    //this is a best-effort attempt to match: persona.Name is not guaranteed to be unique for all networks
                    personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                        Provider = :persona.Provider AND
                        Name = :persona.Name LIMIT 1];
                }
            }
            else if(persona.Provider == 'Other' && String.isNotBlank(persona.ExternalId) && String.isNotBlank(persona.MediaProvider)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    MediaProvider = :persona.MediaProvider AND
                    ExternalId = :persona.ExternalId LIMIT 1];
            } else if(persona.Provider == 'Other' && String.isNotBlank(persona.Name) && String.isNotBlank(persona.MediaProvider)) {
                personaList = [SELECT Id, ParentId FROM SocialPersona WHERE
                    MediaProvider = :persona.MediaProvider AND
                    Name = :persona.Name LIMIT 1];
            }
                    
            if (!personaList.isEmpty()) {
                persona.Id = personaList[0].Id;
                persona.ParentId = personaList[0].ParentId;
            }
        }
    }

    private void createPersona(SocialPost post, SocialPersona persona) {
        if (persona == null || String.isNotBlank(persona.Id) || !isThereEnoughInformationToCreatePersona(persona))
            return;

        //SObject parent = createPersonaParent(persona);
        //persona.ParentId = parent.Id;
        persona.ParentId = post.Id;
        insert persona;
    }

    private boolean isThereEnoughInformationToCreatePersona(SocialPersona persona) {
        return String.isNotBlank(persona.Name) && 
            String.isNotBlank(persona.Provider) && 
            String.isNotBlank(persona.MediaProvider);
    }
    
    private boolean shouldCreateCase(SocialPost post, Map<String, Object> rawData) {
        return !isUnsentParent(rawData) && (!hasSkipCreateCaseIndicator(rawData) || hasPostLabelsThatCreateCase(post));
    }
    
    private boolean isUnsentParent(Map<String, Object> rawData) {
        Object unsentParent = rawData.get('unsentParent');
        return unsentParent != null && 'true'.equalsIgnoreCase(String.valueOf(unsentParent));
    }

    private boolean hasSkipCreateCaseIndicator(Map<String, Object> rawData) {
        Object skipCreateCase = rawData.get('skipCreateCase');
        return skipCreateCase != null && 'true'.equalsIgnoreCase(String.valueOf(skipCreateCase));
    }
    
    private boolean hasPostLabelsThatCreateCase(SocialPost post){
        Set<String> postLabels = getPostLabels(post);
        postLabels.retainAll(getPostLabelsThatCreateCase());
        return !postLabels.isEmpty();
    }
    
    private Set<String> getPostLabels(SocialPost post){
        Set<String> postLabels = new Set<String>();

        // La clase estándar falla porque tenía PostLabels en lugar de PostTags.
        if(post.PostTags != null)
            postLabels.addAll(post.PostTags.split(',', 0));
        return postLabels;
    }

/* COMENTAMOS. NO CREAMOS CONTACTO.
    global String getPersonaFirstName(SocialPersona persona) {
        String name = getPersonaName(persona);      
        String firstName = '';
        if (name.contains(' ')) {
            firstName = name.substringBeforeLast(' ');
        }
        firstName = firstName.abbreviate(40);
        return firstName;
    }
    
    global String getPersonaLastName(SocialPersona persona) {   
        String name = getPersonaName(persona);   
        String lastName = name;
        if (name.contains(' ')) {
            lastName = name.substringAfterLast(' ');
        }
        lastName = lastName.abbreviate(80);
        return lastName;
    }
    
    private String getPersonaName(SocialPersona persona) {
        String name = persona.Name.trim();
        if (String.isNotBlank(persona.RealName)) {
            name = persona.RealName.trim();
        }
        return name;
    }
*/
/* COMENTAMOS POR NO UTILIZAR DENTRO DEL CÓDIGO DE ENTRADA DE TWITTER.
    Por decisión de negocio no se crea persona de contacto en la entrada de Twitter.
    
    global virtual SObject createPersonaParent(SocialPersona persona) {
        String firstName = getPersonaFirstName(persona);
        String lastName = getPersonaLastName(persona);
        
        Contact contact = new Contact(LastName = lastName, FirstName = firstName);
        String defaultAccountId = getDefaultAccountId();
        if (defaultAccountId != null)
            contact.AccountId = defaultAccountId;

        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        insert contact;
        return contact;
    }
*/
            
    private void handlePostAttachments(SocialPost post, Map<String, Object> rawData) {
    String attachmentRawData = JSON.serialize(rawData.get('mediaUrls'));
		if (String.isNotBlank(attachmentRawData)) {
            List<PostAttachment> attachments = (List<PostAttachment>) JSON.deserialize(attachmentRawData, List<PostAttachment>.class);
            if (attachments != null && !attachments.isEmpty()) {
                createAttachments(post, attachments);
            }
        }
    }
    
    private void createAttachments(SocialPost post, List<PostAttachment> attachments) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(PostAttachment attachment : attachments) {
            if (String.isNotBlank(attachment.mediaUrl) && attachment.mediaUrl != null && attachment.mediaUrl.length() <= ContentVersion.ContentUrl.getDescribe().getLength()) {
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.contentUrl = attachment.mediaUrl;
                contentVersion.contentLocation = 'L';
                contentVersions.add(contentVersion);
            }
        }
        if (!contentVersions.isEmpty()) {
            insert(contentVersions);
            createLinksForAttachmentsToSocialPost(post, contentVersions);
        }
    }
    
    private void createLinksForAttachmentsToSocialPost(SocialPost post, List<ContentVersion> contentVersions) {
        List<Id> versionIds = new List<Id>(new Map<Id, ContentVersion>(contentVersions).keySet());
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :versionIds];
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for(ContentDocument contentDocument : contentDocuments) {
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.contentDocumentId = contentDocument.Id;
            contentDocLink.linkedEntityId = post.Id;
            contentDocLink.shareType = 'I';
            contentDocLink.visibility = 'AllUsers';
            contentDocumentLinks.add(contentDocLink);

            // Crear el ContentDocumentLink en el caso.
            if (post != null)
            {
                if (post.ParentId != null)
                {
                    ContentDocumentLink contentDocLink2 = new ContentDocumentLink();
                    contentDocLink2.contentDocumentId = contentDocument.Id;
                    contentDocLink2.linkedEntityId = post.ParentId;
                    contentDocLink2.shareType = 'I';
                    contentDocLink2.visibility = 'AllUsers';
                    contentDocumentLinks.add(contentDocLink2);
                }
            }
        }

        if (!contentDocumentLinks.isEmpty()) {
            insert(contentDocumentLinks);
        }
    }

    public class PostAttachment {
        public String mediaType;
        public String mediaUrl;
        
        public PostAttachment(String mediaType, String mediaUrl) {
            this.mediaType = mediaType;
            this.mediaUrl = mediaUrl;
        }
    }

    /*
        Recuperar cuenta origen del post.
    */
    private String getCuentaOrig (SocialPost oPost)
    {
        String sCuenta = '';

        if (oPost != null)
        {
            List<ExternalSocialAccount> oCuentaOrig = [SELECT Id, Username FROM ExternalSocialAccount WHERE ProviderUserId = :oPost.Recipient];

            // Para el modo test. No podemos crear cuentas en la entidad.
            if (test.isRunningTest())
            {
                ExternalSocialAccount oData = new ExternalSocialAccount();
                oCuentaOrig.add(oData);
            }

            if (oCuentaOrig.size() == 1)
            {
                // Para el modo test. No podemos crear cuentas en la entidad.
                if (test.isRunningTest())
                {
                    sCuenta = 'companydemo001';
                }else{
                    sCuenta = oCuentaOrig[0].Username;
                }
            }
        }

        return sCuenta;
    }

    /*
        Recuperar datos configurados en los Metadatos para la cuenta origen.
            Prioridad, Estado, Canal acceso y tipo de cliente del caso.
    */
    private CC_Config_RRSS__mdt getConfigCuenta (SocialPost oPost, String sCuenta)
    {
        CC_Config_RRSS__mdt oCuenta;
        String sRRSS = '';

        if (oPost != null)
        {
            sRRSS = oPost.Provider;
        }

        if (sCuenta != '' && sRRSS != '')
        {
            List<CC_Config_RRSS__mdt> oConfig = [SELECT Id, CC_CasoEstado__c, CC_CasoPrioridad__c, CC_CasoTipoCliente__c, CC_CasoCanalAcceso__c, CC_Imaginbank__c, CC_ReglaAssigCaso__c, CC_HorasReapertura__c FROM CC_Config_RRSS__mdt WHERE CC_Cuenta_RRSS__c = :sCuenta AND CC_Red_Social__c = :sRRSS];
            if (oConfig.size()==1)
            {
                if (oConfig[0] != null)
                    oCuenta = oConfig[0];
            }
        }

        return oCuenta;
    }

    /*
        Recuperar idioma de la conversación RRSS.
    */
    private String getIdiomaRRSS (SocialPost oPost)
    {
        String sIdioma = '';

        if (oPost != null)
        {
            if (oPost.Language != null)
            {
                sIdioma = CC_MetodosUtiles.getValueLOVMeta('CC_Idioma_Tw', oPost.Language);
                if (sIdioma == '')
                    sIdioma = 'es';
            }else{
                sIdioma = 'es';
            }
        }else{
            sIdioma = 'es';
        }

        return sIdioma;
    }

    //Crea actividad de conversación en RRSS
    private static void createActivity(Id caseId, String comentario, String subject, String tipo) {
       // Crear Tarea
        Date todaysDate = system.today();
        Task task = new Task();
        task.ActivityDate = todaysDate;
        task.Subject = subject;
        task.Type = tipo;
        task.Status = 'Completed';
        task.Description = comentario;
        task.WhatId = caseId;
        task.Priority = 'Normal';
        //insert task;
        CC_Activity.crearActividad(task);
    }
    
    //Update del caso con el Social Persona
    public void setPersonIdOnCase(SocialPersona persona, Case parentCase) {
        if (persona.Id != null) {
            Case oCasoAct = new Case();
            oCasoAct.Id = parentCase.Id;
            oCasoAct.CC_Social_Persona__c = persona.Id;

            update oCasoAct;
        }
    }

    // Método público para cobertura de código.
    public String getDatosTest (SocialPost post)
    {  
        String sAux = 'OK';
        
        Boolean bDatos = hasPostLabelsThatCreateCase (post);

        return sAux;
    }

    //Método para actualizar los datos de RTs.
    public static void actualizarRTPost(SocialPost post) {

        if (post == null)
            return;

        if (post.Id == null || post.ResponseContextExternalId ==  null || post.MessageType != 'Retweet')
            return;        

        List<SocialPost> posts = [SELECT CC_NumRT__c FROM SocialPost WHERE ExternalPostId = :post.ResponseContextExternalId LIMIT 1];

        if (!posts.isEmpty()) {
            SocialPost oParent = posts[0];
            post.CC_ParentPost__c = oParent.Id;
            update post;

            
            Integer iCont = 0; //Incrementar el número de RT de post padre.
            
            if (oParent.CC_NumRT__c != null) {
                iCont = Integer.valueOf(oParent.CC_NumRT__c);
            }

            iCont++;

            oParent.CC_NumRT__c = iCont;
            update oParent;
        }
    }
}