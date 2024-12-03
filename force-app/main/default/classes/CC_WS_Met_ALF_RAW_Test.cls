@isTest
public class CC_WS_Met_ALF_RAW_Test { 
    
    @isTest
    static void test01_convertirRespuesta() {
        // Testar conversión respuesta.
        
        Test.startTest();
        
        String sRespuesta = '';
        sRespuesta = sRespuesta + '<?xml version="1.0"?>';
        sRespuesta = sRespuesta + '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
        sRespuesta = sRespuesta + '<soap:Header/>';
        sRespuesta = sRespuesta + '<soap:Body>';
        sRespuesta = sRespuesta + '<ns2:ConsultaPersonasResponse xmlns:ns2="http://alfabeticpersonaws.alfabeticpersonagestionpersona.mca.si.absis.lacaixa.es/">';
        sRespuesta = sRespuesta + '<return>';
        sRespuesta = sRespuesta + '<actividadEconomica>';
        sRespuesta = sRespuesta + '<cnae>Sin informaci&#xF3;n                                                                 </cnae>';
        sRespuesta = sRespuesta + '<codiCNAE>0</codiCNAE>';
        sRespuesta = sRespuesta + '<codiOrfondos>310</codiOrfondos>';
        sRespuesta = sRespuesta + '<codiSector>200500</codiSector>';
        sRespuesta = sRespuesta + '<indCifra/>';
        sRespuesta = sRespuesta + '<indImprimirEC/>';
        sRespuesta = sRespuesta + '<origenFondos>Sin ingresos                                                </origenFondos>';
        sRespuesta = sRespuesta + '<origenFondosProcede>true</origenFondosProcede>';
        sRespuesta = sRespuesta + '<pendienteVerificar/>';
        sRespuesta = sRespuesta + '<sector>Estudiantes                         </sector>';
        sRespuesta = sRespuesta + '<tipoTributacion>1</tipoTributacion>';
        sRespuesta = sRespuesta + '</actividadEconomica>';
        sRespuesta = sRespuesta + '<alertas>';
        sRespuesta = sRespuesta + '<descOficinaGestora/>';
        sRespuesta = sRespuesta + '<oficinaAviso>0</oficinaAviso>';
        sRespuesta = sRespuesta + '<oficinaError>0</oficinaError>';
        sRespuesta = sRespuesta + '<oficinaGestora>3071</oficinaGestora>';
        sRespuesta = sRespuesta + '</alertas>';
        sRespuesta = sRespuesta + '<codiTipoDocumento>A</codiTipoDocumento>';
        sRespuesta = sRespuesta + '<controlVivencia>';
        sRespuesta = sRespuesta + '<fechaControlVivencia/>';
        sRespuesta = sRespuesta + '<fechaProximoControl/>';
        sRespuesta = sRespuesta + '<pendienteControlVivencia/>';
        sRespuesta = sRespuesta + '</controlVivencia>';
        sRespuesta = sRespuesta + '<datosAuditoria>';
        sRespuesta = sRespuesta + '<fechaModificacionDireccion>20150112</fechaModificacionDireccion>';
        sRespuesta = sRespuesta + '<fechaModificacionOficina>20181121</fechaModificacionOficina>';
        sRespuesta = sRespuesta + '<fechaModificacionPersona>20181105</fechaModificacionPersona>';
        sRespuesta = sRespuesta + '<numOficina>9712</numOficina>';
        sRespuesta = sRespuesta + '</datosAuditoria>';
        sRespuesta = sRespuesta + '<datosCabecera>';
        sRespuesta = sRespuesta + '<idiomaTerminal/>';
        sRespuesta = sRespuesta + '<indicadorBloqueo/>';
        sRespuesta = sRespuesta + '<numeroPersona>999910559714</numeroPersona>';
        sRespuesta = sRespuesta + '<subtipoPersona/>';
        sRespuesta = sRespuesta + '<tipoPersona>F</tipoPersona>';
        sRespuesta = sRespuesta + '</datosCabecera>';
        sRespuesta = sRespuesta + '<datosContacto>';
        sRespuesta = sRespuesta + '<listaEmails>';
        sRespuesta = sRespuesta + '<claseEmail>0</claseEmail>';
        sRespuesta = sRespuesta + '<email>prueba21@caixabank.com</email>';
        sRespuesta = sRespuesta + '<perconta/>';
        sRespuesta = sRespuesta + '</listaEmails>';
        sRespuesta = sRespuesta + '<listaEmails>';
        sRespuesta = sRespuesta + '<claseEmail>0</claseEmail>';
        sRespuesta = sRespuesta + '<email>fcerrada@iberlicor.com</email>';
        sRespuesta = sRespuesta + '<perconta/>';
        sRespuesta = sRespuesta + '</listaEmails>';
        sRespuesta = sRespuesta + '<listaTelefonos>';
        sRespuesta = sRespuesta + '<claseTelf>1</claseTelf>';
        sRespuesta = sRespuesta + '<extensio>0</extensio>';
        sRespuesta = sRespuesta + '<numTelf>   633444555</numTelf>';
        sRespuesta = sRespuesta + '<personaContacto/>';
        sRespuesta = sRespuesta + '<prefijo>34</prefijo>';
        sRespuesta = sRespuesta + '<tipoTelf>006</tipoTelf>';
        sRespuesta = sRespuesta + '</listaTelefonos>';
        sRespuesta = sRespuesta + '<listaTelefonos>';
        sRespuesta = sRespuesta + '<claseTelf>1</claseTelf>';
        sRespuesta = sRespuesta + '<extensio>0</extensio>';
        sRespuesta = sRespuesta + '<numTelf>   956565656</numTelf>';
        sRespuesta = sRespuesta + '<personaContacto/>';
        sRespuesta = sRespuesta + '<prefijo>34</prefijo>';
        sRespuesta = sRespuesta + '<tipoTelf>001</tipoTelf>';
        sRespuesta = sRespuesta + '</listaTelefonos>';
        sRespuesta = sRespuesta + '<listaTelefonos>';
        sRespuesta = sRespuesta + '<claseTelf>1</claseTelf>';
        sRespuesta = sRespuesta + '<extensio>0</extensio>';
        sRespuesta = sRespuesta + '<numTelf>  9565656580</numTelf>';
        sRespuesta = sRespuesta + '<personaContacto/>';
        sRespuesta = sRespuesta + '<prefijo>39</prefijo>';
        sRespuesta = sRespuesta + '<tipoTelf>003</tipoTelf>';
        sRespuesta = sRespuesta + '</listaTelefonos>';
        sRespuesta = sRespuesta + '<listaTelefonos>';
        sRespuesta = sRespuesta + '<claseTelf>1</claseTelf>';
        sRespuesta = sRespuesta + '<extensio>0</extensio>';
        sRespuesta = sRespuesta + '<numTelf>   686638272</numTelf>';
        sRespuesta = sRespuesta + '<personaContacto/>';
        sRespuesta = sRespuesta + '<prefijo>34</prefijo>';
        sRespuesta = sRespuesta + '<tipoTelf>002</tipoTelf>';
        sRespuesta = sRespuesta + '</listaTelefonos>';
        sRespuesta = sRespuesta + '<listaTelefonos>';
        sRespuesta = sRespuesta + '<claseTelf>2</claseTelf>';
        sRespuesta = sRespuesta + '<extensio>0</extensio>';
        sRespuesta = sRespuesta + '<numTelf>   666666666</numTelf>';
        sRespuesta = sRespuesta + '<personaContacto/>';
        sRespuesta = sRespuesta + '<prefijo>34</prefijo>';
        sRespuesta = sRespuesta + '<tipoTelf>002</tipoTelf>';
        sRespuesta = sRespuesta + '</listaTelefonos>';
        sRespuesta = sRespuesta + '</datosContacto>';
        sRespuesta = sRespuesta + '<datosDireccionPer>';
        sRespuesta = sRespuesta + '<codPostal>38009</codPostal>';
        sRespuesta = sRespuesta + '<localitat>SANTA CRUZ DE TENERIFE</localitat>';
        sRespuesta = sRespuesta + '<nomcarrer>LA FORCAA</nomcarrer>';
        sRespuesta = sRespuesta + '<numHasta/>';
        sRespuesta = sRespuesta + '<numcarrer>1</numcarrer>';
        sRespuesta = sRespuesta + '<numero/>';
        sRespuesta = sRespuesta + '<paisNac>11</paisNac>';
        sRespuesta = sRespuesta + '<paisReside>011</paisReside>';
        sRespuesta = sRespuesta + '<provincia>38</provincia>';
        sRespuesta = sRespuesta + '<resta>ESC 2 3</resta>';
        sRespuesta = sRespuesta + '<tipovia>CA</tipovia>';
        sRespuesta = sRespuesta + '</datosDireccionPer>';
        sRespuesta = sRespuesta + '<datosDomicilio>';
        sRespuesta = sRespuesta + '<codiResidencia>011</codiResidencia>';
        sRespuesta = sRespuesta + '<direccionCorrespondencia/>';
        sRespuesta = sRespuesta + '<domicilioFiscal>';
        sRespuesta = sRespuesta + '<codigoPostal>38009 SANTA CRUZ DE TENERIFE (S.C.TENERIFE)</codigoPostal>';
        sRespuesta = sRespuesta + '<direccion>LA FORCAA, 1 ESC 2 3</direccion>';
        sRespuesta = sRespuesta + '<normalizacion>N</normalizacion>';
        sRespuesta = sRespuesta + '<pais>ESPA&#xD1;A</pais>';
        sRespuesta = sRespuesta + '</domicilioFiscal>';
        sRespuesta = sRespuesta + '<residencia>Espanya</residencia>';
        sRespuesta = sRespuesta + '</datosDomicilio>';
        sRespuesta = sRespuesta + '<datosEmpresa>';
        sRespuesta = sRespuesta + '<antiguedadCliente>Sat Feb 21 00:00:00 CET 2009</antiguedadCliente>';
        sRespuesta = sRespuesta + '<anyos>13</anyos>';
        sRespuesta = sRespuesta + '<apoderado/>';
        sRespuesta = sRespuesta + '<codiPaisNaix>11</codiPaisNaix>';
        sRespuesta = sRespuesta + '<constituida>Santa Cruz de Tenerife</constituida>';
        sRespuesta = sRespuesta + '<fechaCancelacion/>';
        sRespuesta = sRespuesta + '<fechaConstitucion>Tue Oct 18 00:00:00 CEST 2005</fechaConstitucion>';
        sRespuesta = sRespuesta + '<formaLegal/>';
        sRespuesta = sRespuesta + '<idMercantil> 58496409A</idMercantil>';
        sRespuesta = sRespuesta + '<identificador>58496409A</identificador>';
        sRespuesta = sRespuesta + '<idioma>Castellano               </idioma>';
        sRespuesta = sRespuesta + '<nifeuro/>';
        sRespuesta = sRespuesta + '<nombre>Raquel Morales Santos</nombre>';
        sRespuesta = sRespuesta + '<pais>Espanya</pais>';
        sRespuesta = sRespuesta + '<personaContacto/>';
        sRespuesta = sRespuesta + '<tipoIdentificador>NIF</tipoIdentificador>';
        sRespuesta = sRespuesta + '</datosEmpresa>';
        sRespuesta = sRespuesta + '<datosMifId>';
        sRespuesta = sRespuesta + '<adenda>S</adenda>';
        sRespuesta = sRespuesta + '<codigoSubcategoria/>';
        sRespuesta = sRespuesta + '<fechaPrimeraFirma>Mon Jan 09 00:00:00 CET 2017</fechaPrimeraFirma>';
        sRespuesta = sRespuesta + '<fechaUltimaFirma>Mon Jan 09 00:00:00 CET 2017</fechaUltimaFirma>';
        sRespuesta = sRespuesta + '<idCategoria>MN</idCategoria>';
        sRespuesta = sRespuesta + '</datosMifId>';
        sRespuesta = sRespuesta + '<datosNomPer>';
        sRespuesta = sRespuesta + '<apellido1>MORALES</apellido1>';
        sRespuesta = sRespuesta + '<apellido2>SANTOS</apellido2>';
        sRespuesta = sRespuesta + '<nombreDP>RAQUEL</nombreDP>';
        sRespuesta = sRespuesta + '<particula1/>';
        sRespuesta = sRespuesta + '<particula2/>';
        sRespuesta = sRespuesta + '</datosNomPer>';
        sRespuesta = sRespuesta + '<datosPersona>';
        sRespuesta = sRespuesta + '<antiguedadCliente>Sat Feb 21 00:00:00 CET 2009</antiguedadCliente>';
        sRespuesta = sRespuesta + '<codiIdioma>002</codiIdioma>';
        sRespuesta = sRespuesta + '<codiNacionalidad>011</codiNacionalidad>';
        sRespuesta = sRespuesta + '<edad>13</edad>';
        sRespuesta = sRespuesta + '<fechaDefuncion/>';
        sRespuesta = sRespuesta + '<fechaNacimiento>Tue Oct 18 00:00:00 CEST 2005</fechaNacimiento>';
        sRespuesta = sRespuesta + '<idFiscal>NIF 58496409A</idFiscal>';
        sRespuesta = sRespuesta + '<identificador>NIF 58496409A (Espanya)</identificador>';
        sRespuesta = sRespuesta + '<idioma>Castellano               </idioma>';
        sRespuesta = sRespuesta + '<nacionalidad>Espanyola</nacionalidad>';
        sRespuesta = sRespuesta + '<nifeuro/>';
        sRespuesta = sRespuesta + '<nombre>Raquel Morales Santos</nombre>';
        sRespuesta = sRespuesta + '<numeroIdFiscal>58496409A</numeroIdFiscal>';
        sRespuesta = sRespuesta + '<paisPasaporte>011</paisPasaporte>';
        sRespuesta = sRespuesta + '<sexo>M</sexo>';
        sRespuesta = sRespuesta + '<tipoIdentificador>NIF</tipoIdentificador>';
        sRespuesta = sRespuesta + '</datosPersona>';
        sRespuesta = sRespuesta + '<datosTributacion>';
        sRespuesta = sRespuesta + '<indicadorTributacion>N</indicadorTributacion>';
        sRespuesta = sRespuesta + '</datosTributacion>';
        sRespuesta = sRespuesta + '<digitalizacion>';
        sRespuesta = sRespuesta + '<digitalizarDNI>10</digitalizarDNI>';
        sRespuesta = sRespuesta + '<digitalizarFirma>10</digitalizarFirma>';
        sRespuesta = sRespuesta + '</digitalizacion>';
        sRespuesta = sRespuesta + '<errores/>';
        sRespuesta = sRespuesta + '<esUsuario>N</esUsuario>';
        sRespuesta = sRespuesta + '<listaCaracteristicas>';
        sRespuesta = sRespuesta + '<codigoSenyal>19</codigoSenyal>';
        sRespuesta = sRespuesta + '<descripcion>Firma digitalitzada</descripcion>';
        sRespuesta = sRespuesta + '<idSenyal>1</idSenyal>';
        sRespuesta = sRespuesta + '<motiu/>';
        sRespuesta = sRespuesta + '<tipoSenyal>10</tipoSenyal>';
        sRespuesta = sRespuesta + '</listaCaracteristicas>';
        sRespuesta = sRespuesta + '<listaCaracteristicas>';
        sRespuesta = sRespuesta + '<codigoSenyal>20</codigoSenyal>';
        sRespuesta = sRespuesta + '<descripcion>Document digitalitzat</descripcion>';
        sRespuesta = sRespuesta + '<idSenyal>1</idSenyal>';
        sRespuesta = sRespuesta + '<motiu/>';
        sRespuesta = sRespuesta + '<tipoSenyal>10</tipoSenyal>';
        sRespuesta = sRespuesta + '</listaCaracteristicas>';
        sRespuesta = sRespuesta + '<listaCaracteristicas>';
        sRespuesta = sRespuesta + '<codigoSenyal>34</codigoSenyal>';
        sRespuesta = sRespuesta + '<descripcion>Alta client internet. Verificat</descripcion>';
        sRespuesta = sRespuesta + '<idSenyal>1</idSenyal>';
        sRespuesta = sRespuesta + '<motiu>002</motiu>';
        sRespuesta = sRespuesta + '<tipoSenyal>10</tipoSenyal>';
        sRespuesta = sRespuesta + '</listaCaracteristicas>';
        sRespuesta = sRespuesta + '<listaCaracteristicas>';
        sRespuesta = sRespuesta + '<codigoSenyal>36</codigoSenyal>';
        sRespuesta = sRespuesta + '<descripcion>Pdt. Impr. Declar. Activitat</descripcion>';
        sRespuesta = sRespuesta + '<idSenyal>1</idSenyal>';
        sRespuesta = sRespuesta + '<motiu/>';
        sRespuesta = sRespuesta + '<tipoSenyal>10</tipoSenyal>';
        sRespuesta = sRespuesta + '</listaCaracteristicas>';
        sRespuesta = sRespuesta + '<listaCaracteristicas>';
        sRespuesta = sRespuesta + '<codigoSenyal>58</codigoSenyal>';
        sRespuesta = sRespuesta + '<descripcion>Autoritza signatura digital. Autoritza</descripcion>';
        sRespuesta = sRespuesta + '<idSenyal>1</idSenyal>';
        sRespuesta = sRespuesta + '<motiu>001</motiu>';
        sRespuesta = sRespuesta + '<tipoSenyal>10</tipoSenyal>';
        sRespuesta = sRespuesta + '</listaCaracteristicas>';
        sRespuesta = sRespuesta + '<listaCaracteristicas>';
        sRespuesta = sRespuesta + '<codigoSenyal>92</codigoSenyal>';
        sRespuesta = sRespuesta + '<descripcion>US Person</descripcion>';
        sRespuesta = sRespuesta + '<idSenyal>1</idSenyal>';
        sRespuesta = sRespuesta + '<motiu/>';
        sRespuesta = sRespuesta + '<tipoSenyal>10</tipoSenyal>';
        sRespuesta = sRespuesta + '</listaCaracteristicas>';
        sRespuesta = sRespuesta + '<listaCaracteristicas>';
        sRespuesta = sRespuesta + '<codigoSenyal>125</codigoSenyal>';
        sRespuesta = sRespuesta + '<descripcion>Dades Persona. En revisio, amb bloqueig</descripcion>';
        sRespuesta = sRespuesta + '<idSenyal>1</idSenyal>';
        sRespuesta = sRespuesta + '<motiu>002</motiu>';
        sRespuesta = sRespuesta + '<tipoSenyal>10</tipoSenyal>';
        sRespuesta = sRespuesta + '</listaCaracteristicas>';
        sRespuesta = sRespuesta + '<noResident>';
        sRespuesta = sRespuesta + '<fechaDeclaracionResiFiscal>0</fechaDeclaracionResiFiscal>';
        sRespuesta = sRespuesta + '</noResident>';
        sRespuesta = sRespuesta + '<numEpleadoGestor>68176</numEpleadoGestor>';
        sRespuesta = sRespuesta + '<numPerson25>0000000000000999910559714</numPerson25>';
        sRespuesta = sRespuesta + '<proteccDatos>';
        sRespuesta = sRespuesta + '<admiteCaixa>Cessi&#xF3; de dades</admiteCaixa>';
        sRespuesta = sRespuesta + '<noAdmiteCaixa>Publicitat, Telemarketing, Publicitat per via electr&#xF2;nica</noAdmiteCaixa>';
        sRespuesta = sRespuesta + '</proteccDatos>';
        sRespuesta = sRespuesta + '<provinciaNacimiento>038</provinciaNacimiento>';
        sRespuesta = sRespuesta + '</return>';
        sRespuesta = sRespuesta + '</ns2:ConsultaPersonasResponse>';
        sRespuesta = sRespuesta + '</soap:Body>';
        sRespuesta = sRespuesta + '</soap:Envelope>';
        
        Map<String,Object> oDataRes = CC_WS_Methods_ALF_RAW.convertirRespuesta (sRespuesta);
        
        CC_WS_ALF_Cons_NP.outconsultapersonasws oData = (CC_WS_ALF_Cons_NP.outconsultapersonasws)oDataRes.get('RETORNO');
        
        Test.stopTest();
        
        System.assertNotEquals(oData, null);
    }
    
