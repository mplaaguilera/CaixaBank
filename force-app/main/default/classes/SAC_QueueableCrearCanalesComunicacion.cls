public with sharing class SAC_QueueableCrearCanalesComunicacion implements Queueable {
    String sTipo;
    List<String> oContMailAct = new List<String>();
    Map<String,String> oMailCont = new Map<String,String> ();
    Map<String,Map<String,String>> oDatosCont = new Map<String,Map<String,String>>();

    public SAC_QueueableCrearCanalesComunicacion(String sTipoC, List<String> oContMailActC, Map<String,String> oMailContC, Map<String,Map<String,String>> oDatosContC) {
        sTipo = sTipoC;
        oContMailAct = oContMailActC;
        oMailCont = oMailContC;
        oDatosCont = oDatosContC;
    }

    public void execute(QueueableContext context) {
        CC_NotifSegCaso.crearCanalesComunicacion (sTipo, oContMailAct, oMailCont, oDatosCont);
    }
}