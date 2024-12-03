global class CC_ST_ReviewsCaseBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global CC_ST_ReviewsCaseBatch() {
    }    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,Title__c,Content__c,Review_ID__c,Rating__c,App__c,App_ID__c,Case__c,Author_Name__c,SocialPost__c,Source__c,CC_Actualizacion_Review__c,CC_Idioma__c from CC_ST_AppReviews__c where Case__c = null and procesado__c=false' +(Test.isRunningTest()?' LIMIT 200':'');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CC_ST_AppReviews__c> scope) {
        Map<String,Boolean> appCaseCreate = new Map<String,Boolean>();
        Map<String,String> appCaseStatus = new Map<String,String>();
        Map<String,String> appCaseAction = new Map<String,String>();
        
        //Buscamos los recordtype para buscar el MCC para las respuestas automaticas de Stores
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        //Recuperamos el MCC para las respuestas automaticas de las Stores
        Id Tematica = [SELECT Id FROM CC_MCC__c WHERE RecordTypeId = :recordTem AND CC_Tipo_Cliente__c = 'Cliente'
                       AND CC_Activo__c= true AND Name = :'App\'s'].Id;
        List<Id> oListProd = new List<Id>();
        Map<String,Id> oMapProd = new Map<String,Id>();
        List<CC_MCC__c> ProdServ = [SELECT Id, Name, CC_Detalle__c FROM CC_MCC__c 
                              WHERE RecordTypeId = :recordProd AND CC_Activo__c= true AND CC_Tipo_Cliente__c = 'Cliente'
                              AND Name IN ('APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank')];
        for(CC_MCC__c prod : ProdServ){
            oListProd.add(prod.Id);
            oMapProd.put(prod.CC_Detalle__c, prod.Id);
        }
        Map<Id,Id> oMapMotivo = new Map<Id,Id>();
        List<CC_MCC__c> Motivo = [SELECT Id, CC_Producto_Servicio__c FROM CC_MCC__c 
	                              WHERE RecordTypeId = :recordMot AND CC_Activo__c= true AND CC_Tipo_Cliente__c = 'Cliente'
    	                          AND CC_Producto_Servicio__c IN : oListProd];
        for(CC_MCC__c mot : Motivo){
            oMapMotivo.put(mot.CC_Producto_Servicio__c, mot.Id);
        }
        
        list<Configuraci_n_de_Acciones_de_Store__mdt> STConfig = [SELECT Crear_Caso__c, Estado_Caso__c, Post_Proceso__c ,MasterLabel,Configuraci_n_de_Store__r.Identificador__c
                                                        FROM Configuraci_n_de_Acciones_de_Store__mdt];
        
        for(Configuraci_n_de_Acciones_de_Store__mdt cfg : STConfig){
            appCaseCreate.put(cfg.MasterLabel + '-' + cfg.Configuraci_n_de_Store__r.Identificador__c, cfg.Crear_Caso__c);
            appCaseStatus.put(cfg.MasterLabel + '-' + cfg.Configuraci_n_de_Store__r.Identificador__c, cfg.Estado_Caso__c);
            appCaseAction.put(cfg.MasterLabel + '-' + cfg.Configuraci_n_de_Store__r.Identificador__c, cfg.Post_Proceso__c );
        }
        
        // Buscamos en la LOV si está el parámetro activo para que se envíen las respuestas automáticas
        // y la afectación que tiene en cuanto a la creación del caso.
        List<CC_Lista_Valores__c> oLista = [SELECT Id, Name, RecordTypeId, CC_Activa__c, CC_Agente__c, CC_Valor__c, 
                                            CC_Valor_SFDC__c, CC_Lista__r.Name 
                                            FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'DETIDI'];
        
        Map<String, CC_Lista_Valores__c> oMapLOV = new Map<String, CC_Lista_Valores__c>();
        for(CC_Lista_Valores__c lov : oLista){
            oMapLOV.put(lov.Name, lov);
        }
        
        List<Case> cList = new List<Case>();
        List<SocialPost> lstPost = new List<SocialPost>();
        List<SocialPersona> lstPersona = new List<SocialPersona>();
        List<SocialPost> lstRespuestas = new List<SocialPost>();

        Map<String,Case> cMap = new Map<String,Case>();
        Map<String,SocialPost> pMap = new Map<String,SocialPost>();
        Map<String,SocialPersona> spMap = new Map<String,SocialPersona>();
        Map<Id,SocialPersona> spCaseMap = new Map<Id,SocialPersona>();
        //Assignament rule para asignar a la cola de Stores y pasar el ID como parametro del createCase
        AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' AND Name = 'CC_Asig_Caso_Cola' limit 1];
        Id idRule;
		if (rules.size() > 0){
        	idRule = rules[0].id;
		}
        
        // Recuperamos la configuracion de todas las Stores para guardarnos en un MAP el canal operativo correspondiente a cada App.
        List<CC_Config_Stores__mdt> oListSTConfig = [SELECT MasterLabel,Imagen__c,App_Name__c,Canal_operativo__c 
                                   					 FROM CC_Config_Stores__mdt];
        Map<String,String> oMapCanalApp = new Map<String,String>();
        for(CC_Config_Stores__mdt config : oListSTConfig){
            oMapCanalApp.put(config.App_Name__c, config.Canal_operativo__c);
        }       

        //Creación de Casos
        for (CC_ST_AppReviews__c Review : scope) {
            if (appCaseCreate.get(Review.Rating__c + '-' + Review.App_ID__c)){
                String estadoActualizacion = '';
                String idioma = null;
                if(Review.CC_Actualizacion_Review__c == true){
                    estadoActualizacion = 'Activo';
                }
                //Mirar si idioma está informado para informarlo
                if (Review.CC_Idioma__c != null){
                	idioma = Review.CC_Idioma__c;
                }
                
                //Con el MCC recuperado, buscamos por App__c de la review para saber que MCC tabular
                Id tematicaMCC = Tematica;
                Id productoMCC = null;
                if (Review.App__c == 'CaixaBank para iPad'){
                    productoMCC = oMapProd.get('CaixaBank');
                } else if (Review.App__c == 'ImaginKids' || Review.App__c == 'ImaginTeens'){
                    productoMCC = oMapProd.get('ImaginBank');
                } else {
                    productoMCC = oMapProd.get(Review.App__c);
                }
                Id motivoMCC = oMapMotivo.get(productoMCC);
                
                Case c = CC_ST_ReviewsController.createCase(Review.Title__c,
                                                            Review.Content__c,
                                                            'Comentarios Stores',
                                                            Review.Id,
                                                            false,
                                                            Review.Rating__c,
                                                            Review.App_ID__c,
                                                            appCaseStatus.get(Review.Rating__c + '-' + Review.App_ID__c),
                                                            appCaseAction.get(Review.Rating__c + '-' + Review.App_ID__c),
                                                            Review.Source__c,
                                                            idRule,
                                                            estadoActualizacion,
                                                            tematicaMCC,
                                                            productoMCC,
                                                            motivoMCC, 
                                                            idioma,
                                                            oMapCanalApp.get(Review.App__c),
                                                            Review.App__c,
                                                            oMapLOV
                                                            );
                cList.add(c);
                cMap.put(Review.Review_ID__c,c);    
            }
            
        }
        //insert cList;
        if (!cList.isEmpty()){
            Database.SaveResult[] ocList = Database.insert(cList, false);
        }
        
        //Creación de Social Post
        for(CC_ST_AppReviews__c Review : scope){
            if (appCaseCreate.get(Review.Rating__c + '-' + Review.App_ID__c)){
                Case c = cMap.get(Review.Review_ID__c);
                String CaseId = '' + c.Id;
                
                SocialPost socPost = CC_ST_ReviewsController.createSocialPost(Review.Review_ID__c,
                                                                              CaseId,
                                                                              Review.Author_Name__c,
                                                                              Review.Content__c,
                                                                              Review.Title__c,
                                                                              'Comment',
                                                                              false,false);
                lstPost.add(socPost);
                pMap.put(Review.Review_ID__c,socPost);
                Review.Case__c = c.Id;
                
            }
        }
        //insert lstPost;
        if (!lstPost.isEmpty()){
            Database.SaveResult[] oReslstPost = Database.insert(lstPost, false);
        }
        
        //Creamos Social Personas
        for(CC_ST_AppReviews__c Review : scope){
            if (appCaseCreate.get(Review.Rating__c + '-' + Review.App_ID__c)){
                Case c = cMap.get(Review.Review_ID__c);
                String CaseId = '' + c.Id;
                SocialPost p = pMap.get(Review.Review_ID__c);	
                String PostId = '' + p.Id;
                SocialPersona sp = CC_ST_ReviewsController.buscarSocialPersona(Review.Author_Name__c,Review.Source__c,PostId,false);
                
                lstPersona.add(sp);
                spMap.put(p.Id,sp);
                //Guardamos para cada caso su Social Persona
                spCaseMap.put(CaseId, sp);
            }
        }
        //upsert lstPersona;
        if (!lstPersona.isEmpty()){
            Set<SocialPersona> myset = new Set<SocialPersona>();
            List<SocialPersona> resultSP = new List<SocialPersona>(); 
            myset.addAll(lstPersona);
            resultSP.addAll(myset);
            Database.UpsertResult[] olstPersona = Database.upsert(resultSP, false);
        }
        
        //Actualizar el caso informando cual es su Social Persona
        List<Case> oListCaseUpd = new List<Case>();
        for(CC_ST_AppReviews__c Review : scope){
        	SocialPersona sp = spCaseMap.get(Review.Case__c);
            Case c = new Case();
            c.Id = Id.valueOf(Review.Case__c);
            c.CC_Social_Persona__c = sp.Id;
            oListCaseUpd.add(c);
        }
        
        if (!oListCaseUpd.isEmpty()){
            Database.SaveResult[] oResultUpdateCase = Database.update(oListCaseUpd, false);
        }
        
        //Actualizar Social Post
        for(SocialPost p : lstPost){
            if(spMap.get(p.Id) != null){
            	p.PersonaId = spMap.get(p.Id).Id;
        	}
        }
        //update lstPost;
        if (!lstPost.isEmpty()){
            Database.SaveResult[] olstPost = Database.update(lstPost, false);
        }
        
        List<Case> ListCase = new List<Case>();
        //Actualización de Review y Ejecución de acciones
        for(CC_ST_AppReviews__c Review : scope){
            Review.Procesado__c=true; 
            if (appCaseCreate.get(Review.Rating__c + '-' + Review.App_ID__c)){
                SocialPost socPost = pMap.get(Review.Review_ID__c);                    
                Review.SocialPost__c = socPost.Id;
                if (appCaseAction.get(Review.Rating__c + '-' + Review.App_ID__c) !=null) {
                    SocialPost socPostResp = CC_ST_ReviewsController.Acciones(Review, appCaseAction.get(Review.Rating__c + '-' + Review.App_ID__c), oMapLOV);
                    if (socPostResp.Name != '' && socPostResp.Name != null){
                        lstRespuestas.add(socPostResp);
                    }
                    // Update Case fecha respuesta Stores
                    if (appCaseAction.get(Review.Rating__c + '-' + Review.App_ID__c) == 'Respuesta 4-5 estrellas'){
                        if (Review.CC_Actualizacion_Review__c != true){
                            //Mirar si idioma está informado
                            if (Review.CC_Idioma__c != null){
                                CC_Lista_Valores__c oLov = oMapLOV.get(Review.App__c);
                                if (oLov != null){
                            		if (oLov.CC_Activa__c == true && oLov.CC_Agente__c != true){
                                        Case caso = new Case();
                                        caso.Id = Review.case__c;
                                        caso.CC_Fecha_Respuesta_Stores__c = Datetime.valueOf(System.now());
                                        ListCase.add(caso);
                                    }
                                }
                            } 
                        }
                    }
                }
            }                
        }
        //update ListCase;
        if (!ListCase.isEmpty()){
            Database.SaveResult[] oListCase = Database.update(ListCase, false);
        }
        //insert lstRespuestas;
        if (!lstRespuestas.isEmpty()){
            Database.SaveResult[] olstRespuestas = Database.insert(lstRespuestas, false);
        }
        //update scope;
        if (!scope.isEmpty()){
            Database.SaveResult[] oScope = Database.update(scope, false);
        }
    }

    global void finish(Database.BatchableContext bc) {
        List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_ST_ReviewsAutoMessageBatch' and Activo__c=true LIMIT 1];
        if (oConf.isEmpty()){
            //Planificación desde el framework
            //CBK_BatchJob.executeBatch('CC_ST_ReviewsAutoMessageBatch',(Test.isRunningTest()?1:1),1);
        } else {
        	CC_ST_ReviewsAutoMessageBatch batch = new CC_ST_ReviewsAutoMessageBatch();
        	Database.executeBatch(batch,(Test.isRunningTest()?1:1));
        }    

        
        //Database.executeBatch(batch,1);
        /**
        String scheduleName = 'Carga Comentarios APPs ';
        if(!Test.isRunningTest())
        {
            CC_ST_ReviewsBatch_Schedule newJob = new CC_ST_ReviewsBatch_Schedule();
            String dt = DateTime.now().addMinutes(5).format('s m H d M ? y');
            String CRON_EXP = string.valueOf(dt);
            System.schedule(scheduleName + dt, CRON_EXP, newJob);        
        }*/

    }
}