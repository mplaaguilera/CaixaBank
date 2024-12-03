@isTest
public with sharing class CSBD_AlertaTelefoniaController_Test {

    /*
    @TestSetup
    static void makeData(){
        User usGestor = CSBD_Usuarios.usuarioGestor();

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp1 = new Opportunity(
            Name = 'test opp 1',
            StageName = 'En curso',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Hipoteca'),
            AccountId = cuenta.Id,
            OwnerId = usGestor.Id,
            CSBD_Producto_MIFID__c = true
        );
        Opportunity opp2 = new Opportunity(
            Name = 'test opp 2',
            StageName = 'En curso',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Accion_Comercial'),
            AccountId = cuenta.Id,
            OwnerId = usGestor.Id,
            CSBD_Producto_MIFID__c = false
        );

        opps.add(opp1);
        opps.add(opp2);

        insert opps;
        System.debug('Ids ' + opp1.Id + ' - ' + opp2.Id );
    }

    @isTest
    public static void obtenerOpp_test() {
        User usuarioGestor = [SELECT Id FROM User WHERE Email = 'usuario_test@test.com' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'test@test.com' LIMIT 1];
        List<Opportunity> opps = [SELECT Id, RecordTypeId FROM Opportunity WHERE AccountId =: acc.Id LIMIT 1];
        Opportunity oppHip = new Opportunity();
        Opportunity oppAcc = new Opportunity();
        Id recTypeHip = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Hipoteca');

        for(Opportunity opp : opps){
            System.debug('Id opp bucle ' + opp.Id );
            if(opp.RecordTypeId == recTypeHip){
                oppHip = opp;
            }else{
                oppAcc = opp;
            }
        }

        System.runAs (usuarioGestor) {
            Test.startTest();
            System.debug('Id opp test ' + oppHip.Id );
            System.debug('Id opp test ' + oppAcc.Id );
            Opportunity opp1 = CSBD_AlertaTelefoniaController.obtenerOpp(oppHip.Id);
            //Opportunity opp2 = CSBD_AlertaTelefoniaController.obtenerOpp(oppAcc.Id);
            Test.stopTest();

            System.assertEquals(opp1.CSBD_Producto_MIFID__c, true,'No se ha recuperado el valor del campo CSBD_Producto_MIFID__c correctamente.');
            //System.assertEquals(opp2.CSBD_Producto_MIFID__c, false,'No se ha recuperado el valor del campo CSBD_Producto_MIFID__c correctamente.');
        }




    }
        */

}