public with sharing class SEG_DiscrepanciaOrgZona {

    @AuraEnabled(cacheable=true)
    public static List<SEG_Excepciones_Org_Zona__mdt> obtenerMtd() {

        List<SEG_Excepciones_Org_Zona__mdt> listExcepciones = SEG_Excepciones_Org_Zona__mdt.getAll().values();
        return listExcepciones;
    }
}