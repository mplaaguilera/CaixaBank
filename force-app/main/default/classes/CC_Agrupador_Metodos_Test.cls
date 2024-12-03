@IsTest
public class CC_Agrupador_Metodos_Test {
    private static void crearListaDeValores() {
        CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;
        
        CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso.CC_Activa__c = true;
        valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral primer aviso';
        valorUmbralPrimerAviso.CC_Valor__c = '2';
        CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos.CC_Activa__c = true;
        valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos.CC_Valor__c = '50';
        
        List<CC_Lista_Valores__c> valorUmbralInsert = new List<CC_Lista_Valores__c>();
        valorUmbralInsert.add(valorUmbralPrimerAviso);
        valorUmbralInsert.add(valorUmbralSiguientesAvisos);
    	insert valorUmbralInsert;
    }

    @isTest
    private static void crearPlantillasIncidencias() {
        crearListaDeValores();

        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador.CC_Titulo__c = 'Agrupador Test';
        agrupador.CC_Estado__c = 'Activo';
        agrupador.CC_Numero_Casos__c = 0;
        insert agrupador;

        Case caso1 = new Case();
        caso1.Status = 'Activo';
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso1.CC_Idioma__c = 'es';
        caso1.CC_CanalNotifCli__c = 'Email';
        caso1.CC_NotIncidencia__c = '1';
        insert caso1;

        Case caso2 = caso1.clone();
        insert caso2;
        
        Test.startTest();
        //Debe crearse plantilla
        caso1.Status = 'Pendiente Incidencia';
        caso1.CC_Agrupador_Id__c = agrupador.Id;
        update caso1;

        // No debe crearse plantilla porque ya existe una con el mismo idioma y canal
        caso2.Status = 'Pendiente Incidencia';
        caso2.CC_Agrupador_Id__c = agrupador.Id;
        update caso2;
        
        List<CC_PlantillaAsociada__c> listaPlantillas1 = [SELECT CC_Idioma__c, CC_Canal__c, CC_Tipo_Cliente__c, CC_Agrupador__c FROM CC_PlantillaAsociada__c ORDER BY CC_Idioma__c ASC];

        // Se cambia el idioma del caso, por lo tanto, se crea una segunda plantilla
        caso2.CC_Idioma__c = 'ca';
        caso2.CC_CanalNotifCli__c = 'SMS';
        update caso2;

        List<CC_PlantillaAsociada__c> listaPlantillas2 = [SELECT CC_Idioma__c FROM CC_PlantillaAsociada__c ORDER BY CC_Idioma__c ASC];

        // Se debería eliminar la plantilla nueva porque ahora son 2 casos con el mismo idioma
        caso2.CC_Idioma__c = 'es';
        caso2.CC_CanalNotifCli__c = 'Email';
        update caso2;
        
        List<CC_PlantillaAsociada__c> listaPlantillas3 = [SELECT CC_Idioma__c, CC_Canal__c, CC_Tipo_Cliente__c, CC_Agrupador__c FROM CC_PlantillaAsociada__c ORDER BY CC_Idioma__c ASC];

        //No se debería eliminar la plantilla ni modificar, porque hay otro caso que depende de ella
        CC_PlantillaAsociada__c plantillaAsociada = listaPlantillas3[0];
        plantillaAsociada.CC_CuerpoNotificacion__c = 'Nuevo cuerpo';
        update plantillaAsociada;
        caso1.Status = 'Activo';
        caso1.CC_Agrupador_Id__c = null;
        update caso1;

        List<CC_PlantillaAsociada__c> listaPlantillas4 = [SELECT CC_CuerpoNotificacion__c FROM CC_PlantillaAsociada__c ORDER BY CC_Idioma__c DESC];

        Test.stopTest();

        System.assertEquals(1, listaPlantillas1.size());
        System.assertEquals('es', listaPlantillas1[0].CC_Idioma__c);
        System.assertEquals('Email', listaPlantillas1[0].CC_Canal__c);
        System.assertEquals('Cliente', listaPlantillas1[0].CC_Tipo_Cliente__c);
        System.assertEquals(agrupador.Id, listaPlantillas1[0].CC_Agrupador__c);

        
        System.assertEquals(2, listaPlantillas2.size());
        System.assertEquals('es', listaPlantillas2[0].CC_Idioma__c);
        System.assertEquals('ca', listaPlantillas2[1].CC_Idioma__c);

        System.assertEquals(1, listaPlantillas3.size());
        System.assertEquals('es', listaPlantillas3[0].CC_Idioma__c);

        System.assertEquals(1, listaPlantillas4.size());
        System.assertEquals('Nuevo cuerpo', listaPlantillas4[0].CC_CuerpoNotificacion__c);
    }
}