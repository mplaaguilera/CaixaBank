public with sharing class OS_WS_AltaCasoValija_Queueable implements Queueable{


    public OS_WS_AltaCasoValija.Input input;
    public Map<String, Integer> reintentos = new Map<String, Integer>();

    public OS_WS_AltaCasoValija_Queueable(OS_WS_AltaCasoValija.WrapperValores valoresWS) {
        this.input = valoresWS.input;
        this.reintentos = valoresWS.reintentosMap;
    }
    public void execute(QueueableContext context){
        String outId = String.valueof(this.input.idValija);
        if(reintentos.containsKey(outId) && reintentos.get(outId) < 5){
            Integer addReintento = reintentos.get(outId)+1;
            reintentos.put(String.valueOf(this.input.idValija), addReintento);
            OS_WS_AltaCasoValija.principal(this.input, reintentos, true);
        } else{
           CBK_Log.error(this.input.idValija, 'Se ha producido UNABLE_TO_LOCK_ROW con más de 5 intentos en el alta de valija: '+this.input);
        }
    }
}