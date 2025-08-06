@isTest
private class CSBD_GestorOportunidadSkillHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        
        // Crear datos de prueba para CC_Lista_Valores__c
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c(
            Name = 'CSBD - Habilidades independientes a enrutar',
            RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId()
        );
        insert lista;
        
        // Crear valores de habilidades
        List<CC_Lista_Valores__c> habilidades = new List<CC_Lista_Valores__c>();
        
        // Obtener el RecordType para CC_Valor
        Id rt = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        
        habilidades.add(new CC_Lista_Valores__c(
            Name = 'Habilidad 1',
            CC_Valor__c = 'Skill1',
            CC_Lista__c = lista.Id,
            CC_Activa__c = true,
            RecordTypeId = rt
        ));
        
        habilidades.add(new CC_Lista_Valores__c(
            Name = 'Habilidad 2',
            CC_Valor__c = 'Skill2',
            CC_Lista__c = lista.Id,
            CC_Activa__c = true,
            RecordTypeId = rt
        ));
        
        habilidades.add(new CC_Lista_Valores__c(
            Name = 'Habilidad Inactiva',
            CC_Valor__c = 'SkillInactive',
            CC_Lista__c = lista.Id,
            CC_Activa__c = false,
            RecordTypeId = rt
        ));
        
        insert habilidades;
    }
    
    @isTest
    static void testSingletonPattern() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            
            // Obtener primera instancia
            CSBD_GestorOportunidadSkillHandler instance1 = CSBD_GestorOportunidadSkillHandler.getInstance();
            
            // Obtener segunda instancia
            CSBD_GestorOportunidadSkillHandler instance2 = CSBD_GestorOportunidadSkillHandler.getInstance();
            
            Test.stopTest();
            
            // Verificar que ambas instancias son la misma (Singleton)
            System.assert(instance1 === instance2, 'Las instancias deben ser la misma (patrón Singleton)');
        }
    }
    
    @isTest
    static void testCargarHabilidades() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            
            CSBD_GestorOportunidadSkillHandler handler = CSBD_GestorOportunidadSkillHandler.getInstance();
            
            Test.stopTest();
            
            // Verificar que las habilidades se cargaron correctamente
            System.assert(handler.contieneValor('Skill1'), 'Debe contener Skill1');
            System.assert(handler.contieneValor('Skill2'), 'Debe contener Skill2');
            System.assert(!handler.contieneValor('SkillInactive'), 'No debe contener SkillInactive (inactiva)');
        }
    }
    
    @isTest
    static void testContieneValor() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            
            CSBD_GestorOportunidadSkillHandler handler = CSBD_GestorOportunidadSkillHandler.getInstance();
            
            Test.stopTest();
            
            // Verificar valores que existen
            System.assert(handler.contieneValor('Skill1'), 'Debe encontrar Skill1');
            System.assert(handler.contieneValor('Skill2'), 'Debe encontrar Skill2');
            
            // Verificar valores que no existen
            System.assert(!handler.contieneValor('SkillNoExiste'), 'No debe encontrar SkillNoExiste');
            System.assert(!handler.contieneValor(''), 'No debe encontrar string vacío');
            System.assert(!handler.contieneValor(null), 'No debe encontrar null');
        }
    }    

}