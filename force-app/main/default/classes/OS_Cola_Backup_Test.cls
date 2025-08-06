@isTest
public class OS_Cola_Backup_Test {

    @TestSetup
    static void cargaDeDatos(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Group testGroup = new Group(Name='2N CCI Holabank', Type='Queue');
        insert testGroup;
    
        //Associating queue with group AND to the Case object
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
        insert testQueue;
    }

    @isTest
    public static void cambiarPropietario() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        List<Id> idDeCasos = new List<Id>();
        List<Case> casos = new List<Case>();

        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso1.Subject = 'Prueba1';
        caso1.Status = 'Activo';
        caso1.Origin = 'Email'; 
        caso1.OwnerId = usuarioOperador.Id;
        caso1.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso1.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(caso1);

        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso2.Subject = 'Prueba2';
        caso2.Status = 'Activo';
        caso2.Origin = 'Email'; 
        caso2.OwnerId = usuarioOperador.Id;
        caso2.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso2.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(caso2);

        Case caso3 = new Case();
        caso3.CC_Idioma__c = 'es';
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso3.Subject = 'Prueba3';
        caso3.Status = 'Activo';
        caso3.Origin = 'Email'; 
        caso3.OwnerId = usuarioOperador.Id;
        caso3.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso3.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso3.CC_Tipo_Contacto__c = 'Asesoramiento';
        casos.add(caso3);
        insert casos;
        
        for(Case caso : casos){
            idDeCasos.add(caso.Id);
        }

        System.runAs(OS_Usuarios.usuarioAdmin()){
            Test.startTest();
            OS_Cola_Backup.cambioPropietario(new List<Id>{usuarioOperador.Id});
            Test.stopTest();
            
            List<Case> casosActual = [SELECT OwnerId FROM Case WHERE Id IN :idDeCasos];

            User usuarioInfo = [SELECT OS_Cola_Backup__c FROM User WHERE Id =:usuarioOperador.Id AND OS_Cola_Backup__c != NULL AND OS_Inicio_Vigencia_Agente_Backup__c <= TODAY AND OS_Fin_Vigencia_Agente_Backup__c >= TODAY LIMIT 1];
            Group grupo = [SELECT ID FROM Group WHERE Name =:usuarioInfo.OS_Cola_Backup__c AND Type ='Queue' LIMIT 1];

            System.assertEquals(grupo.Id, casosActual[0].OwnerId, 'No se ha asignado correctamente el grupo al caso');
            System.assertEquals(grupo.Id, casosActual[1].OwnerId, 'No se ha asignado correctamente el grupo al caso');
            System.assertEquals(grupo.Id, casosActual[2].OwnerId, 'No se ha asignado correctamente el grupo al caso');
        }
    }
}