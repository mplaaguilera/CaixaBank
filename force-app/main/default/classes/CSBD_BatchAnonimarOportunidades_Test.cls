@isTest
public class CSBD_BatchAnonimarOportunidades_Test {

    @testSetup
    public static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        CSBD_ParametrosBatch__c batchParametros = new CSBD_ParametrosBatch__c();
        batchParametros.Name = 'batch de prueba';
		batchParametros.CSBD_HorasParaBatch__c = 24; //se añade un mes y un par de horas a causa de que el campo CSBD_Fecha_vencimiento_alta__c se crea con 1 mes de diferencia de la fecha actual, lo necesitamos para la comparativa de la query
        batchParametros.CSBD_HorasParaBatch2__c = 24; //campo similar al superior, este sirve para calcular las horas para desestimar la oportunidad
        batchParametros.CSBD_RegistrosPorLote__c = 10;
        batchParametros.CSBD_TiempoIntervalos__c = 2;
        insert batchParametros;

        insert new CSBD_ParametrosAnonimizar__c(Name = 'CSBD_Email_Solicitud__c', CSBD_Campo__c = 'CSBD_Email_Solicitud__c');
		insert new CSBD_ParametrosAnonimizar__c(Name = 'CSBD_Telefono_Solicitud__c', CSBD_Campo__c = 'CSBD_Telefono_Solicitud__c');

        //insert new CSBD_QueryDinamica__c(Name = 'CSBD_Now_NUMPERSO__c', CSBD_Operador__c = '=', CSBD_WhereCondition__c = 'null' , CSBD_FieldCondition__c = 'CSBD_Now_NUMPERSO__c', CSBD_TipoBatch__c = 'Anonimizar');
    }

    @isTest
    public static void batchAnonimar() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs(usuarioGestor) {
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('CSBD_Email_Solicitud__c', 'maildeentradaparaseranonimizado@prueba.es');
            campos.put('CSBD_Telefono_Solicitud__c', '603845672');
            campos.put('CSBD_Anonimizada__c', false);
            campos.put('CSBD_Estado__c', 'Rechazada');

            Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
            hipoteca.CSBD_Fecha_vencimiento_alta__c = System.now().addHours(-75);
            update hipoteca;

            Test.startTest();
            Database.executeBatch(new CSBD_BatchAnonimarOportunidades());
            Test.stopTest();

            Opportunity hipotecaCreada = [SELECT CSBD_Email_Solicitud__c, CSBD_Telefono_Solicitud__c, CSBD_Anonimizada__c, CSBD_Fecha_vencimiento_alta__c, OwnerId
                                            FROM Opportunity WHERE Id = :hipoteca.Id];

            System.assertNotEquals(null, hipotecaCreada.CSBD_Fecha_vencimiento_alta__c);
            System.assertEquals(true, hipotecaCreada.CSBD_Anonimizada__c);
            System.assertEquals('xxxxxx@xxxxx.xxx', hipotecaCreada.CSBD_Email_Solicitud__c);
            System.assertEquals('******', hipotecaCreada.CSBD_Telefono_Solicitud__c);
            System.assertEquals(usuarioGestor.Id, hipotecaCreada.OwnerId);
        }
    }
}