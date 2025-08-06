/**
 * @description Controler para LWC de Control de IOP
 */
public without sharing class CBK_Control_Metadata {
    /** @description metadataitem */
    public class metadataitem{
            @AuraEnabled
            /** @description Tipo */
            public String Tipo{get;set;}
            @AuraEnabled
            /** @description Objeto */
            public String Objeto{get;set;}
            @AuraEnabled
            /** @description USs */
            public integer USs{get;set;}
            @AuraEnabled
            /** @description Proyectos */
            public integer Proyectos{get;set;}
            @AuraEnabled
            /** @description UserStorys */
            public list<UserStoryitem> UserStorys{get;set;}         
     }
    
    /** @description UserStoryitem */
    public class UserStoryitem{
            @AuraEnabled
            /** @description UserStory */
            public String UserStory{get;set;}
            @AuraEnabled
            /** @description Proyectos */
            public String Proyecto{get;set;}
            @AuraEnabled
            /** @description Entorno */
            public String Entorno{get;set;}        
            @AuraEnabled
            /** @description LastCommitDate */
            public DateTime LastCommitDate{get;set;}
            @AuraEnabled
            /** @description LastPromotionDate */
            public DateTime LastPromotionDate{get;set;}  
        	@AuraEnabled
            /** @description IOP */
            public String IOP{get;set;}    
    }
    
    @AuraEnabled(cacheable=true)
    /**
     * @description getEntornos
     * @return mapEnt
     */
    public static map<string,object> getEntornos() {    
        map<string,object> mapEnt = new map<string,object>();
        list<map<string,string>> lstEnt = new list<map<string,string>>();
        
        for (copado__Environment__c ent : [select Name
									  from copado__Environment__c order by name ]){
            map<string,string> m = new map<string,string>();
            m.put('label', ent.Name);
            m.put('value', ent.Name); 
            lstEnt.add(m); 
        }
        mapEnt.put('controllerValues',new list<string>());
        mapEnt.put('defaultValue',null);
        mapEnt.put('values',lstEnt);
        return mapEnt;
    }
    
    @AuraEnabled(cacheable=true)
    /**
     * @description getIOPs
     * @return mapIOP
     */
    public static map<string,object> getIOPs(string Entorno) {    
        map<string,object> mapIOP = new map<string,object>();
        
        list<map<string,string>> lstIOP = new list<map<string,string>>();
        
        for (AggregateResult iop : [select copado__User_Story__r.copado__Release__r.Name 
                                         from copado__Promoted_User_Story__c 
                                        where copado__Promotion__r.copado__Status__c='Completed'
                                          and copado__User_Story__r.copado__Release__r.Name!=''
                                    	  and copado__User_Story__r.copado__Is_Bundle__c =false
                                          and copado__Promotion__r.copado__Destination_Environment__r.name=:Entorno
                                        GROUP BY copado__User_Story__r.copado__Release__r.Name
                                        order by max(LastModifiedDate) desc]){
            map<string,string> m = new map<string,string>();
            m.put('label', (string)iop.get('Name'));
            m.put('value', (string)iop.get('Name')); 
            lstIOP.add(m); 
        }
        mapIOP.put('controllerValues',new list<string>());
        mapIOP.put('defaultValue',null);
        mapIOP.put('values',lstIOP);
        return mapIOP;
    }


	@AuraEnabled(cacheable=true)
    /**
     * @description getobjetosIOP
     * @return objetosIOP
     */
    public static list<metadataitem> getobjetosIOP(string IOP,string Entorno,string Tipo) {    
        map<String,integer>mapObjetos = new map<String,integer>();
        map<String,integer>mapObjetosProyecto = new map<String,integer>();
        map<String,integer>mapObjetosIOP = new map<String,integer>();
        
        integer numUs;
        integer numProy;
        integer numIOP;
        
       switch on Tipo {
           when 'IOP' {	
                numUs=1;
                numProy=1;
               	numIOP=1;
           }	
           when 'Proyecto' {	
                numUs=1;
                numProy=1;
               	numIOP=0;
           }	
            when 'US' {		
                numUs=1;
                numProy=0;
               	numIOP=0;
                
            }
            when else {		  // default block, optional
                numUs =99999;
                numProy =99999;
            }
        }
            
        //list<string> lstIOP = new list<string>();
        //lstIOP.add(IOP);
        system.debug(IOP);
        system.debug(Entorno);
        system.debug(Tipo);
        system.debug(numUs);
        system.debug(numProy);
        
		List<String> lstIOPName = IOP.replace('[','').replace(']','').replace('"','').split(',');
        system.debug(lstIOPName);
        list<copado__Release__c> lstIOP = [Select Id from copado__Release__c where Name in : lstIOPName];
        


        
        //lstIOP=testIOP();
        
        //Listado de objetos
        for(AggregateResult US : [select copado__Metadata_API_Name__c,count(Id),COUNT_DISTINCT(copado__User_Story__r.copado__Project__c),COUNT_DISTINCT(copado__User_Story__r.copado__Release__c)
                                    from copado__User_Story_Metadata__c 
                                    where copado__User_Story__c in (
                                       select copado__User_Story__c
                                         from copado__Promoted_User_Story__c 
                                        where copado__Promotion__r.copado__Status__c='Completed'
                                          and copado__Promotion__r.copado__Destination_Environment__r.name=:Entorno)
                                    and copado__User_Story__r.copado__Release__c in :lstIOP
                                    and copado__User_Story__r.copado__Is_Bundle__c =false
                                    group by copado__Metadata_API_Name__c
                                    LIMIT 9000])
        {                            
            mapObjetos.put((string)US.get('copado__Metadata_API_Name__c'),(integer)US.get('expr0'));
            mapObjetosProyecto.put((string)US.get('copado__Metadata_API_Name__c'),(integer)US.get('expr1'));
            mapObjetosIOP.put((string)US.get('copado__Metadata_API_Name__c'),(integer)US.get('expr2'));
        }

		//User Story        
        list<String> lstUSs = new list<String>();

        for (String key : mapObjetos.keySet()) {
            if ((mapObjetos.get(key)>numUs) && (mapObjetosProyecto.get(key)>numProy) && (mapObjetosIOP.get(key)>numIOP)){
                lstUSs.add(key);
            }
        }
        
        list<copado__User_Story_Metadata__c> meta = [select copado__Metadata_API_Name__c,
                                                         copado__User_Story__c,copado__User_Story__r.name,
                                                         copado__User_Story__r.copado__Project__r.name,
                                                         copado__Last_Commit_Date__c,
                                                         copado__User_Story__r.copado__Last_Promotion_Date__c,
                                                   		 copado__User_Story__r.copado__Environment__r.name,
                                                   		 copado__User_Story__r.copado__Release__r.name
                                                           from copado__User_Story_Metadata__c 
                                                          where copado__User_Story__c in (
                                                              select copado__User_Story__c
                                                                from copado__Promoted_User_Story__c 
                                                               where copado__Promotion__r.copado__Status__c='Completed'
                                                                 and copado__Promotion__r.copado__Destination_Environment__r.name=:Entorno)
                                                                 and copado__User_Story__r.copado__Release__c in :lstIOP
                                                   				 and copado__Metadata_API_Name__c in :lstUSs
                                                         order by copado__Metadata_API_Name__c,copado__User_Story__r.copado__Last_Promotion_Date__c desc];
        
        return objetosIOP(meta,mapObjetos,mapObjetosProyecto);
        
    }

     /**
     * @description objetosIOP
     * @return listCambios
     */     
	public static list<metadataitem> objetosIOP(list<copado__User_Story_Metadata__c> lstMeta,map<String,integer> mapObjetos,map<String,integer> mapObjetosProyecto) {    
        string currentMetadata='INICIO';
        metadataitem item = new metadataitem(); 
        list<UserStoryitem> UserStorylst = new list<UserStoryitem>();
        UserStoryitem US = new UserStoryitem();
        list<metadataitem> listCambios = new list<metadataitem>();
        
        for(copado__User_Story_Metadata__c meta : lstMeta)           									
        {
            if (meta.copado__Metadata_API_Name__c!=currentMetadata){
                UserStorylst = new list<UserStoryitem>();
                if (currentMetadata!='INICIO'){
                    listCambios.add(item);
                }
                item = new metadataitem();  
                item.Tipo='Pendiente';
                item.Objeto=meta.copado__Metadata_API_Name__c;
                item.USs=mapObjetos.get(meta.copado__Metadata_API_Name__c);
                item.Proyectos=mapObjetosProyecto.get(meta.copado__Metadata_API_Name__c);
                currentMetadata = meta.copado__Metadata_API_Name__c;
            } 
            
            US = new UserStoryitem();
            US.UserStory = meta.copado__User_Story__r.name;
            US.Proyecto = meta.copado__User_Story__r.copado__Project__r.name;
            US.Entorno = meta.copado__User_Story__r.copado__Environment__r.name;
            US.LastCommitDate = meta.copado__Last_Commit_Date__c;
            US.LastPromotionDate = meta.copado__User_Story__r.copado__Last_Promotion_Date__c;
            US.IOP=meta.copado__User_Story__r.copado__Release__r.Name;
            UserStorylst.add(US);
            item.UserStorys = UserStorylst;
        }
        
        listCambios.add(item);
        return listCambios;
        
    }

    @future
    public static void controlObjetos(List<string> scope, Id entorno) {
        Map<string,list<string>> mapConfig = new Map<string,list<string>>();
        list<string> lstConfig = new list<string>();
        for (CBK_Metadata_IOP__mdt meta : [select MasterLabel,Email__c from CBK_Metadata_IOP__mdt]){
            if (mapConfig.containsKey(meta.MasterLabel)) {
                lstConfig = mapConfig.get(meta.MasterLabel);
            } else {
                lstConfig = new list<string>();
            }
            lstConfig.add(meta.Email__c);
            mapConfig.put(meta.MasterLabel,lstConfig);
        }
        
        //Buscamos los objetos en todas las US no canceladas y no subidas a Producción
        Map<string,list<copado__User_Story_Metadata__c>> mapMeta = new Map<string,list<copado__User_Story_Metadata__c>>();
        list<copado__User_Story_Metadata__c> lstMeta = new list<copado__User_Story_Metadata__c>();
            
        for (copado__User_Story_Metadata__c meta : [select copado__Metadata_API_Name__c,
                                                    	   copado__User_Story__r.name,
                                                    	   copado__User_Story__r.copado__Project__r.name,
                                                           copado__User_Story__r.copado__Release__r.name,
                                                    	   copado__Last_Commit_Date__c,
                                                    	   copado__User_Story__r.copado__Environment__r.name
                                                      from copado__User_Story_Metadata__c 
                                                     where copado__User_Story__c    in (select copado__User_Story__c
                                                                                          from copado__Promoted_User_Story__c 
                                                                                          where copado__Promotion__r.copado__Status__c='Completed'
                                                                                            and copado__Promotion__r.copado__Destination_Environment__c = :entorno) 
                                                      and copado__User_Story__c not in (select copado__User_Story__c
                                                                                          from copado__Promoted_User_Story__c 
                                                                                         where copado__Promotion__r.copado__Status__c='Completed'
                                                                                           and copado__Promotion__r.copado__Destination_Environment__r.name = 'Producción')
                                                     and copado__Metadata_API_Name__c in :scope
                                                     and copado__User_Story__r.copado__Status__c not in ('Cancelled','Rejected')
                                                    LIMIT 2000]){
            if (mapMeta.containsKey(meta.copado__Metadata_API_Name__c)) {
                lstMeta = mapMeta.get(meta.copado__Metadata_API_Name__c);
            } else {
                lstMeta = new list<copado__User_Story_Metadata__c>();
            }
            lstMeta.add(meta);
            mapMeta.put(meta.copado__Metadata_API_Name__c,lstMeta);                                                            
        }
        
		system.debug(mapMeta);
		system.debug(entorno);        
        
        
        
        for (String item: scope){          
			if (mapMeta.containsKey(item)) {
                lstMeta = mapMeta.get(item);
                if ((lstMeta.size()>1) || (mapConfig.containsKey(item))){      
                    //Si es de más de una US, notificamos a todos los afectados de la misma IOP/Objeto --> Se ha detectado colisión con el Objeto XXX en la IOP
                    envioEmailColision(lstMeta,entorno,mapConfig);
                }
            }            
        }
    }
    
    public static boolean envioEmailColision(list<copado__User_Story_Metadata__c> lstMeta,string entorno,Map<string,list<string>> mapConfig) { 
        list<string> lstProjects = new list<string>();
        list<string> toAddresses = new list<string>();
        String strHtmlBody = '<html>';
        
        
        strHtmlBody += '<head>';
        strHtmlBody += '<style>';
        strHtmlBody += 'table {';
        strHtmlBody += '  font-family: arial, sans-serif;';
        strHtmlBody += '  border-collapse: collapse;';
        strHtmlBody += '  width: 100%;';
        strHtmlBody += '}';

        strHtmlBody += 'td, th {';
        strHtmlBody += '  border: 1px solid #ADD8E6;';
        strHtmlBody += '  text-align: left;';
        strHtmlBody += '  padding: 8px;';
        strHtmlBody += '}';

        strHtmlBody += 'tr:nth-child(odd) {';
        strHtmlBody += '  background-color: #ADD8E6;';
        strHtmlBody += '}';
        strHtmlBody += '</style>';
        strHtmlBody += '</head>';
        strHtmlBody += '<body>';
        
        strHtmlBody += '<h2>Alerta de promoción de Código.</h2>';
                
        strHtmlBody += '<p style="font-family: arial, sans-serif;"><b>Objeto: </b>' + lstMeta[0].copado__Metadata_API_Name__c + '.</p>';
        strHtmlBody += '<p style="font-family: arial, sans-serif;"><b>Entorno: </b>' + entorno + '.</p>';
        strHtmlBody += '<br><table border="1" style="border-collapse: collapse"><caption></caption><tr><th>Objeto</th><th>User Story</th><th>Proyecto</th><th>Release</th><th>Fecha Último Commit</th><th>Ubicación Actual</th></tr>';
        
        //Envíos de emails a proyectos afectados
        for (copado__User_Story_Metadata__c objeto : lstMeta){
            strHtmlBody += '<tr><td>' + lstMeta[0].copado__Metadata_API_Name__c + 
                '</td><td>' + objeto.copado__User_Story__r.name + 
                '</td><td>' + objeto.copado__User_Story__r.copado__Project__r.name + 
                '</td><td>' + objeto.copado__User_Story__r.copado__Release__r.name + 
                '</td><td>' + objeto.copado__Last_Commit_Date__c +
                '</td><td>' + objeto.copado__User_Story__r.copado__Environment__r.name + '</td></tr>';   
            lstProjects.add(objeto.copado__User_Story__r.copado__Project__r.name);
        }
        
        strHtmlBody += '</table><br></body>';
        
        //Eliminación de proyectos duplicados    
        Set<string> myset = new Set<string>();
		List<string> lstProjects2 = new List<string>();
		myset.addAll(lstProjects);
		lstProjects2.addAll(myset);
        
        if (lstProjects2.size()>1){
            strHtmlBody += '<br><h3 style=""color:#FF0000"">El objeto ha sido modificado en varias User Storys de distintos proyectos que no han sido desplegadas aún a Producción.</h3>';
        } else if (lstProjects.size()>1){ 
            strHtmlBody += '<br><h3 style=""color:#FF0000"";>El objeto ha sido modificado en varias User Storys que no han sido desplegadas aún a Producción.</h3>';            
        }
        
        strHtmlBody += '</html>';

        
        //Obtención de listado de Emails
        for(string pj : lstProjects2 ){
            if (mapConfig.containsKey(pj)){
                toAddresses.addall(mapConfig.get(pj));   
            }
        }
        
        if (mapConfig.containsKey(lstMeta[0].copado__Metadata_API_Name__c)){
            if (mapConfig.containsKey(lstMeta[0].copado__Metadata_API_Name__c)){
                toAddresses.addall(mapConfig.get(lstMeta[0].copado__Metadata_API_Name__c));
            }
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);        
        if (mapConfig.containsKey('Remitente')){
            List<OrgWideEmailAddress> owea = [SELECT Id,DisplayName FROM OrgWideEmailAddress WHERE Address = :mapConfig.get('Remitente')[0]];
            if (!owea.isEmpty()) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
            
        } else{
            mail.setTargetObjectId(UserInfo.getUserId());
        }
        mail.setSubject('Alerta de promoción de Código (' + entorno + ')- ' + lstMeta[0].copado__Metadata_API_Name__c);
        mail.setHtmlBody(strHtmlBody);
        mail.setSaveAsActivity(false);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(exception e){
            system.debug(e);
        }
        return true;
    }    
}