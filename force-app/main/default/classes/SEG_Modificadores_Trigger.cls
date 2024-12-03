public with sharing class SEG_Modificadores_Trigger {

    private static Map<String, Boolean> modificadoresTrigger = new Map<String, Boolean>();

    public static void activarModificador(String nombreModificador) {
        modificadoresTrigger.put(nombreModificador, true);
    }

    public static void desactivarModificador(String nombreModificador) {
        modificadoresTrigger.put(nombreModificador, false);
    }

    public static Boolean modificadorActivo(String nombreModificador) {
        return modificadoresTrigger.containsKey(nombreModificador) && modificadoresTrigger.get(nombreModificador);
    }
}