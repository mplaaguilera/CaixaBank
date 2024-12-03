@isTest
global class CC_WS_Mock_ALF_WSDL_01 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           
            CC_WS_ALF_Cons_NP.outconsultapersonasws oResp = new CC_WS_ALF_Cons_NP.outconsultapersonasws();
            CC_WS_ALF_Cons_NP.datosPersona oDatosPersona = new CC_WS_ALF_Cons_NP.datosPersona();
            CC_WS_ALF_Cons_NP.datosNomPer oDatosNomPer = new CC_WS_ALF_Cons_NP.datosNomPer();
            CC_WS_ALF_Cons_NP.datosContacto oDatosCont = new CC_WS_ALF_Cons_NP.datosContacto();
            List<CC_WS_ALF_Cons_NP.email> oEmail = new List<CC_WS_ALF_Cons_NP.email>();
            List<CC_WS_ALF_Cons_NP.telefono> oTel = new List<CC_WS_ALF_Cons_NP.telefono>();
            CC_WS_ALF_Cons_NP.datosDomicilio oDatosDom = new CC_WS_ALF_Cons_NP.datosDomicilio();
            CC_WS_ALF_Cons_NP.domicilioFiscal oDatosDomFiscal = new CC_WS_ALF_Cons_NP.domicilioFiscal();
            CC_WS_ALF_Cons_NP.alertas oAlerta = new CC_WS_ALF_Cons_NP.alertas();
            Decimal dEmpGestor;
            List<CC_WS_ALF_Cons_NP.caracteristicas> oCar = new List<CC_WS_ALF_Cons_NP.caracteristicas>();

            CC_WS_ALF_Cons_NP.digitalizacion oDig = new CC_WS_ALF_Cons_NP.digitalizacion();
            CC_WS_ALF_Cons_NP.datosCabecera oCab = new CC_WS_ALF_Cons_NP.datosCabecera();
            CC_WS_ALF_Cons_NP.noResident oResident = new CC_WS_ALF_Cons_NP.noResident();
            CC_WS_ALF_Cons_NP.direccionCorrespondencia oDirCor = new CC_WS_ALF_Cons_NP.direccionCorrespondencia();
            CC_WS_ALF_Cons_NP.datosEmpresa oDatosEmp = new CC_WS_ALF_Cons_NP.datosEmpresa();
            CC_WS_ALF_Cons_NP.datosTributacion oTrib = new CC_WS_ALF_Cons_NP.datosTributacion(); 
            CC_WS_ALF_Cons_NP.proteccionDatos oProt = new CC_WS_ALF_Cons_NP.proteccionDatos();
            CC_WS_ALF_Cons_NP.actividadEconomica oActE = new CC_WS_ALF_Cons_NP.actividadEconomica();
            CC_WS_ALF_Cons_NP.errores oErr = new CC_WS_ALF_Cons_NP.errores();
            CC_WS_ALF_Cons_NP.datosMifId oMif = new CC_WS_ALF_Cons_NP.datosMifId();
            CC_WS_ALF_Cons_NP.datosAuditoria oAudit = new CC_WS_ALF_Cons_NP.datosAuditoria();
            CC_WS_ALF_Cons_NP.colectivo oCol = new CC_WS_ALF_Cons_NP.colectivo();
            CC_WS_ALF_Cons_NP.datosDireccionPer oDirPer = new CC_WS_ALF_Cons_NP.datosDireccionPer();
            List<CC_WS_ALF_Cons_NP.colectivo> oListCol = new List<CC_WS_ALF_Cons_NP.colectivo>();
            List<CC_WS_ALF_Cons_NP.proteccionDatos> oListProt = new List<CC_WS_ALF_Cons_NP.proteccionDatos>();
            CC_WS_ALF_Cons_NP.tribuItem oTribu = new CC_WS_ALF_Cons_NP.tribuItem();
            List<CC_WS_ALF_Cons_NP.tribuItem> oListTribu = new List<CC_WS_ALF_Cons_NP.tribuItem>();
            CC_WS_ALF_Cons_NP.aviso oAv = new CC_WS_ALF_Cons_NP.aviso();
            List<CC_WS_ALF_Cons_NP.aviso> oListAv = new List<CC_WS_ALF_Cons_NP.aviso>();
            CC_WS_ALF_Cons_NP.proteccDatos oProtecc = new CC_WS_ALF_Cons_NP.proteccDatos();
            CC_WS_ALF_Cons_NP.controlVivencia oViv = new CC_WS_ALF_Cons_NP.controlVivencia();

            oDatosPersona.tipoIdentificador = 'NIF';
            oDatosPersona.nombre = 'Cliente Mock Test1';
            oDatosPersona.numeroIdFiscal = '00000000T';
            //oDatosPersona.paisPasaporte = '';
            //oDatosPersona.pasaporte = '';
            oDatosPersona.idioma = 'Castellano';
            oDatosPersona.codiIdioma = '002';
            oDatosPersona.fechaNacimiento = 'Fri Mar 17 00:00:00 CET 2000';
            oDatosPersona.sexo = '';

            oDatosNomPer.nombreDP = 'Cliente';
            oDatosNomPer.apellido1 = 'Mock';
            oDatosNomPer.apellido2 = 'Test1';
            oDatosNomPer.particula1 = '';
            oDatosNomPer.particula2 = '';

            //Añadir teléfonos.
            CC_WS_ALF_Cons_NP.telefono oTel1 = new CC_WS_ALF_Cons_NP.telefono();
            oTel1.cargo = '';
            oTel1.claseTelf = '1';
            oTel1.extensio = '0';
            oTel1.numTelf = '656960302';
            oTel1.personaContacto = 'Cliente Mock Test1';
            oTel1.prefijo = '34';
            oTel1.tipoTelf = '006';

            CC_WS_ALF_Cons_NP.telefono oTel2 = new CC_WS_ALF_Cons_NP.telefono();
            oTel2.cargo = '';
            oTel2.claseTelf = '1';
            oTel2.extensio = '0';
            oTel2.numTelf = '600909090';
            oTel2.personaContacto = 'Cliente Mock Test1';
            oTel2.prefijo = '34';
            oTel2.tipoTelf = '006';

            // Añadir e-mails.
            CC_WS_ALF_Cons_NP.email oMail1 = new CC_WS_ALF_Cons_NP.email();
            oMail1.cargoPersonaCnto = '';
            oMail1.claseEmail = '1';
            oMail1.email = 'pruebas@caixabank.com';
            oMail1.perconta = 'Cliente Mock Test1';

            CC_WS_ALF_Cons_NP.email oMail2 = new CC_WS_ALF_Cons_NP.email();
            oMail2.cargoPersonaCnto = '';
            oMail2.claseEmail = '1';
            oMail2.email = 'pruebas2@caixabank.com';
            oMail2.perconta = 'Cliente Mock Test1';

            oTel.add(oTel1);
            oTel.add(oTel2);
            oEmail.add(oMail1);
            oEmail.add(oMail2);
            oDatosCont.listaEmails = oEmail;
            oDatosCont.listaTelefonos = oTel;

            // Domicilio Fiscal.
            oDatosDomFiscal.codigoPostal = '21001 HUELVA';
            oDatosDomFiscal.direccion = 'JEREZ, 11 1';
            oDatosDomFiscal.motivoRelacion = '';
            oDatosDomFiscal.normalizacion = 'N';
            oDatosDomFiscal.pais = 'ESPA&#xD1;A';
            oDatosDom.domicilioFiscal = oDatosDomFiscal;

            // Alertas.
            oAlerta.oficinaGestora = '3421';

            // Empleado gestor.
            dEmpGestor = 47283;

            // Características.
            CC_WS_ALF_Cons_NP.caracteristicas oCar1 = new CC_WS_ALF_Cons_NP.caracteristicas();
            oCar1.codigoSenyal = '46';
            oCar1.descripcion = 'Estruc. de control no validada. No aplica';
            oCar1.idSenyal = '1';
            oCar1.motiu = '004';
            oCar1.tipoSenyal = '10';
            oCar.add(oCar1);

            CC_WS_ALF_Cons_NP.caracteristicas oCar2 = new CC_WS_ALF_Cons_NP.caracteristicas();
            oCar2.codigoSenyal = '89';
            oCar2.descripcion = 'Inventada';
            oCar2.idSenyal = '1';
            oCar2.motiu = '004';
            oCar2.tipoSenyal = '10';
            
            CC_WS_ALF_Cons_NP.caracteristicas oCar3 = new CC_WS_ALF_Cons_NP.caracteristicas();
            oCar3.codigoSenyal = '134';
            oCar3.descripcion = 'Origen Bankia';
            oCar3.idSenyal = '1';
            oCar3.motiu = '004';
            oCar3.tipoSenyal = '10';
            oCar.add(oCar3);

            CC_WS_ALF_Cons_NP.caracteristicas oCar4 = new CC_WS_ALF_Cons_NP.caracteristicas();
            oCar4.codigoSenyal = '135';
            oCar4.descripcion = 'Origen Compartido';
            oCar4.idSenyal = '1';
            oCar4.motiu = '004';
            oCar4.tipoSenyal = '10';
            oCar.add(oCar4);

            CC_WS_ALF_Cons_NP.caracteristicas oCar5 = new CC_WS_ALF_Cons_NP.caracteristicas();
            oCar5.codigoSenyal = '19';
            oCar5.descripcion = 'Firma digitalizada';
            oCar5.idSenyal = '1';
            oCar5.motiu = '004';
            oCar5.tipoSenyal = '10';
            oCar.add(oCar5);

            CC_WS_ALF_Cons_NP.caracteristicas oCar6 = new CC_WS_ALF_Cons_NP.caracteristicas();
            oCar6.codigoSenyal = '20';
            oCar6.descripcion = 'Documento digitalizado';
            oCar6.idSenyal = '1';
            oCar6.motiu = '004';
            oCar6.tipoSenyal = '10';
            oCar.add(oCar6);

            // Datos no usado, clase test.
            oDig.digitalizarDNI = 'x';
            oDig.digitalizarFirma = 'x';

            oCab.idiomaTerminal = 'x';
            oCab.indicadorBloqueo = 'x';
            oCab.numeroPersona = 'x';
            oCab.subtipoPersona = 'x';
            oCab.tipoPersona = 'x';

            oResident.fechaDeclaracionResiFiscal = 'x';

            oDirCor.codigoPostal = 'x';
            oDirCor.direccion = 'x';
            oDirCor.normalizacion = 'x';
            oDirCor.pais = 'x';

            oDatosEmp.antiguedadCliente = 'x';
            oDatosEmp.anyos = 'x';
            oDatosEmp.apoderado = 'x';
            oDatosEmp.codiPaisNaix = 'x';
            oDatosEmp.constituida = 'x';
            oDatosEmp.fechaCancelacion = 'x';
            oDatosEmp.fechaConstitucion = 'x';
            oDatosEmp.formaLegal = 'x';
            oDatosEmp.idMercantil = 'x';
            oDatosEmp.identificador = 'x';
            oDatosEmp.idioma = 'x';
            oDatosEmp.nifeuro = 'x';
            oDatosEmp.nombre = 'x';
            oDatosEmp.pais = 'x';
            oDatosEmp.personaContacto = 'x';
            oDatosEmp.tipoIdentificador = 'x';

            oTrib.indicadorTributacion = 'x';
            oTribu.identificador1 = 'x';
            oTribu.identificador2 = 'x';
            oTribu.pais = 'x';
            oTribu.tipoIdentificador1 = 'x';
            oTribu.tipoIdentificar2 = 'x';
            oListTribu.add(oTribu);
            oTrib.litaTribu = oListTribu;

            oProt.descripcion = 'x';
            oListProt.add(oProt);

            oActE.cifra = 'x';
            oActE.cnae = 'x';
            oActE.codiCNAE = 'x';
            oActE.codiOrfondos = 'x';
            oActE.codiSector = 'x';
            oActE.ejercicio = 'x';
            oActE.indCifra = 'x';
            oActE.indImprimirEC = 'x';
            oActE.origenFondos = 'x';
            oActE.origenFondosProcede = 'x';
            oActE.pendienteVerificar = 'x';
            oActE.sector = 'x';
            oActE.tipoTributacion = 'x';

            oErr.aplicacion = 'x';
            oErr.codigoError = 'x';
            oErr.textoError = 'x';

            oMif.adenda = 'x';
            oMif.codigoSubcategoria = 'x';
            oMif.fechaPrimeraFirma = 'x';
            oMif.fechaUltimaFirma = 'x';
            oMif.idCategoria = 'x';

            oAudit.fechaModificacionDireccion = 'x';
            oAudit.fechaModificacionOficina = 'x';
            oAudit.fechaModificacionPersona = 'x';
            oAudit.numOficina = 'x';

            oCol.descripcion = 'x';
            oListCol.add(oCol);

            oDirPer.codPostal = 'x';
            oDirPer.localitat = 'x';
            oDirPer.nomcarrer = 'x';
            oDirPer.numHasta = 'x';
            oDirPer.numcarrer = 'x';
            oDirPer.numero = 'x';
            oDirPer.paisNac = 'x';
            oDirPer.paisReside = 'x';
            oDirPer.provincia = 'x';
            oDirPer.resta = 'x';
            oDirPer.tipovia = 'x';

            oProtecc.admiteCaixa = 'x';
            oProtecc.admiteCaixaCard = 'x';
            oProtecc.admiteMicro = 'x';
            oProtecc.noAdmiteCaixa = 'x';
            oProtecc.noAdmiteCaixaCard = 'x';
            oProtecc.noAdmiteMicro = 'x';

            oViv.fechaControlVivencia = 'x';
            oViv.fechaProximoControl = 'x';
            oViv.pendienteControlVivencia = 'x';

            oAv.codAvisoHost1 = 'x';
            oAv.codigoAviso1 = 'x';
            oAv.codigoAviso11 = 'x';
            oAv.codigoAviso12 = 'x';
            oAv.codigoAviso13 = 'x';
            oAv.codigoAviso2 = 'x';
            oAv.tipoAviso = 'x';
            oListAv.add(oAv);
            oAlerta.listaAvisos = oListAv;

            // Rellenar estructura final.
            oResp.datosPersona = oDatosPersona;
            oResp.datosNomPer = oDatosNomPer;
            oResp.datosContacto = oDatosCont;
            oResp.datosDomicilio = oDatosDom;
            oResp.alertas = oAlerta;
            oResp.numEpleadoGestor = dEmpGestor;
            oResp.listaCaracteristicas = oCar;

            oResp.digitalizacion = oDig;
            oResp.datosCabecera = oCab;
            oResp.noResident = oResident;
            oResp.datosDomicilio.direccionCorrespondencia = oDirCor;
            oResp.datosEmpresa = oDatosEmp;
            oResp.datosTributacion = oTrib;
            oResp.listaProteccionDatos = oListProt;
            oResp.actividadEconomica = oActE;
            oResp.errores = oErr;
            oResp.datosMifId = oMif;
            oResp.datosAuditoria = oAudit;
            oResp.listaColectivos = oListCol;
            oResp.datosDireccionPer = oDirPer;
            oResp.proteccDatos = oProtecc;
            oResp.controlVivencia = oViv;
                   
            CC_WS_ALF_Cons_NP.ConsultaPersonasResponse response_x = new CC_WS_ALF_Cons_NP.ConsultaPersonasResponse();
            response_x.return_x = oResp;
            response.put('response_x', response_x);
                   
			
       }
    }