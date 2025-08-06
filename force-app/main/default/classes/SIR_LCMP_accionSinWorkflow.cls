/*****************************************************************
 Name:  SIR_LCMP_accionSinWorkflow
 Copyright © 2022  CaixaBank

Proposito:   Clase controladora externa del LWC SIR_LCMP_accionSinWorkflow                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         31/05/2022     	  Created    

*****************************************************************/
public with sharing class SIR_LCMP_accionSinWorkflow {
    
    /*****************************************************************
        Proposito:  Se comprueba que el usuario actual sea el propietario del proceso, sino no puede crear/modificar accion                                                    
        Parameters: String idProceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         31/05/2022     	  Created    
        
	*****************************************************************/
    @AuraEnabled
    public static Id buscarIdsAccion(){
        if(Schema.SObjectType.RecordType.isAccessible()){
            /*List<RecordType> recordIdAcciones = [SELECT id, name FROM RecordType WHERE SobjectType ='SIREC__SIREC_obj_acciones__c' AND (name = 'Acción Amistoso' OR name = 'Acción Preventivo')];
            return recordIdAcciones;*/

            return Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO).getRecordTypeId();
        } 
        return null; 
    }
    
    /*****************************************************************
        Proposito:  Se comprueba que el usuario actual sea el propietario del proceso, sino no puede crear/modificar accion                                                    
        Parameters: String idProceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         31/05/2022     	  Created    
        
	*****************************************************************/
    @AuraEnabled
    public static String comprobarPropietarioProceso(String idProceso){
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, OwnerId FROM SIREC__SIREC_obj_proceso__c WHERE id=:idProceso LIMIT 1];
            if(proceso.OwnerId == UserInfo.getUserId()){
                return 'OK';
            }else{
                return 'No puede crear una acción si no es propietario del proceso.';
            }
        } 
        return ''; 
    }
    
    /*****************************************************************
        Proposito:  Se comprueba que el usuario actual sea el propietario de la accion, sino no puede crear/modificar accion                                                    
        Parameters: String idProceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         31/05/2022     	  Created     
        
	*****************************************************************/
    @AuraEnabled
    public static String comprobarPropietarioAccion(String idAccion){        
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){
            SIREC__SIREC_obj_acciones__c accion = [SELECT Id, SIREC__SIREC_fld_proceso__r.OwnerId FROM SIREC__SIREC_obj_acciones__c WHERE id=:idAccion LIMIT 1];
            if(accion.SIREC__SIREC_fld_proceso__r.OwnerId == UserInfo.getUserId()){
                return 'OK';
            }else{
                return 'No puede crear o modificar una acción de la que no es propietario.';
            }
        } 
        return ''; 
    }
    
    /*****************************************************************
        Proposito:  Se comprueba que el usuario actual sea el propietario de la accion, sino no puede crear/modificar accion                                                    
        Parameters: String idProceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         31/05/2022     	  Created     
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static String comprobarPropietarioAccionReenvio(String idAccion){        
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){
            SIREC__SIREC_obj_acciones__c accion = [SELECT Id, SIREC__SIREC_fld_proceso__r.OwnerId FROM SIREC__SIREC_obj_acciones__c WHERE id=:idAccion LIMIT 1];            
            if(accion.SIREC__SIREC_fld_proceso__r.OwnerId == UserInfo.getUserId()){
                return 'OK';
            }else{
                return 'No puede crear o modificar una acción de la que no es propietario.';
            }
        } 
        return ''; 
    }
    /*****************************************************************
        Proposito: Realizamos query para obtener el nombre del proceso.                                                      
        Parameters: Id proceso
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                     Atmira         31/05/2022     	  Created    
        
	*****************************************************************/                              
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProceso(String idProceso) {         
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            List<SIREC__SIREC_obj_proceso__c> proceso = [SELECT Name, SIREC__SIREC_fld_fechaInicio__c, SIR_fechaCarga__c, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_estrategia__c, SIREC__SIREC_fld_descEstrategiaCatalogo__c, recordTypeId FROM SIREC__SIREC_obj_proceso__c WHERE id=:idProceso];
            return proceso;
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
        1.0                     Atmira         31/05/2022     	  Created    
        
	*****************************************************************/                              
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_acciones__c> getAccion(String idAccion) {  
      if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){
            List<SIREC__SIREC_obj_acciones__c> accion = [SELECT Id, SIREC__SIREC_fld_responsable__c,SIREC__SIREC_fld_proceso__c,SIREC__SIREC_fld_proceso__r.RecordTypeId,
                                                        SIREC__SIREC_fld_fechaContacto__c, SIREC__SIREC_fld_tipo__c, SIREC__SIREC_fld_accion__c,
                                                        SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_comentarios__c,
                                                        SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_proceso__r.Name,
                                                        SIR_FechaCompromisoPago__c, SIREC__SIREC_fld_proceso__r.SIR_fechaCarga__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaInicio__c
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
        1.0                             Atmira         31/05/2022     	  Created     
        
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
        Proposito: Metodo para recoger correctamente las picklist                                                     
        Parameters: 
        Returns:                                                         
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         31/05/2022     	  Created     
        
	*****************************************************************/
    public class SelectOption {
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
        
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String value { get;set; }     
    }
    
    /*****************************************************************
    Proposito: Recogemos los valores de la picklist SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_accion__c                                                      
    Parameters: String valor
    Returns: List<SelectOption>                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         31/05/2022     	  Created    
        
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
    
    /*****************************************************************
        Proposito: Insertamos la accion                                                      
        Parameters: List<String>
        Returns: String                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         31/05/2022     	  Created     
        
	*****************************************************************/  
    @AuraEnabled
    public static String insertAccion(List<String> data) { 
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isCreateable() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){
            try {             
                SIREC__SIREC_obj_acciones__c insertForm = new SIREC__SIREC_obj_acciones__c();  
                Boolean resultadoInformado = false;      
                insertForm.SIREC__SIREC_fld_fechaContacto__c = date.valueof(data[0]);
                insertForm.SIREC__SIREC_fld_tipo__c = data[1];
                insertForm.SIREC__SIREC_fld_accion__c = data[2];    
                insertForm.SIR_valorAccion__c = getValuePicklistAccion(data[2]);           
                Integer countAcciones = [SELECT Id FROM SIREC__SIREC_obj_acciones__c WHERE SIREC__SIREC_fld_proceso__c =: data[7] AND SIREC__SIREC_fld_resultado__c = : SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO].size();            
                if (data[3] == SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO && countAcciones >=2){
                    insertForm.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_ILOCALIZADO;
               }else{
                    insertForm.SIREC__SIREC_fld_resultado__c = data[3];
                }
                if(String.isblank(insertForm.SIREC__SIREC_fld_resultado__c)){
                    insertForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_EN_CURSO;
                }else{
                    insertForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_PENDIENTE_SINCRONIZACION;
                    resultadoInformado = true;
                }
                insertForm.SIREC__SIREC_fld_comentarios__c = data[4];
                insertForm.SIREC__SIREC_fld_responsable__c = data[5];        
                insertForm.SIREC__SIREC_fld_interviniente__c = data[6];
                insertForm.SIREC__SIREC_fld_persona__c = data[6];
                insertForm.SIREC__SIREC_fld_proceso__c = data[7];
                insertForm.SIR_CodigoEstrategia__c = data[8];                
                insertForm.SIR_estrategia__c = data[10];    

                if(data[9] != null && data[9] != ''){
                    insertForm.SIR_FechaCompromisoPago__c = date.valueof(data[9]);
                }     
                insertForm.RecordTypeId = data[11];          	
                insert insertForm;	
                if(insertForm.SIR_FechaCompromisoPago__c != null){	
                    SIREC__SIREC_obj_proceso__c proceso = [SELECT id, SIR_FechaCompromisoPago__c FROM SIREC__SIREC_obj_proceso__c WHERE id =: insertForm.SIREC__SIREC_fld_proceso__c LIMIT 1];	
                    proceso.SIR_FechaCompromisoPago__c = insertForm.SIR_FechaCompromisoPago__c;	
                    update proceso;	
                }
                String resultado = 'OK-' + resultadoInformado + '@' + insertForm.Id;
                return resultado;                   
            } catch (Exception e) {
                CBK_log.error(e, 'Error : SIR_LCMP_accionSinWorkflow - ' + e.getTypeName() + ': ' + e.getMessage());
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
        1.0                             Atmira         31/05/2022     	  Created     
        <
	*****************************************************************/                             
    @AuraEnabled
    public static String updateAccion(List<String> data, String idAccion) {
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isUpdateable() && Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){
            try {    
                SIREC__SIREC_obj_acciones__c updateForm = [SELECT id, SIREC__SIREC_fld_fechaContacto__c, SIREC__SIREC_fld_tipo__c, SIR_FechaCompromisoPago__c,
                                                            SIREC__SIREC_fld_accion__c, SIREC__SIREC_fld_resultado__c, SIREC__SIREC_fld_estado__c, SIREC__SIREC_fld_comentarios__c,
                                                            SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_responsable__c, SIREC__SIREC_fld_persona__c, SIREC__SIREC_fld_proceso__c
                                                            FROM SIREC__SIREC_obj_acciones__c WHERE Id =: idAccion AND  SIREC__SIREC_fld_resultado__c <> : SIR_Constantes.ACCION_RESULTADO_ILOCALIZADO];         
                Boolean resultadoInformado = false;      
                updateForm.SIREC__SIREC_fld_fechaContacto__c = date.valueof(data[0]);
                updateForm.SIREC__SIREC_fld_tipo__c = data[1];
                updateForm.SIREC__SIREC_fld_accion__c = data[2];
                Integer countAcciones = [SELECT Id FROM SIREC__SIREC_obj_acciones__c WHERE SIREC__SIREC_fld_proceso__c =: data[7] AND SIREC__SIREC_fld_resultado__c = : SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO].size();
                if (data[3] == SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO && countAcciones >=2){
                    updateForm.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_ILOCALIZADO;
               }else{
                    updateForm.SIREC__SIREC_fld_resultado__c = data[3];
                }
                if(String.isblank(updateForm.SIREC__SIREC_fld_resultado__c)){
                    updateForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_EN_CURSO;
                }else{
                    updateForm.SIREC__SIREC_fld_estado__c = SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_PENDIENTE_SINCRONIZACION;                    
                    resultadoInformado = true;
                }                
                updateForm.SIREC__SIREC_fld_comentarios__c = data[4];
                updateForm.SIREC__SIREC_fld_responsable__c = data[5];        
                updateForm.SIREC__SIREC_fld_interviniente__c = data[6];
                updateForm.SIREC__SIREC_fld_persona__c = data[6];             
                updateForm.SIR_valorAccion__c  = getValuePicklistAccion(data[2]); 
                if(data[9] != null && data[9] != ''){
                    updateForm.SIR_FechaCompromisoPago__c = date.valueof(data[9]);
                }
                update updateForm;	
                if(updateForm.SIR_FechaCompromisoPago__c != null){	
                    SIREC__SIREC_obj_proceso__c proceso = [SELECT id, SIR_FechaCompromisoPago__c FROM SIREC__SIREC_obj_proceso__c WHERE id =: updateForm.SIREC__SIREC_fld_proceso__c LIMIT 1];	
                    proceso.SIR_FechaCompromisoPago__c = updateForm.SIR_FechaCompromisoPago__c;	
                    update proceso;	
                }          
                String resultado = 'OK-' + resultadoInformado;
                return resultado;                   
            } catch (Exception e) {
                CBK_log.error(e, 'Error : SIR_LCMP_accionSinWorkflow - ' + e.getTypeName() + ': ' + e.getMessage());
                return 'Ha ocurrido un error: ' + e.getMessage();
            }
        }
        return '';
    }  
    
    /*****************************************************************
        Proposito: Enviamos la Accion a Sirec                                                   
        Parameters: String
        Returns: String []                                                      
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                     Atmira         31/05/2021     	  Created    
        
	*****************************************************************/                              
    @AuraEnabled
    public static String[] enviarAccion(String idAccion) {
        String[] resultado = new String[]{''}; 
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){                 
            // Llamar al WS de Enviar Accion            
            String[] resultadoWS;           
            resultadoWS = SIR_SendNewAction_WS.sendAction(idAccion);
            if(resultadoWS[0] == 'OK'){
            	updateAccionWS(idAccion);
            } 
            return resultadoWS;               
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
        1.0                     Atmira         31/05/2021     	  Created    
        
	*****************************************************************/                              
    @AuraEnabled
    public static void updateAccionWS(String idAccion) {
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isUpdateable()){
            try {    
                SIREC__SIREC_obj_acciones__c updateForm = [SELECT id, SIREC__SIREC_fld_estado__c, SIR_accionEnviada__c
               												FROM SIREC__SIREC_obj_acciones__c WHERE Id =: idAccion];    
                updateForm.SIREC__SIREC_fld_estado__c = 'Finalizada';
                updateForm.SIR_accionEnviada__c = true;
                update updateForm;                   
            } catch (Exception e) {
                CBK_log.error(e, 'Error : SIR_LCMP_accionSinWorkflow - ' + e.getTypeName() + ': ' + e.getMessage());                
            }
        }
    }
}