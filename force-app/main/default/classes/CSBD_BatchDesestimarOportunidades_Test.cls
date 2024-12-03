@isTest
public class CSBD_BatchDesestimarOportunidades_Test {

    @testSetup
    public static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        CSBD_ParametrosBatch__c batchParametros = new CSBD_ParametrosBatch__c();
        batchParametros.Name = 'batch desestimar';
		batchParametros.CSBD_HorasParaBatch__c = 24; //se añade un mes y un par de horas a causa de que el campo CSBD_Fecha_vencimiento_alta__c se crea con 1 mes de diferencia de la fecha actual, lo necesitamos para la comparativa de la query
        batchParametros.CSBD_HorasParaBatch2__c = 24; //campo similar al superior, este sirve para calcular las horas para desestimar la oportunidad
		batchParametros.CSBD_RegistrosPorLote__c = 10;
        batchParametros.CSBD_TiempoIntervalos__c = 2;
        insert batchParametros;
        
        insert new CSBD_QueryDinamica__c(Name = 'CSBD_Now_NUMPERSO__c', CSBD_Operador__c = '=', CSBD_WhereCondition__c = 'null' , CSBD_FieldCondition__c = 'CSBD_Now_NUMPERSO__c', CSBD_TipoBatch__c = 'Desestimar');
    }

    @isTest
    public static void batchDesestimar() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs (usuarioGestor) {
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('CSBD_Email_Solicitud__c', 'xxxxxx@xxxxx.xxx');
            campos.put('CSBD_Telefono_Solicitud__c', '******');
            Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_PROAutomatica', campos);

            hipoteca.CSBD_Fecha_vencimiento_alta__c = System.now().addHours(-50);
            update hipoteca;
            
            Test.startTest();
            CSBD_BatchDesestimarOportunidades obj = new CSBD_BatchDesestimarOportunidades();
            DataBase.executeBatch(obj); 
            Test.stopTest();

        	Opportunity hipotecaDesestimada = [SELECT CSBD_Estado__c, StageName, CSBD_Resolucion__c, OwnerId FROM Opportunity WHERE Id =:hipoteca.Id LIMIT 1];
            List <Task> tareaDeHipotecaDesestimada = [SELECT Type, Status, Subject FROM Task WHERE WhatId =:hipoteca.Id];

            System.assertEquals('Rechazada', hipotecaDesestimada.CSBD_Estado__c);
            System.assertEquals('Rechazada', hipotecaDesestimada.StageName);
            System.assertEquals('Caducidad fecha vencimiento alta', hipotecaDesestimada.CSBD_Resolucion__c);
            System.assertEquals(usuarioGestor.Id, hipotecaDesestimada.OwnerId);

            System.assertEquals(hipotecaDesestimada.CSBD_Estado__c, tareaDeHipotecaDesestimada[0].Type);
            System.assertEquals('Completed', tareaDeHipotecaDesestimada[0].Status);
            System.assertEquals(hipotecaDesestimada.CSBD_Estado__c, tareaDeHipotecaDesestimada[0].Subject);
        }
    }
}