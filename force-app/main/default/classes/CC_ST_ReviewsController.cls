public class CC_ST_ReviewsController {
    @AuraEnabled(cacheable=true) 
    public static List<CC_ST_AppReviews__c> getReviews(String appId){
        List<CC_ST_AppReviews__c> appList = [Select Name,Author_Name__c,Title__c,Content__c,Rating__c,Version__c,Image_Id__c,Page__c,App_Image__c,App__c,Source__c,App_ID__c,Review_ID__c,Case__c,
												  		 Case__r.CaseNumber,Case__r.Status,Fecha__c
                                            from CC_ST_AppReviews__c 
                                            order by Fecha__c desc, Review_ID__c desc limit 1000 ];
        
        if(appList.size()>0)
            return appList;
        else
            return null;
    }
       
    @AuraEnabled
    public static Case createCase(String Title,String Content,String Origin,String ReviewId,boolean salvar,string Valoracion,String Store,
                                  String Estado_Caso,String Accion, String Procedencia, Id idRule, String estadoActualizacion, Id tematicaMCC, 
                                  Id productoMCC, Id motivoMCC, String idioma, String CanalOper, String AppName, Map<String, CC_Lista_Valores__c> oMapLOV){
        
		String TipoCont = '';
		Boolean CierreAuto = false;
		Boolean ControlApp = false;
		Id Tematica = null;
		Id ProdServ = null;
		Id Motivo = null;
		
		//Recuperamos a partir del nombre de la App el detalle de los parámetros para activar/desactivar las respuestas automaticas
		//y las consecuencias en la creación del caso
		CC_Lista_Valores__c oLov = oMapLOV.get(AppName);

        if (Estado_Caso==''){
            Configuraci_n_de_Acciones_de_Store__mdt STConfig = [SELECT Crear_Caso__c, Estado_Caso__c, Post_Proceso__c ,MasterLabel,Configuraci_n_de_Store__r.Identificador__c
                                                        		FROM Configuraci_n_de_Acciones_de_Store__mdt
                                                                WHERE Configuraci_n_de_Store__r.Identificador__c  =:Store 
                                                                AND MasterLabel = :Valoracion LIMIT 1];
            Estado_Caso = STConfig.Estado_Caso__c;
            Accion = STConfig.Post_Proceso__c ;
        }
		//Si parametro activo, estado del caso 'Cerrado' y campo control = true para no contar en SLA.
     	//Controlamos si se trata de una actualizacion de un comentario o sin idioma para dejar en estado Activo
		if(estadoActualizacion == 'Activo'){
            Estado_Caso = 'Activo';
            TipoCont = 'Consulta';
            CierreAuto = false;
        }
		//Si valoración positiva informamos tipo contacto
		if (Valoracion == '4' || Valoracion == '5'){
			TipoCont = 'Felicitación';   
        } else {
        	TipoCont = 'Consulta';
        }
		//Si viene sin idioma controlamos el estado
		//Si idioma null y valoracion 4 y 5 estrellas => estado = 'Rechazado', cierreAuto = true, ControlApp = true
		if (String.isBlank(idioma) && (Valoracion == '4' || Valoracion == '5')){
            Estado_Caso = 'Rechazado';
			TipoCont = 'Felicitación';
            CierreAuto = true;
            ControlApp = true;
            Tematica = tematicaMCC;
            ProdServ = productoMCC;
            Motivo = motivoMCC;
        } else if (String.isBlank(idioma) && (Valoracion != '4' && Valoracion != '5')){
            Estado_Caso = 'Activo';
            CierreAuto = false;
        }
        // Para respuestas automáticas marcamos el caso como cierre automático y el tipo contacto Felicitación
		if (Estado_Caso == 'Cerrado'){
			TipoCont = 'Felicitación';
            CierreAuto = true;
            Tematica = tematicaMCC;
            ProdServ = productoMCC;
            Motivo = motivoMCC;
        }
		
		//Al desactivar el parametro, por aplicación, aquellos de 4 y 5 estrellas se deben cerrar y marcar para que no cuente el SLA
		//siempre que no tengan marcado el flag de agente y siempre que no se trate de una actualización
        if (oLov != null){
			if (oLov.CC_Activa__c != true && oLov.CC_Agente__c != true && estadoActualizacion != 'Activo'){
				if (Accion == 'Respuesta 4-5 estrellas' && (Procedencia == 'Google Play Store' || Procedencia == 'Huawei App Store')){
					Estado_Caso = 'Cerrado';
                    TipoCont = 'Felicitación';
					ControlApp = true;
                    CierreAuto = true;
				}
			}
			// Si tiene marcado el flag de agente se debe crear el caso Activo y sea visible en la Cola de Comentarios Apps
			// contabilizando el SLA y siempre que no se trate de una actualización
			if (oLov.CC_Activa__c != true && oLov.CC_Agente__c == true && estadoActualizacion != 'Activo'){
				if (Accion == 'Respuesta 4-5 estrellas' && (Procedencia == 'Google Play Store' || Procedencia == 'Huawei App Store')){
					Estado_Caso = 'Activo';
                    TipoCont = 'Felicitación';
                    CierreAuto = false;
				}
			}
		}
		//Id ReviewId = Id.valueOf(Review);
        Case c = new Case();
		if (idRule != null){
         	Database.DMLOptions dmlOpts = new Database.DMLOptions();
        	dmlOpts.assignmentRuleHeader.assignmentRuleId= idRule;
			c.setOptions(dmlOpts);   
        }
        c.Subject = Title;
        c.Description = Content;
        c.Status = Estado_Caso;
        c.Origin = Origin;
        c.CC_Idioma__c = idioma;
        c.CC_Tipo_Contacto__c = TipoCont;
		c.CC_Tipo_Cliente__c = 'Cliente';
        c.App_Reviews__c = ReviewId;
        c.CC_Canal_Procedencia__c = Procedencia;
		c.CC_Canal_Operativo__c = CanalOper;
		c.CC_Cierre_Automatico__c = CierreAuto;
		//Se incluye tematica, producto, motivo para casos de cierre automático de Google, para el resto será null
		c.CC_MCC_Tematica__c = Tematica;
		c.CC_MCC_ProdServ__c = ProdServ;
		c.CC_MCC_Motivo__c = Motivo;
		//TODO: Añadir Causa y Solución ¿?
		c.CC_Control_ComApps__c = ControlApp;
		if (Estado_Caso == 'Rechazado'){
			c.CC_Fecha_Respuesta_Stores__c = Datetime.valueOf(System.now()); 
        }
        if (salvar) 
            insert c;
        return c;
    }
    
    @AuraEnabled
    public static SocialPersona buscarSocialPersona(String nombre,String Red,String Padre,boolean salvar){
        
        String socialName;

        if(nombre != null){
            socialName = nombre + ' (' + Red + ')';   
        }else{
            socialName = ' (' + Red + ')';
        }
        List<SocialPersona> lstpersona = [Select Id,Name from SocialPersona where Provider ='Other' and Name = :SocialName ];
        SocialPersona persona = New SocialPersona();
        if (lstpersona.size()==0) {
            persona.parentId = Id.valueOf(Padre);
            persona.Name = socialName;
            persona.RealName = nombre;
            persona.Provider='Other';
            if (salvar) 
                insert persona;
        } else {
            persona = lstpersona[0];
        }
        return persona;
    }

    @AuraEnabled
    public static SocialPost createSocialPost(String Review_ID,String CaseId,String Author_Name,String Content,String Title,String MessageType,boolean IsOutbound,boolean salvar){
        SocialPost socPost = New SocialPost();
        socPost.Content = Content;
        socPost.Handle = Author_Name;
        socPost.ParentId = Id.valueOf(CaseId);
        socPost.Provider = 'Other';
        socPost.MessageType = MessageType;
        socPost.Name = Title;
        socPost.IsOutbound = IsOutbound;

        if (salvar) 
            insert socPost;
        return socPost;
    }
    
    @AuraEnabled
    public static CC_ST_AppReviews__c refrechItem(Id ReviewId){
        CC_ST_AppReviews__c item = [Select Name,Author_Name__c,Title__c,Content__c,Rating__c,Version__c,Image_Id__c,Page__c,App_Image__c,
                                    App__c,Source__c,App_ID__c,Review_ID__c,Case__c,Case__r.CaseNumber,Case__r.Status,Fecha__c
                                   	FROM CC_ST_AppReviews__c WHERE  Id = :ReviewId limit 1 ];
     
        return item;        
    }
    
   @AuraEnabled
    public static CC_ST_AppReviews__c getItem(Id CaseId){
        CC_ST_AppReviews__c item = [SELECT Id,Name,Author_Name__c,Title__c,Content__c,Rating__c,Version__c,Image_Id__c,Page__c,App_Image__c,
                                    App__c,Source__c,App_ID__c,Review_ID__c,Case__c,Case__r.CaseNumber,Case__r.Status,Fecha__c,Case__r.Origin,
                                    Case__r.CC_Idioma__c
                                    FROM CC_ST_AppReviews__c WHERE  Case__c = :CaseId limit 1 ];
     
        return item;        
    }
    /*
    public class WrapperObject{
        @AuraEnabled
        public String ReviewId{get;set;}
        @AuraEnabled
        public String AuthorName{get;set;}
        @AuraEnabled
        public String Title{get;set;}
        @AuraEnabled
        public String Rating{get;set;}
        @AuraEnabled
        public String Content{get;set;}
        @AuraEnabled
        public String Version{get;set;}
        
        public WrapperObject(String ReviewId, String AuthorName, String Title, String Rating, String Content,String Version){
            this.ReviewId = ReviewId;
            this.AuthorName = AuthorName;
            this.Title = Title;
            this.Rating = Rating;
            this.Content = Content;
            this.Version = Version;
        }
    }
        */
    public static void creacionMasivaCasos(List<CC_ST_AppReviews__c> reverseAppList,String appId) {    
        Set<String> revIdSet = new Set<String>();
        //Buscamos los recordtype para buscar el MCC para las respuestas automaticas de Stores
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        //Recuperamos el MCC para las respuestas automaticas de las Stores
    
        Id Tematica = [SELECT Id FROM CC_MCC__c WHERE RecordTypeId = :recordTem AND CC_Activo__c= true AND CC_Tipo_Cliente__c = 'Cliente' AND Name = :'App\'s'].Id;
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

        // Recuperamos la configuracion de todas las Stores para guardarnos en un MAP el canal operativo correspondiente a cada App.
        List<CC_Config_Stores__mdt> oListSTConfig = [SELECT MasterLabel,Imagen__c,App_Name__c,Canal_operativo__c 
                                   					 FROM CC_Config_Stores__mdt];
        Map<String,String> oMapCanalApp = new Map<String,String>();
        for(CC_Config_Stores__mdt config : oListSTConfig){
            oMapCanalApp.put(config.App_Name__c, config.Canal_operativo__c);
        }
        
        list<Configuraci_n_de_Acciones_de_Store__mdt> STConfig = [SELECT Crear_Caso__c, Estado_Caso__c, Post_Proceso__c ,MasterLabel
                                                        			FROM Configuraci_n_de_Acciones_de_Store__mdt
                                                      			   WHERE Configuraci_n_de_Store__r.Identificador__c  =:appId];
        
        Map<String,Boolean> appCaseCreate = new Map<String,Boolean>(); 
        Map<String,String> appCaseStatus = new Map<String,String>();
        Map<String,String> appCaseAction = new Map<String,String>();
        
        for(Configuraci_n_de_Acciones_de_Store__mdt cfg : STConfig){
            System.debug('Pablo: master label - ' +cfg.MasterLabel+' - Estado caso '+cfg.Estado_Caso__c);
            appCaseCreate.put(cfg.MasterLabel, cfg.Crear_Caso__c);
            appCaseStatus.put(cfg.MasterLabel, cfg.Estado_Caso__c);
            appCaseAction.put(cfg.MasterLabel, cfg.Post_Proceso__c );
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
        List<SocialPost> cPost =new List<SocialPost>();
        Map<String,Case> cMap = new Map<String,Case>();
        //Assignament rule para asignar a la cola de Stores y pasar el ID como parametro del createCase
        AssignmentRule[] rules = [select id from AssignmentRule where SobjectType = 'Case' AND Name = 'CC_Asig_Caso_Cola' limit 1];
        Id idRule;
		if (rules.size() > 0){
        	idRule = rules[0].id;
		} 
            for(integer i=0;i<reverseAppList.size();i++){
                if(appCaseCreate.get(reverseAppList[i].Rating__c)){
                //if(revIdSet.contains(reverseAppList[i].Review_ID__c))
                    revIdSet.add(reverseAppList[i].Review_ID__c);
                    String estadoActualizacion = '';
                    if (reverseAppList[i].CC_Actualizacion_Review__c == true){
                        estadoActualizacion = 'Activo';
                    }
                    //Con el MCC recuperado, buscar por App__c de la review para saber que MCC tabular
                    Id tematicaMCC = Tematica;
                    Id productoMCC = null;
                    
                    if (reverseAppList[i].App__c == 'CaixaBank para iPad'){
                        productoMCC = oMapProd.get('CaixaBank');
                    } else if (reverseAppList[i].App__c == 'ImaginKids' || reverseAppList[i].App__c == 'ImaginTeens'){
                 	   productoMCC = oMapProd.get('ImaginBank');
                	} else {
                        productoMCC = oMapProd.get(reverseAppList[i].App__c);
                    }
                    Id motivoMCC = oMapMotivo.get(productoMCC);
                    Case c = CC_ST_ReviewsController.createCase(reverseAppList[i].Title__c,
                                                                reverseAppList[i].Content__c,
                                                                'Comentarios Stores',
                                                                reverseAppList[i].Id,
                                                                false,
                                                                reverseAppList[i].Rating__c,
                                                                reverseAppList[i].App_ID__c,
                                                                appCaseStatus.get(reverseAppList[i].Rating__c),
                                                                appCaseAction.get(reverseAppList[i].Rating__c),
                                                                reverseAppList[i].Source__c,
                                                                idRule,
                                                                estadoActualizacion,
                                                                tematicaMCC,
                                                                productoMCC,
                                                                motivoMCC, 
                                                                reverseAppList[i].Case__r.CC_Idioma__c,
                                                                oMapCanalApp.get(reverseAppList[i].App__c),
                                                                reverseAppList[i].App__c,
                                                                oMapLOV
                                                               );

                    cList.add(c);
                    cMap.put(reverseAppList[i].Review_ID__c,c);
                }
            }
            //insert cList;
  
        	if (!cList.isEmpty()){
                Database.SaveResult[] oResReclamacion = Database.insert(cList, false);
            }

            for(integer i=0;i<reverseAppList.size();i++){
                if(revIdSet.contains(reverseAppList[i].Review_ID__c)){
                    Case c = cMap.get(reverseAppList[i].Review_ID__c);
                    reverseAppList[i].Case__c = c.Id;
                    String CaseId = '' + c.Id;
                    SocialPost socPost = CC_ST_ReviewsController.createSocialPost(reverseAppList[i].Review_ID__c,
                                                                                  CaseId,
                                                                                  reverseAppList[i].App__c,
                                                                                  reverseAppList[i].Content__c,
                                                                                  reverseAppList[i].Title__c,
                                                                                  'Comment',
                                                                                  false,false);
                    cPost.add(socPost);
                }
               	reverseAppList[i].Procesado__c=true; 
            }
        //update reverseAppList;
     
        if (!reverseAppList.isEmpty()){
            Database.SaveResult[] oResReclamacion = Database.update(reverseAppList, false);
        }
        //insert cPost;

        if (!cPost.isEmpty()){
            Database.SaveResult[] oResReclamacion = Database.insert(cPost, false);
        }
    }
    // TODO: Tiene que devolver un List<SocialPost>
    public static SocialPost Acciones(CC_ST_AppReviews__c Review, String accion, Map<String, CC_Lista_Valores__c> oMapLOV) {
        SocialPost socPost = New SocialPost();
        //Miramos el parámetro que activa/desactiva la respuesta automática
        CC_Lista_Valores__c oLov = oMapLOV.get(Review.App__c);
        //List<CC_Valores__mdt> controlApps = [SELECT CC_Valor__c, CC_Activa__c FROM CC_Valores__mdt WHERE DeveloperName =: 'CC_Control_ComApps__c'];
        switch on accion {
            when 'Respuesta 4-5 estrellas' {
                // Crea respuesta automatica solo Google
                if (Review.Source__c == 'Google Play Store'){
                    if(Review.CC_Actualizacion_Review__c != true){
                        //TODO: Al desactivar el parámetro, que ninguna respuesta automática, por aplicación, se envíe.
                        //No solo aquellas sin idioma, ninguna respuesta automática se debe enviar.
						if (oLov != null){
                            if (oLov.CC_Activa__c == true && oLov.CC_Agente__c != true){
							//Controlar Review.CC_Idioma__c para ver si se envía la respuesta automatica o no
							//TODO: Como aquí entran aquellos casos que pasan los filtros, hay que hacer un Listado
							//TODO: de Id's de Reviews para poder hacer el control de 50 callouts
	                    		socPost = CC_ST_PlayStoreReviewsCtrl.Respuesta_automatica(Review.App__c,Review.Review_ID__c,Review.case__c,Review.SocialPost__c,Review.Author_Name__c,Review.App_Id__c,Review.CC_Idioma__c);                            
                            }
                        }
						//else¿?
                    }
                }
            }
            when else {// default block, optional
            	// code block 4
            }
        }
        //TODO: con el listado de id's recopilado hacer aquí la llamada al nuevo método que gestiona las 50 llamadas future
        //y responde automáticamente.
        return socPost;
    }
    //Recuperar mensaje automatico aleatorio para Apple Store y Google Store con 4 o 5 estrellas
    @AuraEnabled
    public static String recuperaMensajeAutomatico (String idioma, String nombre, String aplicacion){
        String mensaje = '';
        Integer randomNumber;
        List<CC_Respuestas_Stores__mdt> STRespuestas = new List<CC_Respuestas_Stores__mdt>();
        List<CC_Respuesta_CBK_Sign__mdt> STRespSign = new List<CC_Respuesta_CBK_Sign__mdt>();
        //Buscar respuestas en función de la aplicacion
        if (aplicacion == 'CaixaBank Sign' || aplicacion == 'ImaginBank' || aplicacion == 'ImaginKids' || aplicacion == 'ImaginTeens') { //CBK Sign, ImaginBank, Imagin Kids e Imagin Teens
            STRespSign = [SELECT Respuesta__c  FROM CC_Respuesta_CBK_Sign__mdt where idioma__c = :idioma ];
            if (STRespSign.size()>0){
                //Respuesta aleatoria
                randomNumber = Integer.valueof((Math.random() * (STRespSign.size()-1)));
                mensaje = STRespSign[randomNumber].Respuesta__c;
                if (nombre == null){
                    nombre = '';
                }
                mensaje = mensaje.replace('##ClientName##', nombre);
            }
        } else{ //CaixaBank, CaixaBank para iPad, CaixaBank Pay y BrokerNow
            STRespuestas = [SELECT Respuesta__c  FROM CC_Respuestas_Stores__mdt where idioma__c = :idioma ];
            if (STRespuestas.size()>0){
                //Respuesta aleatoria
                randomNumber = Integer.valueof((Math.random() * (STRespuestas.size()-1)));
                mensaje = STRespuestas[randomNumber].Respuesta__c;
                if (nombre == null){
                    nombre = '';
                }
                mensaje = mensaje.replace('##ClientName##', nombre);
            }
        }
        return mensaje;
    }
    
    @AuraEnabled
    public static void actualizaCasoFechaRespuesta (id CaseId){
        Case caso = new Case();
        caso.Id = CaseId;
        caso.CC_Fecha_Respuesta_Stores__c = Datetime.valueOf(System.now());
        //caso.Status = 'Cerrado';
        update caso;
    }
    
    // Busqueda de quickText para las Stores
    @AuraEnabled
    public static List<QuickText> buscarTabuladaStores (id CaseId){
        String channel = '';
        //String app = '';
        Case caso = [SELECT App_Reviews__r.App__c, CC_Idioma__c, Origin FROM Case WHERE Id = :CaseId LIMIT 1];
        if (caso.Origin == 'Comentarios Stores'){
            channel = 'Stores';
        }
        //Controlar todas las APP para poner su equivalente
        /*if (caso.App_Reviews__r.App__c == 'Caixabank' || caso.App_Reviews__r.App__c == 'CaixaBank'){
            app = 'CaixaBank';
        } else if (caso.App_Reviews__r.App__c == 'BrokerNow - Bolsa y Finanzas' || caso.App_Reviews__r.App__c == 'BrokerNow'){
            app = 'BrokerNow';
        } else if (caso.App_Reviews__r.App__c == 'CaixaBank Pay - Pago móvil' || caso.App_Reviews__r.App__c == 'Caixabank Pay'){
            app = 'Caixabank Pay';
        } else if (caso.App_Reviews__r.App__c == 'CaixaBank Sign' || caso.App_Reviews__r.App__c == 'Caixabank Sign'){
            app = 'CaixaBank Sign';
        } else if (caso.App_Reviews__r.App__c == 'imaginBank - Your mobile bank' || caso.App_Reviews__r.App__c == 'ImaginBank'){
            app = 'ImaginBank';
        }*/
        //Busqueda de las tabuladas en funcion de la APP, el Idioma y el Canal. También comprueba que las fechas sean correctas
        List<QuickText> tabuladas = [SELECT Name, Message FROM QuickText WHERE Channel = : channel 
                                     AND Category = : caso.App_Reviews__r.App__c AND CC_Idioma__c = : caso.CC_Idioma__c 
                                     AND CC_Inicio_Vigencia__c <> null and CC_Inicio_Vigencia__c <= TODAY and (CC_Fin_Vigencia__c = null or CC_Fin_Vigencia__c >= TODAY )
                                      order by Name asc];
        
        return tabuladas;
    }
    
    //Actualizamos la entidad APP Review para informar que respuesta se le ha dado al cliente al comentario de la Store
    @AuraEnabled
    public static void actualizaComentarioAppReview (id AppReviewId, String comRespuesta){
        CC_ST_AppReviews__c appReview = new CC_ST_AppReviews__c();
        appReview.Id = AppReviewId;
        appReview.Developer_Comment__c = comRespuesta;
        update appReview;
    }
    
    //Función para contestar con la API de Gooogle y dar respuesta al cliente
    @AuraEnabled
    public static void replyAppGoogleReview (String packageName, String reviewId, String reviewSource, String replyText){
        //Mirar custom metadata para ver si se puede realizar la llamada o no
        List<CC_Valores__mdt> permisoReply = [SELECT CC_Valor__c, CC_Activa__c FROM CC_Valores__mdt WHERE DeveloperName =: 'CC_replyStore'];
        if (permisoReply.size()>0){
        	if (permisoReply[0].CC_Activa__c == true && permisoReply[0].CC_Valor__c != 'N'){
                if(reviewSource == 'Google Play Store'){
                    CC_ST_PlayStoreReviewsCtrl.replyReview(packageName, reviewId, replyText);
                }else{
                    CC_ST_AppGalleryReview.replyReview(packageName, reviewId, replyText);
                }
            	
            }
        }
    }

}