@IsTest
public class CC_SDOC_MCC_Batch_Test {
    @isTest static void test() {     
        
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
        mccTematica.CC_Codigo_Externo__c = 'TE-00000188';
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
        insert plantillaCA;

        CC_MCC_Plantilla__c plantillaCACopia = new CC_MCC_Plantilla__c(
            CC_MCC__c = mccTematica.Id,
            CC_MCC_Plantilla_Name__c = 'Plantilla Test Name CA',
            CC_MCC_Plantilla_DeveloperName__c = 'Plantilla Test DeveloperName',
            CC_Id_SDOC_Plantilla__c = docSDOCsCA.Id
        );
        insert plantillaCACopia;

        // MCC para el caso que no tenga ninguna plantilla S-Doc asignada
        CC_MCC__c mccTematica2 = new CC_MCC__c();
        mccTematica2.Name = 'Ahorro a la vista';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        insert mccTematica2;
        
        mccTematica.CC_Id_SDOC_Plantilla__c = plantillaES.Id;
        update mccTematica;

        Test.startTest();

            CC_SDOC_MCC_Batch obj = new CC_SDOC_MCC_Batch();
            DataBase.executeBatch(obj);       
	
        System.debug('mcc id ' + [SELECT CC_Id_SDOC_Plantilla__c FROM CC_MCC__c WHERE Id = :mccTematica.Id].CC_Id_SDOC_Plantilla__c);
        Test.stopTest();
            // CC_MCC_Plantilla_Asignar.guardar(plantilla);
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
}