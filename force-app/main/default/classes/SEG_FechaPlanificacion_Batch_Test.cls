@isTest
public with sharing class SEG_FechaPlanificacion_Batch_Test {
    @testSetup
    
        static void crearDatosPrueba(){
            
        Datetime todayDatetime = Datetime.now();
        //RT Contact
        Id recordCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordColaborador = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        //RT Account
        Id recordCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        //RT Grupo
        Id rtGrupoOpSeg = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        
        //Creamos centro
        Account acc = new Account();
        acc.Name = 'centro';
        acc.RecordTypeId = recordCentro;
        insert acc;
        
        //Cliente
        //Creamos centro
        Account accCliente = new Account();
        accCliente.Name = 'cliente';
        accCliente.RecordTypeId = rtCliente;
        insert accCliente;
        
        //Creamos contacts 
        Contact cCliente = new Contact();
        cCliente.LastName = 'cliente';
        cCliente.RecordTypeId = recordCliente;
        cCliente.CC_Cargo__c = 'DIRECCIÓN';
        cCliente.Email = 'cCliente@gmail.com';
        insert cCliente;
        
        Contact cColaborador = new Contact();
        cColaborador.LastName = 'colaborador';
        cColaborador.RecordTypeId = recordColaborador;
        cColaborador.CC_Cargo__c = 'DIRECCIÓN';
        cColaborador.Email = 'cColaborador@gmail.com';
        cColaborador.AccountId = acc.Id;
        insert cColaborador; 
        
        //Creamos plantilla con diferentes idiomas.
        SEG_Plantilla__c plantilla = new SEG_Plantilla__c();
        plantilla.Name = 'Review';
        plantilla.SEG_Activa__c = true;
        plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
        plantilla.SEG_Organizacion__c = 'Banca Corporativa';
        insert plantilla;

        //Creamos grupo colaborador para asignarle plantilla
        CC_Grupo_Colaborador__c grupocc = new CC_Grupo_Colaborador__c();
        grupocc.RecordTypeId = rtGrupoOpSeg;
        insert grupocc;
            
        //Relacionamos grupo colaborador con plantilla
        CC_Grupo_Colaborador_Plantilla__c grupoccplantilla = new CC_Grupo_Colaborador_Plantilla__c();
        grupoccplantilla.CC_Grupo_Colaborador__c = grupocc.id;
        grupoccplantilla.SEG_Plantilla__c = plantilla.Id;
        grupoccplantilla.CC_Operativa__c = 'Trasladar';
        insert grupoccplantilla;


        //Crear reclamaciones
        SEG_Reclamaciones__c recl = new SEG_Reclamaciones__c();
        recl.Name = 'Testreclamaciones';
        recl.SEG_Plazo1Reclamacion__c = 1;
        recl.SEG_Plazo2Reclamacion__c = 2;
        recl.SEG_Plazo3Reclamacion__c = 3;
        recl.SEG_PlazoEnvioGestor__c = 4;
        recl.SEG_PlazoLlamada__c = 1;

        insert recl;
        
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

       
        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c();
        clasRapida.Name = 'CR1';
        clasRapida.SEG_Tematica__c = mccTematica.Id;
        clasRapida.SEG_Producto__c = mccProducto.Id;
        clasRapida.SEG_Motivo__c = mccMotivo.Id;
        clasRapida.SEG_Detalle__c = mccDetalle.Id;
        clasRapida.SEG_ReclamacionesContratos__c = recl.Id;
        clasRapida.SEG_CRContratos__c  = true;
        clasRapida.CBK_Negocio__c = 'Segmentos';
        insert clasRapida;
        
        //Creamos casos
        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.Subject = 'Caso SEG_Email_Launcher_Controller_Test';
        caso1.Origin = 'Email';
        caso1.CC_Idioma__c = 'es';
        caso1.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso1.CC_Detalles_Solucion__c = 'Detalles solución';
        caso1.SEG_Grupo__c = grupocc.Id;
        caso1.SEG_Organizacion__c = 'Banca Corporativa';
        caso1.SEG_Fecha_planificaci_n__c = todayDatetime;
        caso1.SEG_Subestado__c = 'En curso';
        caso1.status= 'Activo';
        caso1.SEG_Numero_de_centro__c = acc.id;
        caso1.SEG_ClasificacionRapida__c = clasRapida.id;
        insert caso1;
        
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.Origin = 'Email';
        caso2.CC_Idioma__c = 'es';
        caso2.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles solución';
        caso2.status= 'Activo';
        caso2.SEG_Subestado__c = 'En curso';
        caso2.SEG_Fecha_planificaci_n__c = todayDatetime;
        caso2.SEG_Grupo__c = grupocc.Id;
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        insert caso2;
        
        //Excepciones       
        SEG_ExcepcionesCentro__c exCentro = new SEG_ExcepcionesCentro__c(); 
        exCentro.SEG_Plantilla__c = plantilla.id;
        exCentro.SEG_CentroEmpresa__c = acc.id;
        insert exCentro;
        
        SEG_ExcepcionesGrupo__c exGrupo = new SEG_ExcepcionesGrupo__c(); 
        exGrupo.SEG_Plantilla__c = plantilla.id;
        exGrupo.SEG_GrupoTrabajoTexto__c = grupocc.id;
        insert exGrupo;
        
        SEG_ExcepcionesEmpresa__c exEmpresa = new SEG_ExcepcionesEmpresa__c(); 
        exEmpresa.SEG_Plantilla__c = plantilla.id;
        exEmpresa.SEG_Empresa__c = accCliente.id;
        insert exEmpresa;
        
        SEG_ExcepcionesCR__c exCR = new SEG_ExcepcionesCR__c();
        exCR.SEG_Plantilla__c = plantilla.id;
        exCR.SEG_ClasificacionRapida__c = clasRapida.id;
        insert exCR;
    }
    
    @isTest
    public static void fechaPlanificacion()
    {
        //Se ejecuta el batch
		Test.startTest();
        	Database.executeBatch(new SEG_FechaPlanificacion_Batch());
        Test.stopTest();
        
    }
    
}