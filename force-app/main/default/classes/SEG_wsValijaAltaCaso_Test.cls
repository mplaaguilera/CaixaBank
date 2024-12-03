@IsTest
public class SEG_wsValijaAltaCaso_Test {
    //Creamos los datos que vamos a usar en el test
    @TestSetup
    static void crearDatosTest(){
        
        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
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
        
        //Account

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

        Id rtListaValor = Schema.getGlobalDescribe().get('CC_Lista_Valores__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id rtValor = Schema.getGlobalDescribe().get('CC_Lista_Valores__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

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
		caso1.SEG_Idioma__c = 'en';
        caso1.OS_Referencia_Valija__c = '17022230022032000234';
		caso1.CC_AcuseRecibo__c = '1';
		caso1.Subject = 'test 1';
		caso1.Status = 'Pendiente';
		insert caso1;
    }
 
    
    @IsTest
    static void gestionPeticionSegmentosTest(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0000', 'Hay un mensaje de entrada válido');
    }

    //Control de errores en el WS.
    @IsTest
    static void gestionPeticionSegmentosNULLTest(){ 

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(null);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0000', 'Hay un mensaje de entrada válido');
    }

    @IsTest
    static void gestionPeticionSegmentosCasoExistenteTest(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000234';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000234';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0002','La referencia de valija no está dada de alta');
    }

    @IsTest
    static void gestionPeticionSegmentosWrongOfficeFormatTest(){  
        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = 'afk';
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0011', 'La oficina no se ha informado correctamente');
    }
    @isTest
     static void gestionPeticionSegmentosNoOfficeTest(){  
        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = '99999';
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;
 
        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0012','La oficina se ha informado correctamente');
    }

    @isTest
    static void gestionPeticionSegmentosKOTest(){  
        OS_WS_AltaCasoValija.Input input2 = new  OS_WS_AltaCasoValija.Input();
        input2.tipo = 'test test';
        input2.description = 'descripcion';
        input2.titulo = null;
        input2.officeNum = null ;
        input2.empNum = null;
        input2.idFaq = String.valueOf(Date.today());
        input2.email = null;
        input2.idValija = '17022230022032000234';
        input2.numSr = null;
        input2.origen = null;
        input2.tipoProceso = '02';
        input2.nombreProceso = 'Bastanteo Analizar';
        input2.zona = '';
        input2.cif = '00000000T';
        input2.grupo = null;
        input2.numOperaciones = '1';
        input2.importeTotal = null; 
        input2.resultado = null;
        input2.url = null;
        input2.tipoCargo = '03';
        input2.pagoAgrupado = 'No';
        input2.comunidad = '69-Cataluña';
        input2.premium = null;
        input2.conceptoAsociado = 'Concepto asociado Valija';
        input2.numeroDocumentos = 3;
        input2.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input2);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0001','Están informados los datos obligatorios');
    }

    @IsTest
    static void gestionPeticionSegmentosNoOrgNoZoneTest(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];
        oficina[0].SEG_Organizacion__c = null;
        oficina[0].SEG_Zona__c = null;
        update oficina;

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0010','El valor de la organización / zona de la oficina es válido');
    }

    @IsTest
    static void gestionPeticionSegmentosNoCIFTest(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = null;
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0030', 'Se ha informado un CIF correctamente');
    }

    @IsTest
    static void gestionPeticionSegmentosWrongProcessTest(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '99';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0040', 'Clasificación encontrada');
    }

    @IsTest
    static void gestionPeticionSegmentosNoOpsTest(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = 'Z';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0020' ,'Se ha introducido un número de operaciones válido');
    }

    @IsTest
    static void gestionPeticionSegmentosNoCargoTest(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '99';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0021', 'El tipo de cargo informado es válido.');
    }

    @IsTest
    static void gestionPeticionSegmentosWrongIdFaqTest(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = '';
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '03';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0022','La fecha de cargo se ha informado correctamennte, cumple con el formato esperado (YYYY-MM-DD) o es posterior a la fecha actual.');
    }
    @IsTest
    static void gestionPeticionSegmentosEntrada04Test(){  

        List<Account> oficina = [SELECT id, name, CC_Numero_Oficina_Empresa__c, CC_Numero_Oficina__c, SEG_Organizacion__c, SEG_Zona__C FROM Account WHERE name = 'Cuenta' LIMIT 1];
        List<Account> cliente = [SELECT id, name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '00000000T' LIMIT 1];
        cliente[0].CC_Numero_Documento__c = '99999999F';
        update cliente;

        OS_WS_AltaCasoValija.Input input = new  OS_WS_AltaCasoValija.Input();
        input.tipo = 'test test';
        input.description = 'descripcion';
        input.titulo = 'test test17022230022032000235';
        input.officeNum = oficina[0].CC_Numero_Oficina__c ;
        input.empNum = null;
        input.idFaq = String.valueOf(Date.today());
        input.email = null;
        input.idValija = '17022230022032000235';
        input.numSr = null;
        input.origen = null;
        input.tipoProceso = '02';
        input.nombreProceso = 'Bastanteo Analizar';
        input.zona = '';
        input.cif = '00000000T';
        input.grupo = null;
        input.numOperaciones = '1';
        input.importeTotal = null;
        input.resultado = null;
        input.url = null;
        input.tipoCargo = '04';
        input.pagoAgrupado = 'No';
        input.comunidad = '69-Cataluña';
        input.premium = null;
        input.conceptoAsociado = 'Concepto asociado Valija';
        input.numeroDocumentos = 3;
        input.adjuntos = null;

        Test.startTest();
            OS_WS_AltaCasoValija.Output resultado = SEG_wsValijaAltaCaso.gestionPeticionSegmentos(input);
        Test.stopTest();
        System.assertEquals(resultado.codigo, '0021', 'El tipo de cargo informado es válido.');
    }

}