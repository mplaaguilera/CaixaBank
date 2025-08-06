public with sharing class TMS_MetodosUtiles {

    public static Contact identificarNUMPERSO(String numPerso){
        if(String.isEmpty(numPerso)){
            return null;
        }else{
            String numPersoFormat = formatearNumperso(numPerso);

            Id clientePAId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
            Id clienteId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

            List<Contact> contactos = new List<Contact>();
            contactos = [SELECT AccountId FROM Contact
            WHERE (RecordTypeId = :clienteId OR Account.RecordTypeId = :clientePAId)
            AND AV_NumPerso__c = :numPersoFormat AND AV_NumPerso__c != null];

            if(!contactos.isEmpty()){
                return contactos[0];
            }
            return null;
        }


    }

    public static String formatearNumperso(String texto) {
        try {
            if (String.isBlank(texto)) {
                return '';
            } else {
                Map<String, Integer> mapa = new Map<String, Integer>();
                mapa.put('0', 0);
                mapa.put('1', 1);
                mapa.put('2', 2);
                mapa.put('3', 3);
                mapa.put('4', 4);
                mapa.put('5', 5);
                mapa.put('6', 6);
                mapa.put('7', 7);
                mapa.put('8', 8);
                mapa.put('9', 9);
                mapa.put('A', 10);
                mapa.put('B', 11);
                mapa.put('C', 12);
                mapa.put('D', 13);
                mapa.put('E', 14);
                mapa.put('F', 15);
                mapa.put('a', 10);
                mapa.put('b', 11);
                mapa.put('c', 12);
                mapa.put('d', 13);
                mapa.put('e', 14);
                mapa.put('f', 15);

                Double retorno = 0;
                for (Integer i = 0; i < texto.length(); i++)  {
                    retorno += (mapa.get(texto.substring(i, i + 1)) * Math.pow(16, texto.length() - (i + 1))) ;
                }
                //El numperso retornado puede tener un número diferente de 8 caracteres. Si tiene menos caracteres, no están guardados con 0 delante
                //return String.valueOf(Integer.valueOf(retorno)).leftPad(8, '0');
                return String.valueOf(Integer.valueOf(retorno));
            }
        } catch (Exception e) {
            return null;
        }
    }
}