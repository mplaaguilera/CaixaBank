@isTest
public class AV_WS_Mock_Representantes_WSDL implements WebServiceMock {
       public void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {

        List<AV_GCF_Integration.ListaRepreItem> representantes = new List<AV_GCF_Integration.ListaRepreItem>();
        AV_GCF_Integration.ListaRepreItem representante = new AV_GCF_Integration.ListaRepreItem();
        representante.carrec = 'carrec';
        representante.datosEscritura = 'datosEscritura';
        representante.dvtopod = 1;
        representante.empresa = 1;
        representante.fechaVencimiento = 23;
        representante.formatAct = 'formatAct';
        representante.indAccion = 'indAccion';
        representante.indCaducidad = 'indCaducidad';
        representante.indFirmaDig = 'indFirmaDig';
        representante.nif = 'nif';
        representante.nombre ='nombre';
        representante.numperso = 61334682;
        representante.ticketFirma ='ticketFirma';
        representante.tipoFirma = 'tipoFirma';
        representante.tipoFirmaAnt = 'tipoFirmaAnt';
        representantes.add(representante);

        AV_GCF_Integration.Outextconslistarepre body = new AV_GCF_Integration.Outextconslistarepre();
        body.contador = '1';
        body.listaRepre = representantes;

        AV_GCF_Integration.ConsListaRepreResponse responseBody = new AV_GCF_Integration.ConsListaRepreResponse();
        responseBody.return_x = body;
        response.put('response_x', responseBody);
    }
}