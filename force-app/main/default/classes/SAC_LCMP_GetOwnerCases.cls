public without sharing class SAC_LCMP_GetOwnerCases {
/*****************************************************************
 * Name: SAC_LCMP_GetOwnerCases
 * Copyright © 2021  CaixaBank
 *                                                                                        
 * Proposito: Controlador  para poder visualizar y asociar Reclamaciones de un mismo propietario siempre y cuando
 *   sus pretensiones sean las mismas o tengan relación entre Reclamaciones ya existentes.
 *   LWC asociado: sAC_AsociarReclamaciones
 *                                                                                        
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa     16/04/21      Creación Clase
 * 1.1            US233794         Luis Mesa     14/06/21      Adición reclamantes adicionales
*****************************************************************/

private static final String MSG_ERROR_PERMISSIONS = 'No tienes permisos para realizar la acción.';
private static final String MSG_ERROR_RECORDS = 'No existe un cliente asociado a la reclamación.';
private static final Id RECORTYPECONSULTA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();   
private static final Id RECORTYPECONSULTASAC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();   
   
    @AuraEnabled(cacheable = true)
    public static List<ReclamacionWrapper> getSameOwnerCases(String idCasoDisparador){
/*****************************************************************
 * Proposito: Método para obtener la lista de reclamaciones asignadas al mismo propietario de la reclamación que se esta visualizando
 *                                                                                        
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
*****************************************************************/
        if(!Case.SObjectType.getDescribe().isAccessible()){
            throw new AuraHandledException(MSG_ERROR_PERMISSIONS);        }

        //Caso para poder obtener casos relacionados a este
        Case casoAuxiliar = [Select Id, recordTypeId, CaseNumber, CC_CasoRelacionado__c, AccountId From Case Where Id =: idcasoDisparador];
        List<Case> reclamaciones = new List<Case>();

        if(casoAuxiliar.AccountId == null){
            throw new AuraHandledException(MSG_ERROR_RECORDS);        }

        if(casoAuxiliar.recordTypeId == RECORTYPECONSULTA || casoAuxiliar.recordTypeId == RECORTYPECONSULTASAC){
            List<ReclamacionWrapper> resultado = infoConsulta(casoAuxiliar);
            return resultado;
        }

        //Add - Lista de reclamantes
        List<SAC_CaseReclamante__c> reclamantes = [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
                                                    FROM SAC_CaseReclamante__c
                                                    WHERE SAC_Case__c =: casoAuxiliar.Id];

        List<Id> reclamantesAccount = new List<Id>();
        
        for(SAC_CaseReclamante__c reclamante : reclamantes){
            reclamantesAccount.add(reclamante.SAC_Account__c);
        }

        List<SAC_CaseReclamante__c> reclamantesV2 = [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
                FROM SAC_CaseReclamante__c
                WHERE SAC_Account__c IN: reclamantesAccount];

        List<Id> idsCasos = new List<Id>();
        for(SAC_CaseReclamante__c rec : reclamantesV2){
            idsCasos.add(rec.SAC_Case__c);
        }
                
        reclamaciones = [SELECT SAC_Reclamacion__c, Id, CaseNumber, AccountId, Description, ParentId, Subject, CreatedDate, toLabel(Status), Account.Name
                                FROM Case 
                                WHERE Id IN: idsCasos//AccountId IN: reclamantesAccount
                                AND AccountId != null
                                AND recordTypeId =: RECTYPERECLAMACION
                                AND Id != :casoAuxiliar.Id];

        //Lista reclamantes principales
        List<SAC_CaseReclamante__c> reclamantesPrincipalesTotales = 
            [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
                FROM SAC_CaseReclamante__c
                WHERE SAC_Case__c IN: reclamaciones
                    AND SAC_ReclamantePrincipal__c = true];
  
        Map<Id, List<SAC_CaseReclamante__c>> mapDeReclamantesPrincipales = new Map<Id, List<SAC_CaseReclamante__c>>();
        for(SAC_CaseReclamante__c reclamante : reclamantesPrincipalesTotales){
            List<SAC_CaseReclamante__c> nombreReclamantes = new List<SAC_CaseReclamante__c>();
            if(mapDeReclamantesPrincipales.containsKey(reclamante.SAC_Case__c)){
                nombreReclamantes = mapDeReclamantesPrincipales.get(reclamante.SAC_Case__c);
                nombreReclamantes.add(reclamante);
                mapDeReclamantesPrincipales.put(reclamante.SAC_Case__c, nombreReclamantes);
            }
            else{
                nombreReclamantes.add(reclamante);
                mapDeReclamantesPrincipales.put(reclamante.SAC_Case__c, nombreReclamantes);
            }
        }
        //Lista reclamantes secundarios
        List<SAC_CaseReclamante__c> reclamantesSecundariosTotales = 
        [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
            FROM SAC_CaseReclamante__c
            WHERE SAC_Case__c IN: reclamaciones
                AND SAC_ReclamantePrincipal__c = false];
                
        Map<Id, List<SAC_CaseReclamante__c>> mapDeReclamantesSecundarios = new Map<Id, List<SAC_CaseReclamante__c>>();
        for(SAC_CaseReclamante__c reclamante : reclamantesSecundariosTotales){
            List<SAC_CaseReclamante__c> nombreReclamantes = new List<SAC_CaseReclamante__c>();
            if(mapDeReclamantesSecundarios.containsKey(reclamante.SAC_Case__c)){
                nombreReclamantes = mapDeReclamantesSecundarios.get(reclamante.SAC_Case__c);
                nombreReclamantes.add(reclamante);
                mapDeReclamantesSecundarios.put(reclamante.SAC_Case__c, nombreReclamantes);
            }
            else{
                nombreReclamantes.add(reclamante);
                mapDeReclamantesSecundarios.put(reclamante.SAC_Case__c, nombreReclamantes);
            }
        }

        //Map con Id - Reclamacion
        Map<Id,Case> mapDeReclamaciones = new Map<Id, Case>();
        for(Case reclamacionMap : reclamaciones){
            mapDeReclamaciones.put(reclamacionMap.Id, reclamacionMap);
        }

        //Lista pretensiones de las reclamaciones
        List<Case> pretensiones = new List<Case>();
        if(casoAuxiliar.recordTypeId == RECTYPERECLAMACION){
            pretensiones = [ SELECT Id, SAC_Reclamacion__c, SAC_Reclamacion__r.Subject, CaseNumber,Subject, CreatedDate, toLabel(Status),
                                    Owner.Name, SEG_Grupo__r.Name, SEG_Grupo__c
                                    FROM Case
                                    WHERE SAC_Reclamacion__c IN: reclamaciones AND recordTypeId =: RECTYPEPRETENSION];
        }
        
        //Objeto reclamaciones + pretensiones
        List<ReclamacionWrapper> listadoFinal = new List<ReclamacionWrapper>();

        //Map contiene reclamacion + pretensiones
        Map<Id,List<Case>> mapPretensiones = new Map<Id,List<Case>>();

        //MAPEO DEL LISTADO PRETENSIONES A SU CORRESPONDIENTE MAP DE RECLAMACIONES, LISTA PRETENSIONES
        for(Case casoMap : pretensiones){
            //Lista para iterar las pretensiones
            List<Case> listadoAuxiliar = new List<Case>();  
            if(mapPretensiones.containsKey(casoMap.SAC_Reclamacion__c)){
                listadoAuxiliar = mapPretensiones.get(CasoMap.SAC_Reclamacion__c);
                listadoAuxiliar.add(casoMap);
                mapPretensiones.put(CasoMap.SAC_Reclamacion__c, listadoAuxiliar);
            }
            else{
                listadoAuxiliar.add(casoMap);
                mapPretensiones.put(casoMap.SAC_Reclamacion__c, listadoAuxiliar);
            }
        }
        
        //Pasar el objeto MAP al objeto wrapper
        for(String reclamacionMap : mapDeReclamaciones.keySet()){

            Boolean desactivarBtn = false;

            if(reclamacionMap == casoAuxiliar.CC_CasoRelacionado__c){
                desactivarBtn=true;
            }
            //Lista para iterar las pretensiones
            List<Case> pretensionesMapa = new List<Case>();
            pretensionesMapa = mapPretensiones.get(reclamacionMap);

            ReclamacionWrapper reclamacionAuxiliar = new ReclamacionWrapper(mapDeReclamaciones.get(reclamacionMap) , pretensionesMapa,
                mapDeReclamantesPrincipales.get(reclamacionMap), mapDeReclamantesSecundarios.get(reclamacionMap), desactivarBtn, !desactivarBtn);
            listadoFinal.add(reclamacionAuxiliar);
        }

        return listadoFinal;
    }

    /*****************************************************************
     * Proposito: Método para vincular reclamaciones en el apartado Antecedentes del objeto Case 
     *                                                                                        
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
     * 1.2            DE53990        Marcela Neira  12/11/21       Modificación Para no vicular Consultas con reclamaciones Cerradas
     * 1.3            US330921       Marcela Neira  12/11/21       Modificacion (En caso que la reclamación con la que se vincula la Consulta esté 
     *                                                             en estado Cerrada/Ejecución" Y el GESTOR sea diferente del que trata la consulta, 
     *                                                             se mande una notificación al gestor. )
     * 1.4            US683740       Raúl Santos    31/10/24       Modificación:  Si desde una consulta SAC vinculamos una reclamación con grupo letrado informado, 
     *                                                             la consulta SAC debe heredar ese grupo letrado
    *****************************************************************/
    
    @AuraEnabled
    public static String modifySameOwnerCases(String idCasoVinculado, String idCasoActual){
       

        if(!Case.SObjectType.getDescribe().isAccessible()){
            throw new AuraHandledException(MSG_ERROR_PERMISSIONS);
        }
        List<Case> casoAnteriorAVincular = [Select Id, CC_CasoRelacionado__c, Status, RecordTypeId, OwnerId, SEG_Grupo__c, CaseNumber, SAC_PretensionPrincipal__r.OwnerId, SAC_GrupoLetrado__c From Case Where Id =: idCasoVinculado Limit 1];
        List<Case> casoActual = [Select Id, CC_CasoRelacionado__c, Status, RecordTypeId, RecordType.DeveloperName, CaseNumber, OwnerId, SEG_Grupo__c From Case Where Id =: idCasoActual Limit 1];
        //List<Case> pretensiones = [SELECT Id, SAC_Reclamacion__c, Status, SEG_Grupo__c  FROM Case WHERE SAC_Reclamacion__c =: idCasoActual AND Status != 'SAC_009'];
        String tipoCaso = casoActual[0].RecordType.DeveloperName + ';' + casoAnteriorAVincular[0].CaseNumber;
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        List<Case> listaCasosUpdatear = new List<Case>();

           
            Id casoRelacionado = casoAnteriorAVincular[0].Id;
            casoActual[0].CC_CasoRelacionado__c = casoRelacionado;

    
            if(Case.SObjectType.getDescribe().isUpdateable()){
                if( casoActual[0].RecordTypeId == RECORTYPECONSULTA && (casoAnteriorAVincular[0].Status !='Cerrado' && casoAnteriorAVincular[0].Status !='SAC_008')){ 
                    //Enviar notificación
                    FeedItem post = new FeedItem();
                    post.ParentId = casoRelacionado;
                    post.Body =  'Se ha vinculado la Consulta ' + casoActual[0].CaseNumber;
                    insert post;

                    //casoActual[0].OwnerId = casoAnteriorAVincular[0].ownerId;
                    //casoActual[0].SEG_Grupo__c = casoAnteriorAVincular[0].SEG_Grupo__c;                    
                } 
                //En caso que la reclamación con la que se vincula esté en estado Cerrada/Ejecución" y el GESTOR sea diferente 
                //del trata la en consulta, se mande una notificación al gestor.
                if( casoActual[0].RecordTypeId == RECORTYPECONSULTA || casoActual[0].RecordTypeId == RECORTYPECONSULTASAC){

                        casoAnteriorAVincular[0].SAC_NuevaConsulta__c = true;

                        if((casoAnteriorAVincular[0].Status =='Cerrado' || casoAnteriorAVincular[0].Status =='SAC_004')){
                             
                            if(casoActual[0].OwnerId != casoAnteriorAVincular[0].OwnerId){ //Enviar notificación
                                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAnteriorAVincular[0].Id,
                                                                                    'SAC_015',
                                                                                    'La consulta número: '+ casoActual[0].CaseNumber + 
                                                                                    ' ha sido vinculada a la reclamación número: ' + casoAnteriorAVincular[0].CaseNumber + ' con estado Cerrado/Ejecución',
                                                                                    casoAnteriorAVincular[0].OwnerId,
                                                                                    casoActual[0].Id,
                                                                                    '',
                                                                                    '');
                                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoActual[0].Id;
                                //Añadirla a la lista para posteriormente llamar al método
                                listaWrapperAlerta.add(wrapAlerta);
    
                                /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                                SAC_Notificacion.enviarNotificacion(casoAnteriorAVincular[0].OwnerId, casoActual[0].Id, 'Esta consulta se ha vinculado a una reclamación cerrada o en ejecución', 'La consulta número: '+ casoActual[0].CaseNumber + ' ha sido vinculada a la reclamación número: ' + casoAnteriorAVincular[0].CaseNumber + ' con estado Cerrado/Ejecución');*/
                            }
                        }else if (casoAnteriorAVincular[0].Status !='Rechazado'){

                            if(casoAnteriorAVincular[0].SAC_PretensionPrincipal__r.OwnerId != null){
                                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoAnteriorAVincular[0].Id,
                                'SAC_015',
                                'La consulta número: '+ casoActual[0].CaseNumber + 
                                ' ha sido vinculada a la reclamación número: ' + casoAnteriorAVincular[0].CaseNumber,
                                casoAnteriorAVincular[0].SAC_PretensionPrincipal__r.OwnerId,
                                casoActual[0].Id,
                                '',
                                '');
                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + casoActual[0].Id;
                                //Añadirla a la lista para posteriormente llamar al método
                                listaWrapperAlerta.add(wrapAlerta);
                            }                           
                        } 

                        //Si desde una consulta SAC vinculamos una reclamación con grupo letrado informado, la consulta SAC debe heredar ese grupo letrado
                        if(casoActual[0].RecordTypeId == RECORTYPECONSULTASAC && casoAnteriorAVincular[0].SAC_GrupoLetrado__c != null){
                            casoActual[0].SAC_GrupoLetrado__c =  casoAnteriorAVincular[0].SAC_GrupoLetrado__c;
                        }                  
                }

                listaCasosUpdatear.add(casoActual[0]);
                listaCasosUpdatear.add(casoAnteriorAVincular[0]);
                update listaCasosUpdatear;               
                //Si tenemos alertas que enviar, se llama al método que las envía
                if (!listaWrapperAlerta.isEmpty()) {
                    SAC_Alertas.generarAlertas(listaWrapperAlerta);
                }
            }
            else{
                throw new AuraHandledException(MSG_ERROR_PERMISSIONS);
            }
            
            return tipoCaso;
    }    
    
    public class ReclamacionWrapper{
/*****************************************************************
 * Name: ReclamacionWrapper
 * Copyright © 2021  CaixaBank
 *                                                                                        
 * Proposito: Clase Wrapper para mandar contenido formateado del controlador Apex al controlador JS para el correcto funcionamiento
 *  del Lightning Web Component: sAC_AsociarReclamacion.
 *                                                                                        
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa     16/04/21      Creación Clase
*****************************************************************/

        @AuraEnabled public List<Case> pretensiones {get; set;}
        @AuraEnabled public Case reclamacionActual {get; set;}
        @AuraEnabled public List<SAC_CaseReclamante__c> listaDeReclamantesPrincipales {get; set;}
        @AuraEnabled public List<SAC_CaseReclamante__c> listaDeReclamantesSecundarios {get; set;}
        @AuraEnabled public Boolean desactivarBotonVincular {get; set;}
        @AuraEnabled public Boolean desactivarBotonDesvincular {get; set;}
        
        public ReclamacionWrapper(Case reclamacion, List<Case> listaPretensiones, List<SAC_CaseReclamante__c> listaReclamantesPrinc, List<SAC_CaseReclamante__c> listaReclamantesSec, Boolean desactivarBtn, Boolean desactivarBtnDes)
        {
/*****************************************************************
 * Proposito: Método constructor de la clase Wrapper
 *                                                                                        
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
*****************************************************************/
            reclamacionActual = reclamacion;
            pretensiones = listaPretensiones;     
            listaDeReclamantesPrincipales = listaReclamantesPrinc;   
            listaDeReclamantesSecundarios = listaReclamantesSec;
            desactivarBotonVincular = desactivarBtn;
            desactivarBotonDesvincular = desactivarBtnDes;
        }
        
    }

    //private static void throwAuraHandledException( String errorMsg ){
