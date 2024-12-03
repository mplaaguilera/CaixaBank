/*
* @description: SAC_FormulariosGGHFraude to show formularios in reclamación
* @test: SAC_FormulariosGGHFraudeTest
* @author: iria.alvarez.novoa@ibm.com
* @date: october 2024
*/
public with sharing class SAC_FormulariosGGHFraude {
    
	private static String varYes = 'Sí';
    private static String varNo = 'No';
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPEFORMGGH = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SAC_Formulario_GGH').getRecordTypeId();
    private static final Id RECTYPEFORMFRAUDE = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SAC_Formulario_Fraude').getRecordTypeId();

    /* @description: FormularioWrapper */
    public class FormularioWrapper {
        @AuraEnabled public Case reclamacion {get; set; }
        @AuraEnabled public SPV_Formulario__c formulario { get; set; }
        @AuraEnabled public List<Case> pretensiones { get; set; }
        @AuraEnabled public List<FechasWrapper> fechas { get; set; }
    }
    
    /* @description: FechasWrapper */
    public class FechasWrapper {
        @AuraEnabled public string fecha { get; set; }
        @AuraEnabled public string importe { get; set; }
        @AuraEnabled public string producto { get; set; }
    }
    
    /* @description: method that gets SPV_Formulario__c records information 
     * @param recId: id reclamación
	 */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<FormularioWrapper>> getFormulariosByCaseId(Id recId) {
        Map<String, List<FormularioWrapper>> formulariosByRecordType = new Map<String, List<FormularioWrapper>>();
        Map<Id, List<Case>> mapPretensiones = new Map<Id, List<Case>>();
        Case reclamacion = [SELECT Id, SAC_TipoDeDocumento__c, CC_Numero_Documento__c, SAC_Tipo_Doc_Rep_Legal__c, SAC_NumeroDelDocumento__c, SAC_NombreRepresentante__c, CC_Importe_Reclamado__c, CC_SuppliedAmbito__c,
                            SuppliedName, CC_SuppliedApellido1__c, CC_SuppliedApellido2__c, SuppliedEmail, SuppliedPhone, CC_SuppliedOficina__c, CC_SuppliedMotivo__c, CC_SuppliedProducto__c, Description 
                            FROM Case WHERE Id =: recId LIMIT 1];
        List<SPV_Formulario__c> formularioList = [SELECT Id, RecordTypeId, RecordType.DeveloperName, SPV_Caso__c, SAC_Fechas__c, SAC_Provincia__c, SAC_Representante_Legal__c, SAC_Tipo_Documento__c FROM SPV_Formulario__c WHERE SPV_Caso__c =: recId];
        for(Case pretension: [SELECT Id, CaseNumber, Subject, SAC_ImpReclamadoGestoria__c, SAC_ImpReclamadoNotaria__c, SAC_ImpReclamadoRegistros__c, SAC_Otros_gastos__c, CC_Importe_Reclamado__c, SAC_Reclamacion__c, SAC_Prestamo_seleccionado__c 
                              FROM Case 
                              WHERE RecordTypeId =: RECTYPEPRETENSION 
                              AND SAC_Reclamacion__c =: reclamacion.Id]){
            if(!mapPretensiones.containsKey(pretension.SAC_Reclamacion__c)){
                List<Case> pretensionList = new List<Case>();
                pretensionList.add(pretension);
                mapPretensiones.put(pretension.SAC_Reclamacion__c, pretensionList);
            }else{
                List<Case> pretensionList = mapPretensiones.get(pretension.SAC_Reclamacion__c);
                pretensionList.add(pretension);
                mapPretensiones.put(pretension.SAC_Reclamacion__c, pretensionList);
            }
        }
        for(SPV_Formulario__c formulario: formularioList){
            FormularioWrapper wrapper = new FormularioWrapper();
            wrapper.reclamacion = reclamacion;
            // Formularios
            wrapper.formulario = formulario;
            // Pretensiones
            if(formulario.RecordTypeId == RECTYPEFORMGGH && mapPretensiones.containsKey(reclamacion.Id)){
                wrapper.pretensiones = mapPretensiones.get(reclamacion.Id);
            }
            // Fechas
            if(formulario.RecordTypeId == RECTYPEFORMFRAUDE){
                List<FechasWrapper> fechasWList = new List<FechasWrapper>();
                String fechas = formulario.SAC_Fechas__c;
                if(fechas != null){
                    List<String> fechasList = fechas.split(':');
                    for(String fecha: fechasList){
                        List<String> valores = fecha.split(';');
                        FechasWrapper fechasW = new FechasWrapper();
                        fechasW.fecha = valores[0];
                        fechasW.importe = valores[1];
                        fechasW.producto = valores[2];
                        fechasWList.add(fechasW);
                    }
                    wrapper.fechas = fechasWList;
                }
            }
            // Map record type and Formularios
            if(!formulariosByRecordType.containsKey(formulario.RecordType.DeveloperName)) {
                formulariosByRecordType.put(formulario.RecordType.DeveloperName, new List<FormularioWrapper>());
            }
            formulariosByRecordType.get(formulario.RecordType.DeveloperName).add(wrapper);
        }
        return formulariosByRecordType;
    }
}