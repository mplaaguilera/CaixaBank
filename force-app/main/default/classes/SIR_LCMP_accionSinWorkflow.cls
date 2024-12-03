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
    public static Id buscarIdsProceso(){
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            RecordType proceso = [SELECT id FROM RecordType WHERE SobjectType ='SIREC__SIREC_obj_proceso__c' AND name = 'PRESOL' LIMIT 1];
            Id procesoPresol = proceso.Id; 
            return procesoPresol      ;
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
    public static List<RecordType> buscarIdsAccion(){
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            List<RecordType> recordIdAcciones = [SELECT id, name FROM RecordType WHERE SobjectType ='SIREC__SIREC_obj_acciones__c' AND (name = 'Acción Amistoso' OR name = 'Acción Preventivo')];
            return recordIdAcciones;
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
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
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
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isAccessible()){
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
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isAccessible()){
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
    public static List<SIREC__SIREC_obj_proceso__c> getProceso(String idProceso, Object accionesMetadata) {         
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            List<SIREC__SIREC_obj_proceso__c> proceso = [SELECT Name, SIREC__SIREC_fld_fechaInicio__c, SIR_fechaCarga__c, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_estrategia__c, recordTypeId FROM SIREC__SIREC_obj_proceso__c WHERE id=:idProceso];
            return proceso;
        }
        return null;
    } 
    /*@AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_proceso__c> getProceso(String idProceso) {         
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){
            List<SIREC__SIREC_obj_proceso__c> proceso = [SELECT Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_estrategia__c, recordTypeId FROM SIREC__SIREC_obj_proceso__c WHERE id=:idProceso];
            return proceso;
        }
        return null;
    } */
    
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
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isAccessible()){
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
        if(SIREC__SIREC_obj_personaAsociada__c.SObjectType.getDescribe().isAccessible()){
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
        Schema.DescribeFieldResult fieldResult = SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_accion__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();       
        
        for (Schema.PicklistEntry f: ple) {   
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
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isCreateable() && SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isUpdateable()){
            try {  
                Schema.DescribeFieldResult field = SIREC__SIREC_obj_proceso__c.SIREC__SIREC_fld_estrategia__c.getDescribe();              
                SIREC__SIREC_obj_acciones__c insertForm = new SIREC__SIREC_obj_acciones__c();  
                Boolean resultadoInformado = false;      
                insertForm.SIREC__SIREC_fld_fechaContacto__c = date.valueof(data[0]);
                insertForm.SIREC__SIREC_fld_tipo__c = data[1];
                insertForm.SIREC__SIREC_fld_accion__c = data[2];               
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
                
                for (Schema.PicklistEntry f : field.getPicklistValues()){
                    if(f.getValue() == data[8]){
                        insertForm.SIR_estrategia__c= f.getLabel();
                        break;
                    }
                }
                insertForm.SIR_valorAccion__c = getValuePicklistAccion(data[2]);
                if(data[9] != null && data[9] != ''){
                    insertForm.SIR_FechaCompromisoPago__c = date.valueof(data[9]);
                }     
                insertForm.RecordTypeId = data[10];          	
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
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isUpdateable() && SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isUpdateable()){
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
        Proposito: Saber la depencia de la picklist de acciones                                                   
        Parameters: No
        Returns: Map<String, List<String>>                                                    
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US244045         Atmira         02/08/2021     	  Created    
        
	*****************************************************************/
   /* public static Map<String, List<String>> getDependentPicklistValues(String nombreCampo) {
        Schema.DescribeFieldResult depend = SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_accion__c.getDescribe();
        if(nombreCampo == 'Accion'){
           depend = SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_accion__c.getDescribe();
        } else if(nombreCampo == 'Resultado'){
            depend = SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_resultado__c.getDescribe();
        }
        
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0){
                        continue;
                    }
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getValue());
                }
            }
        }
        return dependentPicklistValues;
    }*/
       
    
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
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isAccessible()){                 
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
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isUpdateable()){
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