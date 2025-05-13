@IsTest
public class SEG_ValijaStatusJustificantes_Test {
   
    @TestSetup
    static void crearDatosTest(){
        Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();

        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
       	CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.Name = 'Detalle1';
        mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle.RecordTypeId = recordTypeIdDetalle;
        mccDetalle.CC_Tematica__c = mccTematica.Id;
        mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
        mccDetalle.CC_Motivo__c = mccMotivo.Id;
        mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalle;

        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;
        regla1.CBK_Negocio__c = 'Segmentos';
        insert regla1;
        
        ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account oficinaGestora = new Account();
        oficinaGestora.Name='Cuenta';
        oficinaGestora.CC_Numero_Oficina__c = '00137';
        oficinaGestora.CC_Numero_Oficina_Empresa__c = '001-'+ oficinaGestora.CC_Numero_Oficina__c;
        oficinaGestora.SEG_NotaCentroPlantillasCAT__c = 'notasCentroCAT'; 
        oficinaGestora.SEG_NotaCentroPlantillasEN__c = 'notasCentroEN'; 
        oficinaGestora.SEG_NotaCentroPlantillasES__c = 'notasCentroES'; 
        oficinaGestora.SEG_NotaCentroPlantillasEU__c = 'notasCentroEU'; 
        oficinaGestora.SEG_NotaCentroPlantillasGL__c = 'notasCentroGL';
        oficinaGestora.SEG_Organizacion__c = 'Centro Empresas';
        oficinaGestora.SEG_Zona__c = 'Empresas Cataluña';
        oficinaGestora.RecordTypeId = recordTypeCentro;
        insert oficinaGestora;

        ID recordTypeClienteSeg = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();

        Account cliente = new Account();
        cliente.Name='Cuenta2';
        cliente.SEG_NotaCentroPlantillasCAT__c = 'notasCentroCAT'; 
        cliente.SEG_NotaCentroPlantillasEN__c = 'notasCentroEN'; 
        cliente.SEG_NotaCentroPlantillasES__c = 'notasCentroES'; 
        cliente.SEG_NotaCentroPlantillasEU__c = 'notasCentroEU'; 
        cliente.SEG_NotaCentroPlantillasGL__c = 'notasCentroGL';
        cliente.SEG_Organizacion__c = 'Centro Empresas';
        cliente.SEG_Zona__c = 'Empresas Cataluña';
        cliente.CC_Numero_Documento__c = '00000000T';
        cliente.RecordTypeId = recordTypeClienteSeg;
        insert cliente;
        
        //Grupo Colaborador
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c();
        grupoCol1.Name = 'MCC 0029';
        grupoCol1.RecordTypeId = grupoOpSegId;
        grupoCol1.SEG_GrupoSegmentos__c = true;
        grupoCol1.SEG_NotaGrupoPlantillaEN__c = 'notaGrupoEN';
        grupoCol1.SEG_NotaGrupoPlantillaES__c = 'notaGrupoES';
        grupoCol1.SEG_NotaGrupoPlantillaCAT__c = 'notaGrupoCAT';
        grupoCol1.SEG_NotaGrupoPlantillaEU__c = 'notaGrupoEU';
        grupoCol1.SEG_NotaGrupoPlantillaGL__c = 'notaGrupoGA';
        insert grupoCol1;

        Id rtListaValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id rtValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

        CC_Lista_Valores__c listaValoresPadre = new CC_Lista_Valores__c();
        listaValoresPadre.RecordTypeId = rtListaValor;
        listaValoresPadre.CC_Activa__c = true;
        listaValoresPadre.Name = 'VALIJA: PROCESOS SEGMENTOS';
        listaValoresPadre.CC_Valor__c = oficinaGestora.SEG_Organizacion__c;
        insert listaValoresPadre;

        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = rtValor;
        listaValores.CC_Activa__c = true;
        listaValores.CC_Lista__c = listaValoresPadre.Id;
        listaValores.Name = '02';
        listaValores.CC_Valor__c = oficinaGestora.SEG_Organizacion__c;
        insert listaValores;

        // Crear contactos para cuentas SEG.
		Contact contactoSEG1 = new Contact();
		contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		contactoSEG1.LastName = 'Contacto SEG 1';
		contactoSEG1.AccountId = oficinaGestora.Id;
		contactoSEG1.Email = 'test@test.com';
		insert contactoSEG1;

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = oficinaGestora.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.SEG_Idioma__c = 'es';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        caso1.Status = 'Activo';
        caso1.Subject = 'test 1';
        caso1.SEG_Organizacion__c = 'Banca Corporativa';
        caso1.OS_Referencia_Valija__c = '17022230022032000234';
        caso1.SEG_RefSalienteValija__c = '17022230022032000234';
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.Origin = 'WebService';
        caso1.SEG_EstadoTrasladoValija__c = 'Ficheros procesados';
        caso1.SEG_N_operaciones_del_caso__c = 1;
		insert caso1; 
        
        ContentVersion ficheroValija2 = new ContentVersion();
        ficheroValija2.ContentLocation = 'S';
        ficheroValija2.SEG_ValijaId__c = '0054321';
        ficheroValija2.Description = 'fichero_SEG_2';
        ficheroValija2.PathOnClient = 'fichero_SEG_2.txt';
        ficheroValija2.Title = 'fichero_SEG_2';
        ficheroValija2.VersionData = Blob.valueOf('test');
        ficheroValija2.IsMajorVersion = true;
        ficheroValija2.SEG_Tipo__c = 'JUSTIFICANTES';
        ficheroValija2.SEG_EnviadoValija__c = true;
        insert ficheroValija2;

        ContentVersion ficheroAdjuntado2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ficheroValija2.Id];

