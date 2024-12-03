/*
* @description: SAC_Ficheros lwc Controller
* @test: SAC_FicheroControllerTest
* @author: iria.alvarez-novoa@ibm.com
* @date: august 2024
*/
public with sharing class SAC_FicheroController {

    /* @description: wrapper */
    public class FicheroWrapper {
        @AuraEnabled public SAC_Reclamacion_Hipotecaria__c fichero { get; set; }
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
        @AuraEnabled public String titularCuentaURL { get; set; }
        @AuraEnabled public String titularPrestamoURL { get; set; }
        @AuraEnabled public String url { get; set; }
        @AuraEnabled public String validation { get; set; }  
    }

    /* @description: method that gets SAC_Reclamacion_Hipotecaria__c records information */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<FicheroWrapper>> getFicherosByAccountId(Id recId) {
        String varYes = 'Sí';
        String varNo = 'No';
        String prestamoRT = 'SAC_Prestamo';
        Map<String, List<FicheroWrapper>> ficherosByRecordType = new Map<String, List<FicheroWrapper>>();
        List<FicheroWrapper> ficherosWrapper = new List<FicheroWrapper>();
        // Get AccountId from Case
        Case reclamacion = [SELECT Id, Account.CC_NumPerso__c, CreatedDate FROM Case WHERE Id = :recId LIMIT 1];
        // Check nulls
        if(reclamacion.AccountId == null) {
            return new Map<String, List<FicheroWrapper>>();
        }
        // Get Fichero records related to Account
        List<SAC_Reclamacion_Hipotecaria__c> ficheroList =  [SELECT Id, Name, RecordType.Name, RecordType.DeveloperName, CreatedDate,
                                                             SAC_Baja_Persona__c, SAC_CNAE__c, SAC_Centro_gestor__c, SAC_Codigo_CNAE__c, SAC_Codigo_Contrato__c, SAC_Codigo_Contrato_Origen__c, SAC_Codigo_Contrato_TF7__c, 
                                                             SAC_Codigo_Entidad_Origen_Migracion__c, SAC_Codigo_Finalidad_Prestamo__c, SAC_Codigo_Garantia_Principal__c, SAC_Codigo_Linea_Credito__c, SAC_Codigo_Pais_Titular__c, 
                                                             SAC_Codigo_Provincia_titular__c, SAC_Codigo_Tipo_Convenio__c, SAC_Codigo_Tipo_Garantia__c, SAC_Codigo_Tipo_Relacion__c, SAC_Codigo_Tipo_documento_titular__c, 
                                                             SAC_Codigo_Vigencia_Prestamo__c, SAC_Codigo_centro_gestor__c, SAC_Codigo_empresa_gestora__c, SAC_Cuenta_Actual_Activa__c, SAC_Cuenta_Inicial_Activa__c, SAC_Defuncion__c, 
                                                             SAC_Empleado__c, SAC_Entidad_Migrada__c, SAC_Entidad_Origen_Migracion__c, SAC_Fecha_cancelacion_real_prestamo__c, SAC_Fecha_constitucion_prestamo__c, SAC_Fecha_ultima_subrogacion__c, 
                                                             SAC_Finalidad_prestamo_consumidor__c, SAC_Finalidad_Prestamo__c, SAC_Garantia_Principal__c, SAC_Id_Cuenta_Actual__c, SAC_Id_Cuenta_Inicial__c, SAC_Id_Cuenta_TF7__c, 
                                                             SAC_Id_persona_en_Origen__c, SAC_Importe_capital_concedido__c, SAC_Linea_Credito__c, SAC_Localidad_Titular__c, SAC_NIF_titular__c, SAC_Nombre_titular__c, SAC_Operacion_Empleado__c, 
                                                             SAC_Pais_titular__c, SAC_Poblacion_centro_gestor__c, SAC_Prestamo_activo__c, SAC_Provincia_centro_gestor__c, SAC_Provincia_titular__c, SAC_Senales_de_bloqueo_embargo__c, 
                                                             SAC_Tipo_Garantia__c, SAC_Tipo_documento_titular__c, SAC_Tipo_persona__c, SAC_Tipo_relacion__c, SAC_Titular_Cuenta__c, SAC_Titular_Cuenta__r.Name, SAC_Titular_Prestamo__c, 
                                                             SAC_Titular_Prestamo__r.Name, SAC_Ultimo_mes_Datapool__c, SAC_Vigencia_Prestamo__c
                                                             FROM SAC_Reclamacion_Hipotecaria__c 
                                                             WHERE SAC_Id_persona_en_Origen__c = :reclamacion.Account.CC_NumPerso__c
                                                             OR SAC_Titular_Cuenta__r.SAC_Id_persona_en_Origen__c = :reclamacion.Account.CC_NumPerso__c
                                                             ORDER BY RecordType.Name ASC];

        // Map Record Type and Ficheros
        for(SAC_Reclamacion_Hipotecaria__c fichero: ficheroList) {
            String recordTypeName = fichero.RecordType.DeveloperName;
            // Wrapper
            FicheroWrapper wrapper = new FicheroWrapper();
            wrapper.fichero = fichero;
            wrapper.bajaPersona = (fichero.SAC_Baja_Persona__c) ? varYes : varNo;
            wrapper.cuentaActualActiva = (fichero.SAC_Cuenta_Actual_Activa__c) ? varYes : varNo;
            wrapper.cuentaInicialActiva = (fichero.SAC_Cuenta_Inicial_Activa__c) ? varYes : varNo;
            wrapper.defuncion = (fichero.SAC_Defuncion__c) ? varYes : varNo;
            wrapper.empleado = (fichero.SAC_Empleado__c) ? varYes : varNo;
            wrapper.entidadMigrada = (fichero.SAC_Entidad_Migrada__c) ? varYes : varNo;
            wrapper.finalidadConsumidor = (fichero.SAC_Finalidad_prestamo_consumidor__c) ? varYes : varNo;
            wrapper.operacionEmpleado = (fichero.SAC_Operacion_Empleado__c) ? varYes : varNo;
            wrapper.prestamoActivo = (fichero.SAC_Prestamo_activo__c) ? varYes : varNo;
            wrapper.senalBloqueoEmbargo = (fichero.SAC_Senales_de_bloqueo_embargo__c) ? varYes : varNo;
            wrapper.titularCuentaURL = url.getOrgDomainUrl().toExternalForm() + '/' + fichero.SAC_Titular_Cuenta__c;
            wrapper.titularPrestamoURL = url.getOrgDomainUrl().toExternalForm() + '/' + fichero.SAC_Titular_Prestamo__c;
            wrapper.url = url.getOrgDomainUrl().toExternalForm() + '/' + fichero.Id;
            // Check validations
            wrapper.validation = (fichero.RecordType.DeveloperName == prestamoRT) ? checkValidations(fichero, Date.valueOf(reclamacion.CreatedDate)) : null;
            // Map record type and ficheros
            if(!ficherosByRecordType.containsKey(recordTypeName)) {
                ficherosByRecordType.put(recordTypeName, new List<FicheroWrapper>());
            }
            ficherosByRecordType.get(recordTypeName).add(wrapper);
        }
        return ficherosByRecordType;
    }

    /* @description: method that updates Case status when pressing the reject button */
    @AuraEnabled
    public static void rejectReclamacion(Id recId) {
        String rechazadoStatus = 'Rechazado';
        String motivoRechazo = 'Otros';
        // Get Case and update Status
        Case reclamacion = [SELECT Id, Status, SAC_StatusAuxiliar__c, SAC_MotivoRechazo__c FROM Case WHERE Id = :recId LIMIT 1];
        if (reclamacion != null) {
            reclamacion.Status = rechazadoStatus;
            reclamacion.SAC_StatusAuxiliar__c = rechazadoStatus;
            reclamacion.SAC_MotivoRechazo__c = motivoRechazo;
            update reclamacion;
        }
    }
    
    /* @description: method that checks validations (in order) to make the reject button visible */
    public static String checkValidations(SAC_Reclamacion_Hipotecaria__c fichero, Date createdDate) {
        List<String> catProvinces = new List<String>{'Barcelona', 'Tarragona', 'Lleida', 'Girona'};
		List<String> navProvinces = new List<String>{'Navarra'};
        String cnaeValue = 'CNAE 99 PERSONAS FISICAS - CNAE No Standard';
        String noConsumidor = 'No consumidor';
        String empleados = 'Empleados';
        String antigReclamacion = 'Antigüedad Reclamación';
        String prescripcion = 'Prescripción';
        Date navCancelation1 = Date.newInstance(1994, 10, 16);
        Date navCancelation2 = Date.newInstance(1994, 10, 17);
        Date navCancelation3 = Date.newInstance(2019, 10, 16);
        Date navCancelation4 = Date.newInstance(2024, 10, 16);
        Date reclamacionAnterior = Date.newInstance(2019, 10, 16);
        String validation;
        // Criteria "No consumidor"
        if(fichero.SAC_CNAE__c != cnaeValue){
            validation = noConsumidor;
        }
        // Criteria "Empleados"
        else if(fichero.SAC_Operacion_Empleado__c){
            validation = empleados;
        }
        else{
            // Criteria Antigüedad Reclamación and Prescripción
            if(catProvinces.contains(fichero.SAC_Provincia_centro_gestor__c)){
                // Antigüedad Reclamación
                if(reclamacionAnterior.addYears(10) < createdDate){
                    validation = antigReclamacion;
                }
                // Prescripción
                else if(fichero.SAC_Fecha_cancelacion_real_prestamo__c.addYears(10) < createdDate){
                    validation = prescripcion;
                }
            }else if(navProvinces.contains(fichero.SAC_Provincia_centro_gestor__c)){
                // Antigüedad Reclamación
                if((reclamacionAnterior < navCancelation3 && createdDate > navCancelation4) || (reclamacionAnterior > navCancelation3 && reclamacionAnterior.addYears(5) <= createdDate)){
                    validation = antigReclamacion;
                }
                // Prescripción
                else if((fichero.SAC_Fecha_cancelacion_real_prestamo__c < navCancelation1 && fichero.SAC_Fecha_cancelacion_real_prestamo__c.addYears(30) < createdDate) || 
                        (fichero.SAC_Fecha_cancelacion_real_prestamo__c >= navCancelation2 && fichero.SAC_Fecha_cancelacion_real_prestamo__c <= navCancelation3 && createdDate > navCancelation4) ||
                        (fichero.SAC_Fecha_cancelacion_real_prestamo__c > navCancelation3 && fichero.SAC_Fecha_cancelacion_real_prestamo__c.addYears(5) < createdDate)){
                            validation = prescripcion;
                        }
            }else{
                // Antigüedad Reclamación
                if(reclamacionAnterior.addYears(5).addDays(82) < createdDate){
                    validation = antigReclamacion;
                }   
                // Prescripción
                else if(reclamacionAnterior.addYears(5).addDays(82) < createdDate){
                    validation = prescripcion;
                }                
            }
        }
        return validation;
    }
    /* @description: check current status of the reclamación */
    @AuraEnabled(cacheable=true)
    public static String getRecStatus(Id recId) {
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Id = :recId LIMIT 1];
        return reclamacion.Status;
    }
}