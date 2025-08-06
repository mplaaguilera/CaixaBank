@isTest
global class CC_WS_Mock_CLI_WSDL2 implements WebServiceMock {
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

        List<CC_CLI_WS_Constructor.datosItem> oListDatosItem = new List<CC_CLI_WS_Constructor.datosItem>();
        CC_CLI_WS_Constructor.datosItem oDatosItem = new CC_CLI_WS_Constructor.datosItem();
        oDatosItem.agrupa35 = 'x';
        oDatosItem.area = 0;
        oDatosItem.contrato = 0;
        oDatosItem.empresa = 0;
        oDatosItem.feAper = 0;
        oDatosItem.feCanc = 0;
        oDatosItem.limite = 0;
        oDatosItem.modalidad = 0;
        oDatosItem.oficina = 0;
        oDatosItem.ordRel = 0;
        oDatosItem.prodNiv35 = 0;
        oDatosItem.producto = 0;
        oDatosItem.riesgo = 0;
        oDatosItem.saldoPunt = 0;
        oDatosItem.tipRel = 0;
        oListDatosItem.add(oDatosItem);
                   
        CC_CLI_WS_Constructor.tooutsoap oToOut = new CC_CLI_WS_Constructor.tooutsoap();
      	oToOut.claveCont = 'x';
        oToOut.codGen = 'x';
        oToOut.consucap = 0;
        oToOut.DActivo = 0;
        oToOut.DPasivo = 0;
        oToOut.datosCont = oListDatosItem;
        oToOut.imaginBank = 'S';

        oToOut.indpub = 'x';
        oToOut.nivServ = 'x';
        oToOut.numLliure1 = 0;
        oToOut.numLliure2 = 0;
        oToOut.numper = 0;
        oToOut.pctrar = 0;
        oToOut.resul12m = 0;
        oToOut.segmento = 'PIM';
        oToOut.subNegocio = 'x';
        oToOut.subSegmento = 'PIE';
        oToOut.subSubNegocio = 'x';
        oToOut.tpcre12m = 0;
        oToOut.txtErr = 'x';
        oToOut.txtLliure = 'x';
                   
        CC_CLI_WS_Constructor.toinsoap oToIn = new CC_CLI_WS_Constructor.toinsoap();
        oToIn.claveCont = 'x';
        oToIn.numLliure1 = 0;
        oToIn.numLliure2 = 0;
        oToIn.numper = 0;
        oToIn.txtLliure = 'x';

        CC_CLI_WS_Constructor.RecuperarDatosResponse response_x = new CC_CLI_WS_Constructor.RecuperarDatosResponse();
        response_x.return_x = oToOut;
        response.put('response_x', response_x);
               
               }               
}