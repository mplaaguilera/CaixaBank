@isTest
public with sharing class CC_MCC_Plantilla_Asignar_Test {
    @isTest
    public static void obtenerCarpetas() {
        List<Folder> carpetas = CC_MCC_Plantilla_Asignar.getCarpetas(null);
        System.assert(carpetas.size() > 0);
    }
    @isTest
    public static void obtenerCarpetasOperativa() {
        List<Folder> carpetas = CC_MCC_Plantilla_Asignar.getCarpetas('CC_Operativas');
        System.assert(carpetas.size() > 0);
    }
    @isTest
    public static void obtenerPlantillas() {
        Folder carpeta = [SELECT Id,DeveloperName FROM Folder LIMIT 1];

        /*EmailTemplate plantilla = new EmailTemplate(
            Name = 'Plantilla Test',
            DeveloperName = 'Plantilla_Test_unique_name',
            TemplateType = 'custom',
            TemplateStyle = 'none',
            Body = '',
            FolderId = '00l6E000000Myc1QAC',
            IsActive = true
        );
        insert plantilla;*/

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;

        List<EmailTemplate> plantillas = CC_MCC_Plantilla_Asignar.getPlantillas(mccTematica.Id,carpeta.DeveloperName);
        System.assertEquals(0, plantillas.size());
    }
    @isTest
    public static void guardarMCCPlantilla() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;

        CC_MCC_Plantilla__c plantilla = new CC_MCC_Plantilla__c(
            CC_MCC__c = mccTematica.Id,
            CC_MCC_Plantilla_Name__c = 'Plantilla Test Name',
            CC_MCC_Plantilla_DeveloperName__c = 'Plantilla Test DeveloperName'
        );
		
        CC_MCC_Plantilla_Asignar.guardar(plantilla);	
        
        List<CC_MCC_Plantilla__c> plantillas = [SELECT CC_MCC__c,CC_MCC_Plantilla_Name__c,CC_MCC_Plantilla_DeveloperName__c FROM CC_MCC_Plantilla__c];
        System.assertEquals(1, plantillas.size());
        System.assertEquals(plantilla.CC_MCC__c, plantillas[0].CC_MCC__c);
        System.assertEquals(plantilla.CC_MCC_Plantilla_Name__c, plantillas[0].CC_MCC_Plantilla_Name__c);
        System.assertEquals(plantilla.CC_MCC_Plantilla_DeveloperName__c, plantillas[0].CC_MCC_Plantilla_DeveloperName__c);

    }
    
    @isTest
    public static void guardarMCCPlantillaSDOC() {
        
       //Crear plantilla S-Docs
        SDOC__SDTemplate__c docSDOCsES = generarPlantilla('Plantilla', 'Castellano', 'PDF');
        SDOC__SDTemplate__c docSDOCsCA = generarPlantilla('Plantilla', 'Catalan', 'PDF');

        // MCC y MCC Plantilla
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000651';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;

        CC_MCC_Plantilla__c plantillaES = new CC_MCC_Plantilla__c(
            CC_MCC__c = mccTematica.Id,
            CC_MCC_Plantilla_Name__c = 'Plantilla Test Name ES',
            CC_MCC_Plantilla_DeveloperName__c = 'Plantilla Test DeveloperName',
            CC_Id_SDOC_Plantilla__c = docSDOCsES.Id
        );
        insert plantillaES;

        CC_MCC_Plantilla__c plantillaCA = new CC_MCC_Plantilla__c(
            CC_MCC__c = mccTematica.Id,
            CC_MCC_Plantilla_Name__c = 'Plantilla Test Name CA',
            CC_MCC_Plantilla_DeveloperName__c = 'Plantilla Test DeveloperName',
            CC_Id_SDOC_Plantilla__c = docSDOCsCA.Id
        );       

        CC_MCC_Plantilla_Asignar.guardar(plantillaCA);
        
        System.assert(mccTematica.Id != null, 'Error al insertar el objeto CC_MCC__c');
        System.assert(plantillaES.Id != null, 'Error al insertar la plantilla ES');
        System.assert(plantillaCA.Id != null, 'Error al insertar la plantilla CA');

    }
    
    //Método para crear plantillas
    private static SDOC__SDTemplate__c generarPlantilla(String nombre, String idioma, String formato){
        SDOC__SDTemplate__c documento = new SDOC__SDTemplate__c();
        documento.Name = nombre;	
        documento.SDOC__Language__c = idioma;
        documento.SDOC__Template_Format__c = formato;
        documento.SDOC__Active__c = true;
        insert documento;
        return documento;
    } 
    
    @isTest
    public static void getNegocioTest(){
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.CC_Codigo_Externo__c = 'TEM-000001';
        insert mccTematica;
        
        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'MCC Tematica 2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente (COPS)';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        mccTematica2.OS_Departamento__c = 'UAC';
        insert mccTematica2;
        
        System.assertEquals('', CC_MCC_Plantilla_Asignar.getNegocio(mccTematica.Id));
        System.assertEquals('OS', CC_MCC_Plantilla_Asignar.getNegocio(mccTematica2.Id));

    }
    
    @isTest
    public static void buscarPlantillasSDOCTest(){
        List<SDOC__SDTemplate__c> listaSdocs = CC_MCC_Plantilla_Asignar.buscarPlantillasSDOC('HTML', 'ES');
        System.assertEquals(0, listaSdocs.size(), 'Se esperaba encontrar una única plantilla SDOCS');

    }
}