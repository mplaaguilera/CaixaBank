/*****************************************************************
 * Name: SAC_LCMP_InsertarPretension
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador para maneja la lógica del component sac_RedaccionReclamacion 
 *      y validar la etapa correspondiente
 * 
 *   LWC asociado: sac_RedaccionReclamacion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US248482         Luis Mesa     28/07/21      Creación Clase
 * ***************************************************************/

public with sharing class SAC_LCMP_RedaccionReclamacion {
    
    @AuraEnabled
    public static Boolean validacionRedaccion(String id){
    /*****************************************************************
    * Proposito: Validar que las pretensiones de la reclamación a la que se ha de rellenar la redacción están listas para la redacción final
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      28/07/21     Creación
    *****************************************************************/
        if(!Schema.sObjectType.Case.isAccessible()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }
        List<Case> pretensiones = [SELECT Id, SAC_RedaccionFinal__c, SAC_Redaccion__c FROM Case WHERE SAC_Reclamacion__c =: id];
        if(pretensiones.size() > 0){
            for(Case pretension : pretensiones){
                if(!pretension.SAC_RedaccionFinal__c || String.isBlank(pretension.SAC_Redaccion__c)){
                    return false;
                }
            }
            return true;
        }
        else{
            throw new AuraHandledException('No existen pretensiones de la reclamación.');
        }
    }

    @AuraEnabled
    public static String getBodyRedaccion(String id){
    /*****************************************************************
    * Proposito: Rellenar la redacción de la Reclamación a partir de la redacción de sus pretensiones.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      28/07/21     Creación
    *****************************************************************/
        EmailTemplate importado = [SELECT Id, BrandTemplateId, HtmlValue, Body, DeveloperName FROM EmailTemplate WHERE Name =: 'SAC Redaccion' LIMIT 1];
        //String stringFinal = importado.HtmlValue;
        Id head = importado.BrandTemplateId;
        
        BrandTemplate bt = [SELECT Value FROM BrandTemplate WHERE Id =: head LIMIT 1];
        String header = bt.Value;
        String body = importado.Body;

        List<String> contentParts = new List<String>{header, body};
        
        String whoId = UserInfo.getUserId();
        String whatId = id;
        String stringFinal = '';
        List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(whoId, whatId, contentParts);
        String substring = '';
        
        String result = '<br />';
        if(!Schema.sObjectType.Case.isAccessible()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }
        List<Case> pretensiones = [SELECT Id, SAC_Redaccion__c FROM Case WHERE SAC_Reclamacion__c =: id];

        if(pretensiones.size() > 0){
            for(Case pretension : pretensiones){
                result += pretension.SAC_Redaccion__c + '<br />' +'<br />';
            }
        }

        if(resList.size() > 0){
            stringFinal = resList[0].getMergedBody();
            substring = stringFinal.substringBetween('[CDATA[',']]>');
        }
        if(!String.isBlank(substring)){
            String url = URL.getSalesforceBaseUrl().toExternalForm();
            String img = '<img src="'+ url + substring + '" alt="" border="0" align="left">';
            //

            String user = UserInfo.getUserId();

            if(!Schema.sObjectType.User.isAccessible()){
                throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
            }
            User u = [SELECT Id, Name FROM User WHERE Id =: user];
            String cuerpo = img + result/* + 'Atentamente su gestor de confianza ' + u.Name*/;
            return cuerpo;
        }
        // hacer substring y sacar la imagen de dentro del letterhead
        return result;
    }

    @AuraEnabled
    public static void guardarRedaccion(String id, String texto){
    /*****************************************************************
    * Proposito: Rellenar la redacción de la Reclamación a partir de la redacción de sus pretensiones.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      28/07/21     Creación
    *****************************************************************/ 
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }
        Case casoActual = [SELECT Id, SAC_Redaccion__c FROM Case WHERE Id =: id];
        casoActual.SAC_Redaccion__c = texto;
        update casoActual;
    }

    @AuraEnabled
    public static Boolean gestionTareas(String id){
    /*****************************************************************
    * Proposito: Comprobar si la reclamación tiene tareas o no.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      05/08/21     Creación
    *****************************************************************/ 
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isAccessible()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }
        Case reclamacion = [SELECT Id FROM Case WHERE Id =: id];
        List<Case> pretensiones = [SELECT Id, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
        List<SAC_Accion__c> tareas = [SELECT Id, SAC_Reclamacion__c, SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Reclamacion__c =: reclamacion.Id];

        return tareas.size() > 0 ? true : false;
    }

    @AuraEnabled
    public static void guardarSentidoResolucion(String id, String sentido, String argumento){
    /*****************************************************************
    * Proposito: Guardar el contenido de los campos sentido resolucion y argumento resolucion.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      26/08/21     Creación
    *****************************************************************/ 
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes permisos para visualizar o actualizar el registro.');
        }
        system.debug(id + '  ' + sentido + '  ' + argumento );
        Case casoActual = [SELECT Id, SAC_SentidoResolucion__c, SAC_MotivoSentidoResolucion__c FROM Case WHERE Id =: id LIMIT 1];
        casoActual.SAC_SentidoResolucion__c = sentido;
        casoActual.SAC_MotivoSentidoResolucion__c = argumento;
        system.debug(casoActual);
        update casoActual;
    }

    @AuraEnabled
    public static DateTime finalizarRedaccion(String id){
    /*****************************************************************
    * Proposito: Comprobar si la reclamación tiene tareas o no.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      05/08/21     Creación
    *****************************************************************/ 
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isAccessible() || !Schema.sObjectType.SAC_Accion__c.isUpdateable() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular la redacción.');
        }
        Case reclamacion = [SELECT Id, OS_Fecha_Resolucion__c, Status, SAC_Redaccion__c, OS_Email__c, CaseNumber  FROM Case WHERE Id =: id];
        List<SAC_Accion__c> tareas = [SELECT Id, OwnerId, SAC_Estado__c, SAC_Pretension__c, SAC_Reclamacion__c, Name, SAC_EquipoResponsable__c
                                        FROM SAC_Accion__c WHERE SAC_Reclamacion__c =: id];

        List<Case> pretensiones = [SELECT Id, Status FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];

        reclamacion.OS_Fecha_Resolucion__c = system.now();
        //lanzar el correo al reclamante
        lanzarCorreo(reclamacion.SAC_Redaccion__c, reclamacion.OS_Email__c);
        //actualizar estados de tareas + notificacion a los equipos ejecutores
        if(!tareas.isEmpty()){
            reclamacion.Status = 'SAC_004';
            reclamacion.SAC_StatusAuxiliar__c = 'SAC_004';
            for(Case pretension : pretensiones){
                pretension.Status = 'Cerrado';
                pretension.SAC_StatusAuxiliar__c = 'Cerrado';
            }
            gestionarTareas(tareas, reclamacion.CaseNumber);
        }
        else{
            for(Case pretension : pretensiones){
                pretension.Status = 'Cerrado';
                pretension.SAC_StatusAuxiliar__c = 'Cerrado';
            }
            reclamacion.Status = 'Cerrado';
            reclamacion.SAC_StatusAuxiliar__c = 'Cerrado';
        }

        update pretensiones;
        update reclamacion;
        return reclamacion.OS_Fecha_Resolucion__c;
    }

    @AuraEnabled
    public static void lanzarCorreo(String texto, String direccion){
    /*****************************************************************
    * Proposito: Lanzar el email con la redacción al reclamante
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      06/08/21     Creación
    *****************************************************************/ 
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { direccion };
        message.optOutPolicy = 'FILTER';
        message.Subject = 'Redacción de la Reclamación';
        message.HtmlBody = texto;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

    @AuraEnabled
    public static void gestionarTareas(List<SAC_Accion__c> acciones, String numCaso){
    /*****************************************************************
    * Proposito: Lanzar el email con la redacción al reclamante
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      06/08/21     Creación
    *****************************************************************/ 
        List<Id> idListaGrupos = new List<Id>();
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        for(SAC_Accion__c accion : acciones){
            accion.SAC_Estado__c = 'SAC_EnGestion';
            idListaGrupos.add(accion.SAC_EquipoResponsable__c);
        }
        listaGrupos = [SELECT Id, SAC_Email__c FROM CC_Grupo_Colaborador__c WHERE Id IN: idListaGrupos];
        
        String [] arrayAddress = new List<String>();
        for(CC_Grupo_Colaborador__c grupo : listaGrupos){
            arrayAddress.add(grupo.SAC_Email__c);
        }

        //falta crear el texto desde una plantilla
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE name = 'SAC Notificar equipo red'];
        system.debug('prueba email template equipos ' + emailTemplate.Subject + '  ' + emailTemplate.Body);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = arrayAddress;
        message.optOutPolicy = 'FILTER';
        message.Subject = emailTemplate.Subject;
        message.HtmlBody = /*texto*/ emailTemplate.Body + ' ' + numCaso;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        update acciones;
    }
    
    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoList(){
    /*****************************************************************
    * Proposito: Obtener los valores del picklist para mostrarlos por pantalla
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US248482         Luis Mesa      04/08/21     Creación
    *****************************************************************/ 
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = Case.SAC_SentidoResolucion__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
     }

    public class plantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }
}