/*****************************************************************
 * Proposito: Método para controlar errores y lanzarlos por pantalla
 *                                                                                        
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
*****************************************************************/
        /*AuraHandledException auraException = new AuraHandledException( errorMsg );
        auraException.setMessage( errorMsg );
        throw auraException;
    }*/

    @AuraEnabled
    public static String desvincular(String idCasoVinculado, String idCasoActual){
        if(!Case.SObjectType.getDescribe().isAccessible()){
            throw new AuraHandledException(MSG_ERROR_PERMISSIONS);
        }
        List<Case> casoAVincular = [Select Id, CC_CasoRelacionado__c, Status, RecordTypeId, OwnerId, SEG_Grupo__c, CaseNumber From Case Where Id =: idCasoVinculado Limit 1];
        List<Case> casoActual = [Select Id, CC_CasoRelacionado__c, Status, RecordTypeId, RecordType.DeveloperName, CaseNumber, OwnerId, SEG_Grupo__c From Case Where Id =: idCasoActual Limit 1];
        //List<Case> pretensiones = [SELECT Id, SAC_Reclamacion__c, Status, SEG_Grupo__c  FROM Case WHERE SAC_Reclamacion__c =: idCasoActual AND Status != 'SAC_009'];
        String tipoCaso = casoActual[0].RecordType.DeveloperName + ';' + casoAVincular[0].CaseNumber;

        //if(pretensiones.isEmpty()){
           
            Id casoRelacionado = null;
            casoActual[0].CC_CasoRelacionado__c = casoRelacionado;
            if(Case.SObjectType.getDescribe().isUpdateable()){
                if( casoActual[0].RecordTypeId == RECORTYPECONSULTA && (casoAVincular[0].Status !='Cerrado' && casoAVincular[0].Status !='SAC_008')){ //Enviar notificación
                    FeedItem post = new FeedItem();
                    post.ParentId = casoActual[0].Id;
                    post.Body =  'Se ha desvinculado la Consulta ' + casoActual[0].CaseNumber;
                    insert post;

                    /* casoActual[0].OwnerId = casoAVincular[0].ownerId;
                    casoActual[0].SEG_Grupo__c = casoAVincular[0].SEG_Grupo__c; */ 
                } 
                update casoActual;           
            }
            else{
                throw new AuraHandledException(MSG_ERROR_PERMISSIONS);
            }
            
            return tipoCaso;
        //}
       // else{
        //    throw new AuraHandledException('No se puede desvincular la reclamación.');
        //}
    }    

