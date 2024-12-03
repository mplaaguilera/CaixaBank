@isTest
public with sharing class CC_Grupo_Colaborador_Plantilla_Test {
    @isTest
    public static void obtenerPlantillasTrasladar() {		

        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Colaborador Test 1',
            RecordtypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId(),
            CC_External__c = 'GC-02001'
            
        );
        insert grupo;

        CC_Grupo_Colaborador_Plantilla__c plantilla = new CC_Grupo_Colaborador_Plantilla__c(
            CC_Grupo_Colaborador__c = grupo.Id,
            CC_Plantilla_Name__c = 'Plantilla Test Name',
            CC_Plantilla_DeveloperName__c = 'Plantilla Test DeveloperName',
            CC_Operativa__c = 'Trasladar'
        );
        insert plantilla;

        List<EmailTemplate> plantillas = CC_Grupo_Colaborador_Plantilla.getPlantillas(grupo.Id,'CC_Trasladar');
        System.assert(plantillas.size() > 0);
	}
    @isTest
    public static void obtenerCarpetasOperativa() {

        List<Folder> operativas = CC_Grupo_Colaborador_Plantilla.getOperativas('');
        System.assert(operativas.size() > 0);
	}
    @isTest
    public static void obtenerPlantillasRemitir() {

        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Colaborador Test 2',
            RecordtypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId(),
            CC_External__c = 'GC-02002'
        );
        insert grupo;

        CC_Grupo_Colaborador_Plantilla__c plantilla = new CC_Grupo_Colaborador_Plantilla__c(
            CC_Grupo_Colaborador__c = grupo.Id,
            CC_Plantilla_Name__c = 'Plantilla Test Name',
            CC_Plantilla_DeveloperName__c = 'Plantilla Test DeveloperName',
            CC_Operativa__c = 'Remitir'
        );
        insert plantilla;

        List<EmailTemplate> plantillas = CC_Grupo_Colaborador_Plantilla.getPlantillas(grupo.Id,'CC_Remitir');
        System.assert(plantillas.size() > 0);
    }
    @isTest
    public static void guardarGrupoPlantillaTrasladar() {
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Colaborador Test 3',
            RecordtypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId(),
            CC_External__c = 'GC-02003'
        );
        insert grupo;

        CC_Grupo_Colaborador_Plantilla__c plantilla = new CC_Grupo_Colaborador_Plantilla__c(
            CC_Grupo_Colaborador__c = grupo.Id,
            CC_Plantilla_Name__c = 'Plantilla Test Name',
            CC_Plantilla_DeveloperName__c = 'Plantilla Test DeveloperName',
            CC_Operativa__c = 'Trasladar'
        );

        CC_Grupo_Colaborador_Plantilla.guardar(plantilla);

        List<CC_Grupo_Colaborador_Plantilla__c> plantillas = [SELECT CC_Grupo_Colaborador__c,CC_Plantilla_Name__c,CC_Plantilla_DeveloperName__c FROM CC_Grupo_Colaborador_Plantilla__c];
        System.assertEquals(1, plantillas.size());
        System.assertEquals(plantilla.CC_Grupo_Colaborador__c, plantillas[0].CC_Grupo_Colaborador__c);
        System.assertEquals(plantilla.CC_Plantilla_Name__c, plantillas[0].CC_Plantilla_Name__c);
        System.assertEquals(plantilla.CC_Plantilla_DeveloperName__c, plantillas[0].CC_Plantilla_DeveloperName__c);

    }
    @isTest
    public static void guardarGrupoPlantillaRemitir() {
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Colaborador Test 4',
            RecordtypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId(),
            CC_External__c = 'GC-02004'
        );
        insert grupo;

        CC_Grupo_Colaborador_Plantilla__c plantilla = new CC_Grupo_Colaborador_Plantilla__c(
            CC_Grupo_Colaborador__c = grupo.Id,
            CC_Plantilla_Name__c = 'Plantilla Test Name',
            CC_Plantilla_DeveloperName__c = 'Plantilla Test DeveloperName',
            CC_Operativa__c = 'Remitir'
        );

        CC_Grupo_Colaborador_Plantilla.guardar(plantilla);

        List<CC_Grupo_Colaborador_Plantilla__c> plantillas = [SELECT CC_Grupo_Colaborador__c,CC_Plantilla_Name__c,CC_Plantilla_DeveloperName__c FROM CC_Grupo_Colaborador_Plantilla__c];
        System.assertEquals(1, plantillas.size());
        System.assertEquals(plantilla.CC_Grupo_Colaborador__c, plantillas[0].CC_Grupo_Colaborador__c);
        System.assertEquals(plantilla.CC_Plantilla_Name__c, plantillas[0].CC_Plantilla_Name__c);
        System.assertEquals(plantilla.CC_Plantilla_DeveloperName__c, plantillas[0].CC_Plantilla_DeveloperName__c);

    }
}