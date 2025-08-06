@isTest
public class CC_Marcas_Case_Test {
    
    @isTest
    static void caracteristicasCops() {
        Datetime myDateNow = Datetime.valueOf(System.now());
        Datetime newDate = myDateNow.addHours(1);
        Id caracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
            
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.Name = 'BREXIT';
        caracteristica.CC_Descripcion__c = 'Marca para el Brexit';
        caracteristica.RecordTypeId = caracteristicaRecordTypeId;
        caracteristica.CC_Fecha_vigencia_inicio__c = myDateNow;
        caracteristica.CC_Fecha_vigencia_fin__c = newDate;
        caracteristica.OS_Negocio__c = 'COPS';
           
        insert caracteristica;    
        
		Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Caso de prueba';
        caso1.Status = 'Activo';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso1.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso1;
        
        
        
        Test.startTest();
        List<CC_Caracteristica__c> listaCaracteristica = CC_Marcas_Case.caracteristicas(caso1.Id);
        Test.stopTest();
        System.assert(listaCaracteristica.size() > 0);
    }
    
    @isTest
    static void caracteristicasContact() {
        Datetime myDateNow = Datetime.valueOf(System.now());
        Datetime newDate = myDateNow.addHours(1);
        Id caracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
            
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.Name = 'BREXIT';
        caracteristica.CC_Descripcion__c = 'Marca para el Brexit';
        caracteristica.RecordTypeId = caracteristicaRecordTypeId;
        caracteristica.CC_Fecha_vigencia_inicio__c = myDateNow;
        caracteristica.CC_Fecha_vigencia_fin__c = newDate;
        caracteristica.OS_Negocio__c = 'CC';
           
        insert caracteristica;    
        
		Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Caso de prueba';
        caso1.Status = 'Activo';
        caso1.Origin = 'Phone';
        caso1.CC_Canal_Procedencia__c = 'Atención al Cliente';
        caso1.CC_Canal_Resolucion__c = 'Cajeros';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        insert caso1;
        
        
        
        Test.startTest();
        List<CC_Caracteristica__c> listaCaracteristica = CC_Marcas_Case.caracteristicas(caso1.Id);
        Test.stopTest();
        System.assert(listaCaracteristica.size() > 0);
    }

    @isTest
    static void caracteristicasSACH() {
        Datetime myDateNow = Datetime.valueOf(System.now());
        Datetime newDate = myDateNow.addHours(1);
        Id caracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
            
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.Name = 'BREXIT';
        caracteristica.CC_Descripcion__c = 'Marca para el Brexit';
        caracteristica.RecordTypeId = caracteristicaRecordTypeId;
        caracteristica.CC_Fecha_vigencia_inicio__c = myDateNow;
        caracteristica.CC_Fecha_vigencia_fin__c = newDate;
        caracteristica.OS_Negocio__c = 'SACH';
        insert caracteristica;    
        
		Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Caso de prueba';
        caso1.Status = 'Activo';
        caso1.Origin = 'Phone';
        caso1.CC_Canal_Procedencia__c = 'SACH';
        insert caso1;
        
        Test.startTest();
        List<CC_Caracteristica__c> listaCaracteristica = CC_Marcas_Case.caracteristicas(caso1.Id);
        Test.stopTest();
        System.assert(listaCaracteristica.size() > 0);
    }
    
    
}