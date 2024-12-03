@isTest
public class CC_Informar_DG_DAN_Caso_Test {

    @isTest
    public static void informaDNDG() {
        //Creacion de cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuentaDG = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank DG',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DG'
        );        
        insert cuentaDG;
        
        Account cuentaDAN = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DAN',
            ParentId = cuentaDG.Id
        );        
        insert cuentaDAN;
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT',
            CC_Gerencia_Comercial__c = cuentaDAN.Id
        );        
        insert cuenta;
                        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            CC_OficinaGestoraId__c = cuenta.Id
        );        
        insert cuenta1;    
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DG_DAN_Caso.informaDANDG(listCaseId);
        Test.stopTest();
    }
}