//--------------------------- Metodo para consultas -----------------------------    

    @AuraEnabled
    public static List<ReclamacionWrapper> infoConsulta(Case consulta){
        List<ReclamacionWrapper> resultado = new List<ReclamacionWrapper>();

        //Add - Lista de reclamantes
        List<SAC_CaseReclamante__c> reclamantes = [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
                                                    FROM SAC_CaseReclamante__c
                                                    WHERE SAC_Case__c =: consulta.Id];

        List<Id> reclamantesAccount = new List<Id>();
        
        for(SAC_CaseReclamante__c reclamante : reclamantes){
            reclamantesAccount.add(reclamante.SAC_Account__c);
        }

        List<SAC_CaseReclamante__c> reclamantesV2 = [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
                FROM SAC_CaseReclamante__c
                WHERE SAC_Account__c IN: reclamantesAccount];

        List<Id> idsCasos = new List<Id>();
        for(SAC_CaseReclamante__c rec : reclamantesV2){
            idsCasos.add(rec.SAC_Case__c);
        }
        
        
        List<Case> reclamaciones = [SELECT SAC_Reclamacion__c, Id, CaseNumber, AccountId, Description, ParentId, Subject, CreatedDate, toLabel(Status), Account.Name
                                FROM Case 
                                WHERE Id IN: idsCasos//AccountId IN: reclamantesAccount
                                AND AccountId != null
                                AND recordTypeId =: RECTYPERECLAMACION
                                AND Id != :consulta.Id];
        

        //Lista reclamantes principales
        List<SAC_CaseReclamante__c> reclamantesPrincipalesTotales = 
            [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
                FROM SAC_CaseReclamante__c
                WHERE SAC_Case__c IN: reclamaciones
                    AND SAC_ReclamantePrincipal__c = true];
  
        Map<Id, List<SAC_CaseReclamante__c>> mapDeReclamantesPrincipales = new Map<Id, List<SAC_CaseReclamante__c>>();
        for(SAC_CaseReclamante__c reclamante : reclamantesPrincipalesTotales){
            List<SAC_CaseReclamante__c> nombreReclamantes = new List<SAC_CaseReclamante__c>();
            if(mapDeReclamantesPrincipales.containsKey(reclamante.SAC_Case__c)){
                nombreReclamantes = mapDeReclamantesPrincipales.get(reclamante.SAC_Case__c);
                nombreReclamantes.add(reclamante);
                mapDeReclamantesPrincipales.put(reclamante.SAC_Case__c, nombreReclamantes);
            }
            else{
                nombreReclamantes.add(reclamante);
                mapDeReclamantesPrincipales.put(reclamante.SAC_Case__c, nombreReclamantes);
            }
        }
        //Lista reclamantes secundarios
        List<SAC_CaseReclamante__c> reclamantesSecundariosTotales = 
        [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
            FROM SAC_CaseReclamante__c
            WHERE SAC_Case__c IN: reclamaciones
                AND SAC_ReclamantePrincipal__c = false];
                
        Map<Id, List<SAC_CaseReclamante__c>> mapDeReclamantesSecundarios = new Map<Id, List<SAC_CaseReclamante__c>>();
        for(SAC_CaseReclamante__c reclamante : reclamantesSecundariosTotales){
            List<SAC_CaseReclamante__c> nombreReclamantes = new List<SAC_CaseReclamante__c>();
            if(mapDeReclamantesSecundarios.containsKey(reclamante.SAC_Case__c)){
                nombreReclamantes = mapDeReclamantesSecundarios.get(reclamante.SAC_Case__c);
                nombreReclamantes.add(reclamante);
                mapDeReclamantesSecundarios.put(reclamante.SAC_Case__c, nombreReclamantes);
            }
            else{
                nombreReclamantes.add(reclamante);
                mapDeReclamantesSecundarios.put(reclamante.SAC_Case__c, nombreReclamantes);
            }
        }

        //Map con Id - Reclamacion
        Map<Id,Case> mapDeReclamaciones = new Map<Id, Case>();
        for(Case reclamacionMap : reclamaciones){   
            mapDeReclamaciones.put(reclamacionMap.Id, reclamacionMap);
        }
        //Lista pretensiones de las reclamaciones
        List<Case> pretensiones = new List<Case>();
            pretensiones = [ SELECT Id, SAC_Reclamacion__c, SAC_Reclamacion__r.Subject, CaseNumber,Subject, CreatedDate, toLabel(Status),
                                    Owner.Name, SEG_Grupo__r.Name, SEG_Grupo__c
                                    FROM Case
                                    WHERE SAC_Reclamacion__c IN: reclamaciones AND recordTypeId =: RECTYPEPRETENSION];
        
        //Objeto reclamaciones + pretensiones
        List<ReclamacionWrapper> listadoFinal = new List<ReclamacionWrapper>();

        //Map contiene reclamacion + pretensiones
        Map<Id,List<Case>> mapPretensiones = new Map<Id,List<Case>>();

        //MAPEO DEL LISTADO PRETENSIONES A SU CORRESPONDIENTE MAP DE RECLAMACIONES, LISTA PRETENSIONES
        for(Case casoMap : pretensiones){
            //Lista para iterar las pretensiones
            List<Case> listadoAuxiliar = new List<Case>(); 
            if(mapPretensiones.containsKey(casoMap.SAC_Reclamacion__c)){
                listadoAuxiliar = mapPretensiones.get(CasoMap.SAC_Reclamacion__c);
                listadoAuxiliar.add(casoMap);
                mapPretensiones.put(CasoMap.SAC_Reclamacion__c, listadoAuxiliar);
            }
            else{
                listadoAuxiliar.add(casoMap);
                mapPretensiones.put(casoMap.SAC_Reclamacion__c, listadoAuxiliar);
            }
        }
        
        //Pasar el objeto MAP al objeto wrapper
        for(Case reclamacion : reclamaciones){

            Boolean desactivarBtn = false;

            if(reclamacion.Id == consulta.CC_CasoRelacionado__c){
                desactivarBtn=true;
            }

            //Lista para iterar las pretensiones
            List<Case> pretensionesMapa = new List<Case>();
            if(mapPretensiones.containsKey(reclamacion.Id)){
                pretensionesMapa = mapPretensiones.get(reclamacion.Id);
            }

            ReclamacionWrapper reclamacionAuxiliar = new ReclamacionWrapper(mapDeReclamaciones.get(reclamacion.Id) , pretensionesMapa,
                mapDeReclamantesPrincipales.get(reclamacion.Id), mapDeReclamantesSecundarios.get(reclamacion.Id), desactivarBtn, !desactivarBtn);

            resultado.add(reclamacionAuxiliar);
        }

        return resultado;

    }

}