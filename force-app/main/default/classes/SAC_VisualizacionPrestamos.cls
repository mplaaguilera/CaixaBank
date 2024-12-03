/*
* @description: SAC_VisualizacionPrestamos lwc Controller
* @test: SAC_VisualizacionPrestamosTest
* @author: iria.alvarez.novoa@ibm.com
* @date: august 2024
*/
public with sharing class SAC_VisualizacionPrestamos {
    
    private static String prestamoRT = 'SAC_Prestamo';
    private static String varYes = 'Sí';
    private static String varNo = 'No';
    
    /* @description: wrapper */
    public class PrestamoWrapper {
        @AuraEnabled public SAC_Prestamo__c prestamo { get; set; }
        @AuraEnabled public String bajaPersona { get; set; }
        @AuraEnabled public String cuentaActualActiva { get; set; }
        @AuraEnabled public String cuentaInicialActiva { get; set; }
        @AuraEnabled public String defuncion { get; set; }
        @AuraEnabled public String empleado { get; set; }
        @AuraEnabled public String entidadMigrada { get; set; }
        @AuraEnabled public String finalidadConsumidor { get; set; }
        @AuraEnabled public String operacionEmpleado { get; set; }
        @AuraEnabled public String prestamoActivo { get; set; }
        @AuraEnabled public String senalBloqueoEmbargo { get; set; }
        @AuraEnabled public String url { get; set; }
        @AuraEnabled public String validation { get; set; }  
    }
    
    /* @description: method that gets SAC_Prestamo__c records information 
     * @param recId: id reclamación
	 */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<PrestamoWrapper>> getPrestamosByAccountId(Id recId) {
        Map<String, List<PrestamoWrapper>> prestamosByRecordType = new Map<String, List<PrestamoWrapper>>();
        List<SAC_Prestamo__c> allPrestamoList = new List<SAC_Prestamo__c>();
        List<Id> prestamosIds = new List<Id>();
        List<String> reclamantesNumPerso = new List<String>();
        // Get AccountId from Case
        Case reclamacion = [SELECT Id, Account.CC_NumPerso__c, SAC_FechaRecepcion__c, AccountId, CC_MCC_Tematica__r.Name, 
                            CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, SEG_Detalle__r.Name 
                            FROM Case WHERE Id = :recId LIMIT 1];
        // Get Reclamantes 
        for(SAC_CaseReclamante__c reclamante : SAC_LCMP_PrestamoGlobal.getReclamantes(reclamacion.Id)){
            if(reclamante.SAC_Account__r.CC_NumPerso__c != null){
                reclamantesNumPerso.add(reclamante.SAC_Account__r.CC_NumPerso__c);
            }
        }
        // Check nulls
        if(reclamacion.AccountId == null) {
            return new Map<String, List<PrestamoWrapper>>();
        }
        // Get Titulares records related to Account
        List<SAC_Prestamo__c> titularesList =  [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, CreatedDate,
                                               SAC_Baja_Persona__c, SAC_CNAE__c, SAC_Centro_gestor__c, SAC_Codigo_CNAE__c, SAC_Codigo_Contrato__c, SAC_Codigo_Contrato_Origen__c, SAC_Codigo_Contrato_TF7__c, 
                                               SAC_Codigo_Entidad_Origen_Migracion__c, SAC_Codigo_Finalidad_Prestamo__c, SAC_Codigo_Garantia_Principal__c, SAC_Codigo_Linea_Credito__c, SAC_Codigo_Pais_Titular__c, 
                                               SAC_Codigo_Provincia_titular__c, SAC_Codigo_Tipo_Convenio__c, SAC_Codigo_Tipo_Garantia__c, SAC_Codigo_Tipo_Relacion__c, SAC_Codigo_Tipo_documento_titular__c, 
                                               SAC_Codigo_Vigencia_Prestamo__c, SAC_Codigo_centro_gestor__c, SAC_Codigo_empresa_gestora__c, SAC_Cuenta_Actual_Activa__c, SAC_Cuenta_Inicial_Activa__c, SAC_Defuncion__c, 
                                               SAC_Empleado__c, SAC_Entidad_Migrada__c, SAC_Entidad_Origen_Migracion__c, SAC_Fecha_cancelacion_real_prestamo__c, SAC_Fecha_constitucion_prestamo__c, SAC_Fecha_ultima_subrogacion__c, 
                                               SAC_Finalidad_prestamo_consumidor__c, SAC_Finalidad_Prestamo__c, SAC_Garantia_Principal__c, SAC_Id_Cuenta_Actual__c, SAC_Id_Cuenta_Inicial__c, SAC_Id_Cuenta_TF7__c, 
                                               SAC_Id_persona_en_Origen__c, SAC_Importe_capital_concedido__c, SAC_Linea_Credito__c, SAC_Localidad_Titular__c, SAC_NIF_titular__c, SAC_Nombre_titular__c, SAC_Operacion_Empleado__c, 
                                               SAC_Pais_titular__c, SAC_Poblacion_centro_gestor__c, SAC_Prestamo_activo__c, SAC_Provincia_centro_gestor__c, SAC_Provincia_titular__c, SAC_Senales_de_bloqueo_embargo__c, 
                                               SAC_Tipo_Garantia__c, SAC_Tipo_documento_titular__c, SAC_Tipo_persona__c, SAC_Tipo_relacion__c, SAC_Ultimo_mes_Datapool__c, SAC_Vigencia_Prestamo__c
                                               FROM SAC_Prestamo__c 
                                               WHERE SAC_Id_persona_en_Origen__c IN: reclamantesNumPerso
                                               ORDER BY RecordType.Name ASC];

        // Get Préstamo/Titulares 
        List<SAC_Prestamo_Titular__c> prestamoTitular = [SELECT Id, SAC_Prestamo__c, SAC_Titular__c FROM SAC_Prestamo_Titular__c WHERE SAC_Titular__c IN: titularesList];
        for(SAC_Prestamo_Titular__c pt: prestamoTitular){
            prestamosIds.add(pt.SAC_Prestamo__c);
        }
        // Get Préstamo records related to Account
        List<SAC_Prestamo__c> prestamoList =  [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, CreatedDate,
                                               SAC_Baja_Persona__c, SAC_CNAE__c, SAC_Centro_gestor__c, SAC_Codigo_CNAE__c, SAC_Codigo_Contrato__c, SAC_Codigo_Contrato_Origen__c, SAC_Codigo_Contrato_TF7__c, 
                                               SAC_Codigo_Entidad_Origen_Migracion__c, SAC_Codigo_Finalidad_Prestamo__c, SAC_Codigo_Garantia_Principal__c, SAC_Codigo_Linea_Credito__c, SAC_Codigo_Pais_Titular__c, 
                                               SAC_Codigo_Provincia_titular__c, SAC_Codigo_Tipo_Convenio__c, SAC_Codigo_Tipo_Garantia__c, SAC_Codigo_Tipo_Relacion__c, SAC_Codigo_Tipo_documento_titular__c, 
                                               SAC_Codigo_Vigencia_Prestamo__c, SAC_Codigo_centro_gestor__c, SAC_Codigo_empresa_gestora__c, SAC_Cuenta_Actual_Activa__c, SAC_Cuenta_Inicial_Activa__c, SAC_Defuncion__c, 
                                               SAC_Empleado__c, SAC_Entidad_Migrada__c, SAC_Entidad_Origen_Migracion__c, SAC_Fecha_cancelacion_real_prestamo__c, SAC_Fecha_constitucion_prestamo__c, SAC_Fecha_ultima_subrogacion__c, 
                                               SAC_Finalidad_prestamo_consumidor__c, SAC_Finalidad_Prestamo__c, SAC_Garantia_Principal__c, SAC_Id_Cuenta_Actual__c, SAC_Id_Cuenta_Inicial__c, SAC_Id_Cuenta_TF7__c, 
                                               SAC_Id_persona_en_Origen__c, SAC_Importe_capital_concedido__c, SAC_Linea_Credito__c, SAC_Localidad_Titular__c, SAC_NIF_titular__c, SAC_Nombre_titular__c, SAC_Operacion_Empleado__c, 
                                               SAC_Pais_titular__c, SAC_Poblacion_centro_gestor__c, SAC_Prestamo_activo__c, SAC_Provincia_centro_gestor__c, SAC_Provincia_titular__c, SAC_Senales_de_bloqueo_embargo__c, 
                                               SAC_Tipo_Garantia__c, SAC_Tipo_documento_titular__c, SAC_Tipo_persona__c, SAC_Tipo_relacion__c, SAC_Ultimo_mes_Datapool__c, SAC_Vigencia_Prestamo__c
                                               FROM SAC_Prestamo__c 
                                               WHERE Id IN: prestamosIds
                                               ORDER BY RecordType.Name ASC];
        allPrestamoList.addAll(prestamoList);
        allPrestamoList.addAll(titularesList);
        //Check MCCs
        Boolean appliesMCC = checkMCCs(reclamacion);
        // Map Record Type and Préstamos
        for(SAC_Prestamo__c prestamo: allPrestamoList) {
            String recordTypeName = prestamo.RecordType.DeveloperName;
            // Wrapper
            PrestamoWrapper wrapper = new PrestamoWrapper();
            wrapper.prestamo = prestamo;
            wrapper.bajaPersona = (prestamo.SAC_Baja_Persona__c) ? varYes : varNo;
            wrapper.cuentaActualActiva = (prestamo.SAC_Cuenta_Actual_Activa__c) ? varYes : varNo;
            wrapper.cuentaInicialActiva = (prestamo.SAC_Cuenta_Inicial_Activa__c) ? varYes : varNo;
            wrapper.defuncion = (prestamo.SAC_Defuncion__c) ? varYes : varNo;
            wrapper.empleado = (prestamo.SAC_Empleado__c) ? varYes : varNo;
            wrapper.entidadMigrada = (prestamo.SAC_Entidad_Migrada__c) ? varYes : varNo;
            wrapper.finalidadConsumidor = (prestamo.SAC_Finalidad_prestamo_consumidor__c) ? varYes : varNo;
            wrapper.operacionEmpleado = (prestamo.SAC_Operacion_Empleado__c) ? varYes : varNo;
            wrapper.prestamoActivo = (prestamo.SAC_Prestamo_activo__c) ? varYes : varNo;
            wrapper.senalBloqueoEmbargo = (prestamo.SAC_Senales_de_bloqueo_embargo__c) ? varYes : varNo;
            wrapper.url = url.getOrgDomainUrl().toExternalForm() + '/' + prestamo.Id;
            // Check validations
            if(appliesMCC){
                wrapper.validation = (prestamo.RecordType.DeveloperName == prestamoRT) ? SAC_LCMP_PrestamoGlobal.checkValidations(prestamo, Date.valueOf(reclamacion.SAC_FechaRecepcion__c), reclamacion.Id, reclamacion.AccountId) : null;
            }else{
                wrapper.validation = null;
            }
            // Map record type and Préstamos
            if(!prestamosByRecordType.containsKey(recordTypeName)) {
                prestamosByRecordType.put(recordTypeName, new List<PrestamoWrapper>());
            }
            prestamosByRecordType.get(recordTypeName).add(wrapper);
        }
        return prestamosByRecordType;
    }
    
    /* @description: method that checks MCCs
     * @param reclamacion: reclamación record
	 */
    public static Boolean checkMCCs(Case reclamacion){
        Boolean applies = false;
        // Get specific MCCs
        List<SAC_MCC_Prestamos__mdt> mccsToCheckList = [SELECT Id, SAC_Tematica__c, SAC_ProductoServicio__c, SAC_Motivo__c, SAC_Detalle__c FROM SAC_MCC_Prestamos__mdt];
        // Check if reclamación matches specific MCCs
        for(SAC_MCC_Prestamos__mdt mcc: mccsToCheckList){
            if(mcc.SAC_Tematica__c == reclamacion.CC_MCC_Tematica__r.Name && mcc.SAC_ProductoServicio__c == reclamacion.CC_MCC_ProdServ__r.Name 
               && mcc.SAC_Motivo__c == reclamacion.CC_MCC_Motivo__r.Name && mcc.SAC_Detalle__c == reclamacion.SEG_Detalle__r.Name){
                   applies = true;
               }
        }
        return applies;
    }  
}