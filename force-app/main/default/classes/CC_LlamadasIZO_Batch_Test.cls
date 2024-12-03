// Nota: Ejecutar el test CC_LlamadasIZO_Batch_Schedule_Test para saber la cobertura real de la clase CC_LlamadasIZO_Batch
@isTest
public class CC_LlamadasIZO_Batch_Test {
    public static Integer LLAMADAS_TOTALES_POR_AGENTE = 3;

    private static void ejecutarBatch (CC_LlamadasIZO_Batch batch) {
        Database.QueryLocator ql = batch.start(null);
        Database.QueryLocatorIterator qli = ql.iterator();

        List<CC_Llamada__c> llamadas = new List<CC_Llamada__c>();
        while (qli.hasNext()) {
            llamadas.add((CC_Llamada__c)qli.next());
        }
        batch.execute(null, llamadas);
        batch.finish(null);
    }

    @isTest
    static void test() {
        List<User> agentes = new List<User>();
        User agente = new User();
        agente.FirstName = 'Agente';
        agente.ProfileId = CC_Llamada_Test.obtenerPerfilAdministrador();
        agente.EmailEncodingkey ='UTF-8';
        agente.LanguageLocaleKey ='en_US';
        agente.LocalesIdKey ='en_US';
        agente.TimezonesIdKey ='Europe/Berlin';
        agente.CompanyName = 'COMDATA';
        agente.IsActive = true;
        // Agentes sin auditar
        agente.LastName = '1Uno';
        agente.Alias = 'AUno';
        agente.Email = 'agente1@invalid.caiax';
        agente.Username = 'agente1@caiax.caiax';
        agente.CC_Auditoria_IZO__c = false;
        agentes.add(agente.clone());
        // Agentes auditados el mes pasado
        agente.LastName = '2Dos';
        agente.Alias = 'ADos';
        agente.Email = 'agente2@invalid.caiax';
        agente.Username = 'agente2@caiax.caiax';
        agente.CC_Auditoria_IZO__c = true;
        agentes.add(agente.clone());
        // Agentes sin auditar
        agente.LastName = '3Tres';
        agente.Alias = 'ATres';
        agente.Email = 'agente3@invalid.caiax';
        agente.Username = 'agente3@caiax.caiax';
        agente.CC_Auditoria_IZO__c = false;
        agentes.add(agente.clone());
        // Agente sin auditar
        agente.LastName = '4Cuatro';
        agente.Alias = 'ACuatro';
        agente.Email = 'agente4@invalid.caiax';
        agente.Username = 'agente4@caiax.caiax';
        agente.CC_Auditoria_IZO__c = false;
        agentes.add(agente.clone());
        // Agente auditado, pero que no se va a utilizar
        agente.LastName = '5Cinco';
        agente.Alias = 'ACinco';
        agente.Email = 'agente5@invalid.caiax';
        agente.Username = 'agente5@caiax.caiax';
        agente.CC_Auditoria_IZO__c = true;
        agentes.add(agente.clone());
        insert agentes;

        List<CC_Servicio_Genesys__c> servicios = new List<CC_Servicio_Genesys__c>();
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c();
        servicio.CC_Fecha_Inicio_Salesforce__c = date.today().addDays(-1);
        servicio.CC_Tipo__C = 'Servicio';
        servicio.CC_Prefijo__c = '0';
        // Servicio CaixaBankNow
        servicio.Name = 'Servicio 1';
        servicio.CC_Codigo__c = 'S1';
        servicio.CC_VDN__c = '4444444';
        servicio.CC_Tipo_Cliente__c = 'Cliente';
        servicio.CC_Canal_Procedencia__c = 'CaixaBankNow';
        servicios.add(servicio.clone());
        // Servicio ImaginBank
        servicio.Name = 'Servicio 2';
        servicio.CC_Codigo__c = 'S2';
        servicio.CC_VDN__c = '5555555';
        servicio.CC_Tipo_Cliente__c = 'Cliente';
        servicio.CC_Canal_Procedencia__c = 'ImaginBank';
        servicios.add(servicio.clone());
        insert servicios;

        List<CC_Lista_Valores__c> listaAuditorias = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c auditoriaCaixabank = new CC_Lista_Valores__c();
        auditoriaCaixabank.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Auditoria').getRecordTypeId();
        auditoriaCaixabank.CC_Llamadas_Mes_Auditoria__c = 2;
        auditoriaCaixabank.CC_Llamadas_Agente_Mes_Auditoria__c = 2;
        auditoriaCaixabank.CC_Tipo_Cliente_Auditoria__c = 'Clientes';
        auditoriaCaixabank.CC_Canal_Procedencia_Auditoria__c = 'CaixaBankNow';
        listaAuditorias.add(auditoriaCaixabank);
        CC_Lista_Valores__c auditoriaImaginBank = new CC_Lista_Valores__c();
        auditoriaImaginBank.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Auditoria').getRecordTypeId();
        auditoriaImaginBank.CC_Llamadas_Mes_Auditoria__c = 4;
        auditoriaImaginBank.CC_Llamadas_Agente_Mes_Auditoria__c = 2;
        auditoriaImaginBank.CC_Tipo_Cliente_Auditoria__c = 'Clientes';
        auditoriaImaginBank.CC_Canal_Procedencia_Auditoria__c = 'ImaginBank';
        listaAuditorias.add(auditoriaImaginBank);
        insert listaAuditorias;

        List<CC_Llamada__c> listaLlamadas = new List<CC_Llamada__c>();
        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.CC_Idioma__c = 'es';
        // Primer dia
        llamada.CC_Fecha_Inicio__c = Datetime.newInstance(2020, 5, 1, 16, 0, 0); // Datetime.newInstance(year, month, day, hour, minute, second)
        llamada.CC_Fecha_Fin__c    = llamada.CC_Fecha_Inicio__c.addMinutes(10);
        // Usuario valido
        llamada.OwnerId                  = agentes[0].Id;
        llamada.CC_Servicio_Genesys__c = servicios[0].Id;
        for (Integer i = 0; i < LLAMADAS_TOTALES_POR_AGENTE; ++i) {
            listaLlamadas.add(llamada.clone());
        }
        // Usuario una llamada invalida
        llamada.OwnerId                  = agentes[0].Id;
        llamada.CC_Servicio_Genesys__c = servicios[1].Id;
        for (Integer i = 0; i < LLAMADAS_TOTALES_POR_AGENTE; ++i) {
            listaLlamadas.add(llamada.clone());
        }
        // Usuario valido
        llamada.OwnerId                  = agentes[1].Id;
        llamada.CC_Servicio_Genesys__c = servicios[1].Id;
        for (Integer i = 0; i < LLAMADAS_TOTALES_POR_AGENTE; ++i) {
            listaLlamadas.add(llamada.clone());
        }

        //Segundo dia
        llamada.CC_Fecha_Inicio__c = Datetime.newInstance(2020, 5, 2, 16, 0, 0); // Datetime.newInstance(year, month, day, hour, minute, second)
        llamada.CC_Fecha_Fin__c    = llamada.CC_Fecha_Inicio__c.addMinutes(10);
        // Usuario invalido del dia anterior ahora es valido
        llamada.OwnerId                  = agentes[0].Id;
        llamada.CC_Servicio_Genesys__c = servicios[1].Id;
        listaLlamadas.add(llamada.clone());
        // Nuevas llamadas para usuario valido, para reemplazarlas
        llamada.OwnerId                  = agentes[1].Id;
        llamada.CC_Servicio_Genesys__c = servicios[1].Id;
        for (Integer i = 0; i < LLAMADAS_TOTALES_POR_AGENTE; ++i) {
            listaLlamadas.add(llamada.clone());
        }

        //Ultimo dia
        llamada.CC_Fecha_Inicio__c = Datetime.newInstance(2020, 5, 31, 16, 0, 0); // Datetime.newInstance(year, month, day, hour, minute, second)
        llamada.CC_Fecha_Fin__c    = llamada.CC_Fecha_Inicio__c.addMinutes(10);
        // En ImaginBank tenemos un usuario con prioridad 3 (se ha marcado para CaixaBank) y con prioridad 2 (se ha marcado el mes pasado)
        // Añadimos nuevas llamadas para reemplazar ambos, ya que los nuevos tienen prioridad 1 (no se han marcado ni este mes ni el anterior)
        llamada.OwnerId                  = agentes[2].Id;
        llamada.CC_Servicio_Genesys__c = servicios[1].Id;
        for (Integer i = 0; i < LLAMADAS_TOTALES_POR_AGENTE; ++i) {
            listaLlamadas.add(llamada.clone());
        }
        llamada.OwnerId                  = agentes[3].Id;
        llamada.CC_Servicio_Genesys__c = servicios[1].Id;
        for (Integer i = 0; i < LLAMADAS_TOTALES_POR_AGENTE; ++i) {
            listaLlamadas.add(llamada.clone());
        }

        insert listaLlamadas;

        // Invalidamos la llamada que queríamos con una consulta
        CC_Llamada__c consulta = new CC_Llamada__c();
        consulta.CC_Idioma__c = 'es';
        consulta.OwnerId = agentes[1].Id;
        consulta.CC_Servicio_Genesys__c = servicios[1].Id;
        consulta.CC_Llamada_Padre__c = listaLlamadas[LLAMADAS_TOTALES_POR_AGENTE+1].Id;
        insert consulta;

        
        Test.startTest();

        ejecutarBatch(new CC_LlamadasIZO_Batch(2020, 5, 1));
        System.assertEquals(4, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        System.assertEquals(2, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        OwnerId = :agentes[0].Id AND CC_Servicio_Genesys__c = :servicios[1].Id AND
        CC_Valida_IZO__c = true][0].get('sum'));
        System.assertEquals(2, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        OwnerId = :agentes[0].Id AND CC_Servicio_Genesys__c = :servicios[0].Id AND
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        System.assertEquals(0, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        OwnerId = :agentes[0].Id AND CC_Servicio_Genesys__c = :servicios[1].Id AND
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        System.assertEquals(2, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        OwnerId = :agentes[1].Id AND CC_Servicio_Genesys__c = :servicios[1].Id AND
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        
        ejecutarBatch(new CC_LlamadasIZO_Batch(2020, 5, 2));
        ejecutarBatch(new CC_LlamadasIZO_Batch(2020, 5, 2)); // Lo ejecutamos dos veces para simular que la primera vez no se ha ejecutado bien
        System.assertEquals(6, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        System.assertEquals(2, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        OwnerId = :agentes[0].Id AND CC_Servicio_Genesys__c = :servicios[1].Id AND
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        System.assertEquals(2, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        OwnerId = :agentes[1].Id AND CC_Servicio_Genesys__c = :servicios[1].Id AND
        CC_Auditoria_IZO__c <> null][0].get('sum'));

        ejecutarBatch(new CC_LlamadasIZO_Batch(2020, 5, 31));
        System.assertEquals(6, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        System.assertEquals(2, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        OwnerId = :agentes[2].Id AND
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        System.assertEquals(2, [SELECT Count(Id) sum FROM CC_Llamada__c WHERE
        OwnerId = :agentes[3].Id AND
        CC_Auditoria_IZO__c <> null][0].get('sum'));
        System.assertEquals(3, [SELECT Count(Id) sum FROM User WHERE
        Id IN :agentes AND
        CC_Auditoria_IZO__c <> null][0].get('sum'));

        Test.stopTest();
    }
}