        ContentDocumentLink linkFichero = new ContentDocumentLink();
        linkFichero.ContentDocumentId = ficheroAdjuntado2.ContentDocumentId;
        linkFichero.LinkedEntityId = caso1.Id;
        linkFichero.Visibility = 'AllUsers'; 
        
        insert linkFichero;
    }


    @IsTest
    static void informarEstadoTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];
        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add(conVer[0].id);
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = caso[0].Id;
        input.valijaId = caso[0].OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0000','La referencia de valija no está dada de alta');
        System.assertEquals(resultado.resultado, 'OK','NOK');

    }

    //Errores
    @IsTest
    static void informarEstadoErroresTest(){  
        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = null;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0000','La referencia de valija no está dada de alta');
        System.assertEquals(resultado.resultado, 'NOK','OK');
    }

    @IsTest
    static void informarEstadoNoCaseTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];
        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add(conVer[0].id);
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = '12';
        input.valijaId = caso[0].OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
            System.assertEquals(resultado.codigo, '0001','Se ha encontrado el caso indicado en la petición.');
            System.assertEquals(resultado.resultado, 'NOK','OK');
    }

    @IsTest
    static void informarEstadoNoReferenceTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];

        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add(conVer[0].id);
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = caso[0].Id;
        input.valijaId = '12';
        input.status = 'OK';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
            System.assertEquals(resultado.codigo, '0002','La referencia de Valija es válida');
            System.assertEquals(resultado.resultado, 'NOK','OK');
    }

    @IsTest
    static void informarEstadoNoReferencePaqueteriaTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];
        caso[0].OS_Referencia_Valija__c = '23';
        caso[0].Origin = 'Paquetería';
        update caso;

        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add(conVer[0].id);
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = caso[0].Id;
        input.valijaId = '12';
        input.status = 'OK';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
            System.assertEquals(resultado.codigo, '0002','La referencia de Valija es válida (paquetería).');    
            System.assertEquals(resultado.resultado, 'NOK','OK');
    }

    @IsTest
    static void informarEstadoTrasladoErrorTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];
        caso[0].SEG_EstadoTrasladoValija__c = 'Iniciado';
        update caso;

        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add(conVer[0].id);
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = caso[0].Id;
        input.valijaId = caso[0].OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
            System.assertEquals(resultado.codigo, '0006','El caso se ha enviado a Valija o ya no se ha recibido el OK a la recepción de justificantes.');
            System.assertEquals(resultado.resultado, 'NOK','OK');  
    }

    @IsTest
    static void informarEstadoIncorrectoTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];
        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add(conVer[0].id);
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = caso[0].Id;
        input.valijaId = caso[0].OS_Referencia_Valija__c;
        input.status = 'test';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
            System.assertEquals(resultado.codigo, '0003','Se ha informado un estado válido.');  
            System.assertEquals(resultado.resultado, 'NOK','OK');
    }

    @IsTest
    static void informarEstadoJustificantesTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];
        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add(conVer[0].id);
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = caso[0].Id;
        input.valijaId = caso[0].OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'Quizas';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
            System.assertEquals(resultado.codigo, '007','Se ha informado un estado válido para la gestión de justificantes.'); 
            System.assertEquals(resultado.resultado, 'NOK','OK'); 
    }

    @IsTest
    static void informarEstadoErrorFechaTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];
        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add(conVer[0].id);
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = caso[0].Id;
        input.valijaId = caso[0].OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = 'test';
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
            System.assertEquals(resultado.codigo, '0000','Error en el procesado de la petición');  
            System.assertEquals(resultado.resultado, 'OK','OK');
    }

    @IsTest
    static void informarEstadoNoFicherosTest(){  

        List<Case> caso = [SELECT id, subject,OS_Referencia_Valija__c FROM Case WHERE subject = 'test 1' LIMIT 1];
        List<ContentVersion> conVer = [SELECT id FROM ContentVersion WHERE Title = 'fichero_SEG_2'];

        List<String> filelist = new List<String>();
        filelist.add('test');
        List<String> emails = new List<String>();
        emails.add('email@email.com');

        SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput input = new SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostInput();
        input.operation = 'JUSTIFICANTES';
        input.caseId = caso[0].Id;
        input.valijaId = caso[0].OS_Referencia_Valija__c;
        input.status = 'OK';
        input.detalleProceso = 'Ficheros procesados';
        input.requiereJustificantes = 'No';
        input.numeroOperaciones = 300;
        input.fechaValorSLA = String.valueOf(Datetime.now());
        input.fileList = filelist;
        input.emails = emails;

        Test.startTest();
            SEG_wsValijaStatusFiles.SEG_WS_StatusFile_PostOutput resultado = SEG_ValijaStatusJustificantes.informarEstado(input);
        Test.stopTest();
            System.assertEquals(resultado.codigo, '0004','Datos obligatorios informados');
            System.assertEquals(resultado.resultado, 'NOK','OK');

    }
}