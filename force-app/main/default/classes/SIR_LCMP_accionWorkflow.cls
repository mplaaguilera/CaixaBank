/*****************************************************************
 Name:  SIR_LCMP_accionWorkflow
 Copyright © 2022  CaixaBank

Proposito:   Clase controladora externa del LWC SIR_LCMP_accionWorkflow                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         06/05/2022     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_accionWorkflow {

    /*****************************************************************
        Proposito: Realizamos query para obtener el nombre del proceso.                                                      
        Parameters: Id proceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/05/2022     	  Created     
        
	*****************************************************************/                              
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProceso(String idProceso) { 
        List<SIREC__SIREC_obj_proceso__c> procesoLst = new List<SIREC__SIREC_obj_proceso__c>(); 

        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            procesoLst = [SELECT Name, SIREC__SIREC_fld_cliente__c, RecordType.DeveloperName, SIREC__SIREC_fld_estrategia__c, SIREC__SIREC_fld_tarea__c, RecordTypeId,
                        SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_fechaInicio__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c, 
                        SIR_fechaCarga__c, SIREC__SIREC_fld_descEstrategiaCatalogo__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c
                        FROM SIREC__SIREC_obj_proceso__c   
                        WHERE id=:idProceso];
        
            
            return procesoLst;
        }
        return null;
    } 

    /*****************************************************************
        Proposito: Realizamos query para obtener el nombre del proceso.                                                      
        Parameters: Id proceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         09/05/2022     	  Created     
        
	*****************************************************************/                              
    @AuraEnabled
    public static List<SIREC__SIREC_obj_acciones__c> getAccionProceso(String idTarea) {    
        
        List<SIREC__SIREC_obj_acciones__c> accionLst = new List<SIREC__SIREC_obj_acciones__c>();

        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){
            accionLst = [SELECT id, name, SIREC__SIREC_fld_tarea__c,SIREC__SIREC_fld_estado__c
                        FROM SIREC__SIREC_obj_acciones__c 
                        WHERE SIREC__SIREC_fld_tarea__c =: idTarea
                        AND SIREC__SIREC_fld_estado__c != 'Finalizada' AND SIREC__SIREC_fld_estado__c != 'Borrar'
                        LIMIT 1];

            return accionLst;
        }
        return null;
    }

    /*****************************************************************
        Proposito: Realizamos query para obtener la accion                                                      
        Parameters: Id accion
        Returns: List                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/05/2022     	  Created     
        
	*****************************************************************/                              
    @AuraEnabled
    public static List<SIREC__SIREC_obj_acciones__c> getAccion(String idAccion) {  
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){
            List<SIREC__SIREC_obj_acciones__c> accion = [SELECT Id, SIREC__SIREC_fld_responsable__c,SIREC__SIREC_fld_proceso__c, SIREC__SIREC_fld_estado__c,
                                                        SIREC__SIREC_fld_fechaContacto__c, SIREC__SIREC_fld_tipo__c, SIREC__SIREC_fld_accion__c, RecordTypeId,
                                                        SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_comentarios__c, SIREC__SIREC_fld_resultado__c, 
                                                        SIREC__SIREC_fld_proceso__r.RecordTypeId, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_cliente__c, 
                                                        SIREC__SIREC_fld_proceso__r.Name, SIREC__SIREC_fld_proceso__r.SIR_fechaCarga__c, 
                                                        SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaInicio__c, SIR_contactoAccionEmp__c
                                                        FROM SIREC__SIREC_obj_acciones__c WHERE id=:idAccion LIMIT 1];
            return accion;
        }
        return null;
    }     
    
    /*****************************************************************
        Proposito: Recogemos los intervinientes                                                      
        Parameters: No
        Returns: List<SelectOption>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/05/2022     	  Created     
        
	*****************************************************************/                              
    @AuraEnabled
    public static List<SelectOption> getPicklistIntervinientes(String idProceso) {
        if(Schema.SObjectType.SIREC__SIREC_obj_personaAsociada__c.isAccessible()){
            List<SIREC__SIREC_obj_personaAsociada__c> personAsociadas = [SELECT id, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_persona__r.Name 
                                                                        FROM SIREC__SIREC_obj_personaAsociada__c 
                                                                        WHERE SIREC__SIREC_fld_proceso__c =: idProceso AND SIR_estadoCarga__c != 'B'];            
            List<SelectOption> options = new List<SelectOption>();
            for (SIREC__SIREC_obj_personaAsociada__c persona: personAsociadas) {
                options.add(new SelectOption(persona.SIREC__SIREC_fld_persona__c, persona.SIREC__SIREC_fld_persona__r.Name));
            }  
            return options;
        }
        return null;
    }

    /*****************************************************************
        Proposito: Recogemos los intervinientes                                                      
        Parameters: No
        Returns: List<SelectOption>                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/05/2022     	  Created     
        
	*****************************************************************/                              
    @AuraEnabled
    public static List<SelectOption> getPicklistContactos(String idAccount) {
        if(Schema.SObjectType.Contact.isAccessible()){
            List<Contact> contacto = [SELECT Id, FirstName, LastName, CIBE_Cargo__c, toLabel(CIBE_Carrec__c), RecordType.DeveloperName FROM Contact WHERE AccountId = :idAccount 
                                      AND (RecordType.DeveloperName = 'CIBE_ContactoComercial' OR RecordType.DeveloperName = 'CIBE_Apoderado')];            
            List<SelectOption> options = new List<SelectOption>();
            for (Contact cont: contacto) {
                if(cont.RecordType.DeveloperName == 'CIBE_ContactoComercial'){
                    options.add(new SelectOption(cont.Id, cont.FirstName + ' ' + cont.LastName + ' (' + cont.CIBE_Cargo__c + ')'));
                } else {
                    options.add(new SelectOption(cont.Id, cont.FirstName + ' ' + cont.LastName + ' (' + cont.CIBE_Carrec__c + ')'));
                }                
            }  
            return options;
        }
        return null;
    }      
    
    /*****************************************************************
        Proposito: Metodo para recoger correctamente las picklist                                                     
        Parameters: 
        Returns:                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/05/2022     	  Created     
        
	*****************************************************************/
    public class SelectOption {
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
            this.disabled = false;
            this.escapeItem = false;
        }        
        public SelectOption(String value, String label, Boolean isDisabled) {
            this.value = value;
            this.label = label;
            this.disabled = isDisabled;
            this.escapeItem = false;
        }        
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String value { get;set; }
        @AuraEnabled
        public Boolean disabled { get;set; }
        @AuraEnabled
        public Boolean escapeItem { get;set; }        
    }    
    
    /*****************************************************************
        Proposito: Buscamos RecordType de Accion por RecordType.DeveloperName de Proceso                                                     
        Parameters: List<String>
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         16/10/2024     	  Created     
        
	*****************************************************************/ 
    
    @AuraEnabled
    public static Id buscarIdsAccion(String rtDevelop){
        if(Schema.SObjectType.RecordType.isAccessible()){
            //Modificar esto para el condicional (Mirar si esta bien el parametro del frontal)
            if(rtDevelop == SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA){ //PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA
                return Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_WORKFLOW).getRecordTypeId();
            }else if (rtDevelop == SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_EMP_FLUJO) { //PROCESO_RECORDTYPE_DEVELOPER_NAME_EMP_FLUJO
                return Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_EMPRESA).getRecordTypeId();
            } else if (rtDevelop == SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL) { //PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL
                return Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId();
            }else{
                return null;
            }
        } 
        return null; 
    }


    /*****************************************************************
        Proposito: Insertamos la accion                                                      
        Parameters: List<String>
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/05/2022     	  Created     
        
	*****************************************************************/ 

    @AuraEnabled
    public static String insertAccion(List<String> data) {
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isCreateable() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){
            try {  
              
                SIREC__SIREC_obj_acciones__c insertForm = new SIREC__SIREC_obj_acciones__c();  
                String resultadoAccion;
                Boolean resultadoInformado = false;              
                String fecha = data[0];
                String[] fechaPartida = fecha.split('T');
                insertForm.SIREC__SIREC_fld_fechaContacto__c = date.valueof(data[0]);
                insertForm.SIREC__SIREC_fld_tipo__c = data[1];
                insertForm.SIREC__SIREC_fld_accion__c = data[2];
                insertForm.SIR_valorAccion__c = getValuePicklistAccion(data[2]);
                insertForm.SIREC__SIREC_fld_resultado__c = data[3];
                if(String.isblank(insertForm.SIREC__SIREC_fld_resultado__c)){
                    insertForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_EN_CURSO;
                }else{
                    insertForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_PENDIENTE;
                    resultadoInformado = true;
                }
                insertForm.SIREC__SIREC_fld_comentarios__c = data[4];
                insertForm.SIREC__SIREC_fld_responsable__c = data[5];        
                insertForm.SIREC__SIREC_fld_interviniente__c = data[6];
                insertForm.SIREC__SIREC_fld_persona__c = data[6];
                insertForm.SIREC__SIREC_fld_proceso__c = data[7];
                if(data[8] != ''){
                    insertForm.SIR_contactoAccionEmp__c = data[8];
                    insertForm.SIR_contactoCargoAccionEmp__c = data[9];
                }                
                insertForm.SIR_CodigoEstrategia__c = data[10]; 
                insertForm.SIR_estrategia__c = data[12]; 
             
                insertForm.RecordTypeId = data[11];
                insertForm.SIREC__SIREC_fld_tarea__c = data[13];   
             
                //Se crea la nueva accion
                insert insertForm;               
                String resultado = 'OK-' + resultadoInformado + '@' + insertForm.Id;
                return resultado;                   
            } catch (Exception e) {
                CBK_log.error(e, 'Error : SIR_LCMP_accionWorkflow - insertAccion  -  ' + e.getTypeName() + ': ' + e.getMessage());
                return 'Ha ocurrido un error: ' + e.getMessage();
            }
        }
        return '';
    }    

    /*****************************************************************
        Proposito: Update de la accion desde la ficha de Accion                                                     
        Parameters: List<String>
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/05/2022     	  Created     
        
	*****************************************************************/                              
    @AuraEnabled
    public static String updateAccion(List<String> data, String idAccion, String idProceso) {
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isUpdateable() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){
            try {
                SIREC__SIREC_obj_acciones__c updateForm = new SIREC__SIREC_obj_acciones__c();
                if(idAccion != null ){
                    updateForm = [SELECT id, SIREC__SIREC_fld_fechaContacto__c, SIREC__SIREC_fld_tipo__c, SIR_FechaCompromisoPago__c,
                                SIREC__SIREC_fld_accion__c, SIREC__SIREC_fld_resultado__c, SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_comentarios__c,
                                SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_responsable__c, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_proceso__c,
                                SIR_contactoAccionEmp__c, SIR_contactoCargoAccionEmp__c
                                FROM SIREC__SIREC_obj_acciones__c WHERE Id =: idAccion];
                }else if(idProceso != null){
                    updateForm = [SELECT id, SIREC__SIREC_fld_fechaContacto__c, SIREC__SIREC_fld_tipo__c, SIR_FechaCompromisoPago__c,
                                SIREC__SIREC_fld_accion__c, SIREC__SIREC_fld_resultado__c, SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_comentarios__c,
                                SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_responsable__c, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_proceso__c,
                                SIR_contactoAccionEmp__c, SIR_contactoCargoAccionEmp__c
                                FROM SIREC__SIREC_obj_acciones__c WHERE SIREC__SIREC_fld_proceso__c =: idProceso AND Id =: idAccion];
                } 
                String resultadoAccion;
                Boolean resultadoInformado = false;              
                String fecha = data[0];
                String[] fechaPartida = fecha.split('T');
                updateForm.SIREC__SIREC_fld_fechaContacto__c = date.valueof(data[0]);
                updateForm.SIREC__SIREC_fld_tipo__c = data[1];
                updateForm.SIREC__SIREC_fld_accion__c = data[2];
                updateForm.SIR_valorAccion__c  = getValuePicklistAccion(data[2]); 
                updateForm.SIREC__SIREC_fld_resultado__c = data[3];
                if(String.isblank(updateForm.SIREC__SIREC_fld_resultado__c)){
                    updateForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_EN_CURSO;
                }else{
                    updateForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_PENDIENTE;                    
                    resultadoInformado = true;
                }                                
                updateForm.SIREC__SIREC_fld_comentarios__c = data[4];
                updateForm.SIREC__SIREC_fld_responsable__c = data[5];        
                updateForm.SIREC__SIREC_fld_interviniente__c = data[6];
                updateForm.SIREC__SIREC_fld_persona__c = data[6]; 
                if(data[8] != ''){
                    updateForm.SIR_contactoAccionEmp__c = data[8];
                    updateForm.SIR_contactoCargoAccionEmp__c = data[9];
                }                    
                //Se actualiza la accion
                update updateForm;	                         
                String resultado = 'OK-' + resultadoInformado;            
                return resultado;                   
            } catch (Exception e) {
                CBK_log.error(e, 'Error : SIR_LCMP_accionWorkflow - updateAccion  - ' + e.getTypeName() + ': ' + e.getMessage());
                return 'Ha ocurrido un error: ' + e.getMessage();
            }
        }
        return '';
    }  
    
    @AuraEnabled
    public static List<String> enviarAccion(String idAccion, String idProceso) { 
        List<SIREC__SIREC_obj_acciones__c> lstAccion = new List<SIREC__SIREC_obj_acciones__c>();
        String[] resultado = new String[]{''}; 
        
        List<String> resultadoWS = new List<String>();
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){  
            if(idProceso != null){
                lstAccion = [SELECT Id, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_responsable__c, SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_proceso__c,
                            SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_accion__c, SIREC__SIREC_fld_resultado__c, SIREC__SIREC_fld_tipo__c, SIREC__SIREC_fld_comentarios__c, 
                            SIREC__SIREC_fld_fechaContacto__c , SIR_accionEnviada__c
                            FROM SIREC__SIREC_obj_acciones__c WHERE SIREC__SIREC_fld_proceso__c =: idProceso AND Id =: idAccion];
            }else if(idAccion != null){
                lstAccion = [SELECT Id, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_responsable__c, SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_proceso__c,
                            SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_accion__c, SIREC__SIREC_fld_resultado__c, SIREC__SIREC_fld_tipo__c, SIREC__SIREC_fld_comentarios__c, 
                            SIREC__SIREC_fld_fechaContacto__c , SIR_accionEnviada__c
                            FROM SIREC__SIREC_obj_acciones__c WHERE Id =: idAccion];
            }      
                   
            resultadoWS = SIR_cls_gestorMotor.enviarAccion(lstAccion[0]);             
         
            for(String lst : resultadoWS){
                if(lst == 'OK'){
                    updateAccionWS(lstAccion[0].Id);
                }
            }
            resultado = resultadoWS;
            return resultado;               
        } 
        return resultado; 
    }    
    
    /*****************************************************************
        Proposito: Update la accion despues de llamar al WS                                                    
        Parameters: List<String>
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/05/2022     	  Created   
       
	*****************************************************************/                              
    @AuraEnabled
    public static void updateAccionWS(String idAccion) {
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isUpdateable()){
            try {    
                SIREC__SIREC_obj_acciones__c updateForm = [SELECT id, SIREC__SIREC_fld_estado__c, SIR_accionEnviada__c
               												FROM SIREC__SIREC_obj_acciones__c WHERE Id =: idAccion];    
                updateForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_FINALIZADA;
                updateForm.SIR_accionEnviada__c = true;
                update updateForm;                   
            } catch (Exception e) {
                CBK_log.error(e, 'Error : SIR_LCMP_accionWorkflow - updateAccionWS - ' + e.getTypeName() + ': ' + e.getMessage());                
            }
        }
    }

    /*****************************************************************
    Proposito: Recogemos los valores de la picklist SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_accion__c                                                      
    Parameters: String valor
    Returns: List<SelectOption>                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         06/05/2022     	  Created    
        
    *****************************************************************/
    @AuraEnabled
    public static String getValuePicklistAccion(String valor) {
        String resultado = null;
 
        for (Schema.PicklistEntry f : Schema.sObjectType.SIREC__SIREC_obj_acciones__c.fields.SIREC__SIREC_fld_accion__c.getPicklistValues()){
            if( valor == f.getValue()){ 
                resultado = f.getLabel();  
            }              
        }
        return resultado;
    } 

}