    @isTest
    static void test02_convertirRespuesta() {
        // Testar conversión respuesta con error.
        
        Test.startTest();
        
        String sRespuesta = '';
        sRespuesta = sRespuesta + '<?xml version="1.0"?>';
        sRespuesta = sRespuesta + '<soap:ERROR xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
        sRespuesta = sRespuesta + '<soap:Header/>';
        sRespuesta = sRespuesta + '<soap:Body>';
        sRespuesta = sRespuesta + '</soap:Body>';
        sRespuesta = sRespuesta + '</soap:ERROR>';
        
        Map<String,Object> oDataRes = CC_WS_Methods_ALF_RAW.convertirRespuesta (sRespuesta);
        
        CC_WS_ALF_Cons_NP.outconsultapersonasws oData = (CC_WS_ALF_Cons_NP.outconsultapersonasws)oDataRes.get('RETORNO');
        
        Test.stopTest();
        
        System.assertEquals(oData, null);
    }
    
    @isTest
    static void test03_convertirRespuesta() {
        // Testar conversión respuesta con error.
        
        Test.startTest();
        
        String sRespuesta = '';
        sRespuesta = sRespuesta + '<?xml version="1.0"?>';
        sRespuesta = sRespuesta + '<soap:ERROR xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
        sRespuesta = sRespuesta + '<soap:Header/>';
        sRespuesta = sRespuesta + '<soap:Body>';
        sRespuesta = sRespuesta + '</soap:ERROR>';
        
        Exception oResErr;
        
        try
        {
            Map<String,Object> oDataRes = CC_WS_Methods_ALF_RAW.convertirRespuesta (sRespuesta);
            
            CC_WS_ALF_Cons_NP.outconsultapersonasws oData = (CC_WS_ALF_Cons_NP.outconsultapersonasws)oDataRes.get('RETORNO');
        }catch(Exception e) {
            oResErr = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(oResErr, null);
    }
    
    @isTest
    static void test04_getHttpALF() {
        // Testar WebService HTTP Alfabético - Respuesta correcta.
        
        Test.startTest();
        
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());

        Map<String,Object> oData = CC_WS_Methods_ALF_RAW.getHttpALF (oConfig, '999910559714', '');
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('RETORNO'), null);
    }
    
    @isTest
    static void test05_getHttpALF() {
        // Testar WebService HTTP Alfabético - Respuesta incorrecta.
        
        Test.startTest();
        
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_06());

        Map<String,Object> oData = CC_WS_Methods_ALF_RAW.getHttpALF (oConfig, '999910559714','');
        
        Test.stopTest();
        
        System.assertEquals(oData.get('RETORNO'), null);
    }
    
    @isTest
    static void test06_getAP2WSDLALF() {
        // Testar WebService WSDL Alfabético - Respuesta correcta.
        
        Test.startTest();
        
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALF_WSDL_01());

        Map<String,Object> oData = CC_WS_Methods_ALF_RAW.getAP2WSDLALF (oConfig, '999910559714','');
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('RETORNO'), null);
    }
    
    @isTest
    static void test07_getHttpALF() {
        // Testar WebService HTTP Alfabético - Respuesta incorrecta.
        
        Test.startTest();
        
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_07());

        Map<String,Object> oData = CC_WS_Methods_ALF_RAW.getHttpALF (oConfig, '999910559714','');
        
        Test.stopTest();
        
        System.assertEquals(oData.get('RETORNO'), null);
    }
    
    @isTest
    static void test08_1_getHttpALF() {
        // Testar WebService HTTP Alfabético Búsqueda NIF / TEL - Respuesta correcta.
        
		CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF_DOC');
        
        Test.startTest();
        
		Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());

        Map<String,Object> oData2 = CC_WS_Methods_ALF_RAW.getAP2WSDL_ALF_DOC (oConfig, '9999999999','DATATEL','');
        
        Test.stopTest();
        
        System.assertNotEquals(oData2.get('RETORNO'), null);
    }
    
    @isTest
    static void test08_2_getHttpALF() {
        // Testar WebService HTTP Alfabético Búsqueda NIF / TEL - Respuesta correcta.
        
		CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF_DOC');
        
        Test.startTest();
        
		Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());

        Map<String,Object> oData = CC_WS_Methods_ALF_RAW.getAP2WSDL_ALF_DOC (oConfig, '9999999999','DATADOC','');
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('RETORNO'), null);
    }
    
    @isTest
    static void test09_getHttpALF() {
        // Testar WebService HTTP Alfabético Búsqueda RRSS - Respuesta correcta.
        
        Test.startTest();
        
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF_RRSS');
        
		Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFRRSS_WSDL_01());

        Map<String,Object> oData = CC_WS_Methods_ALF_RAW.getAP2WSDL_ALF_RRSS (oConfig, '9999999999','','');
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('RETORNO'), null);
    }
}