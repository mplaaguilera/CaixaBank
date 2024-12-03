public with sharing class CSBD_Utils {

        public static List<String> listaCampo(List<SObject> registros, String campo, Boolean quitarDuplicados) {
        /* Marc Pla, 19/8/2020: Dada una lista de SObject, retorna una lista con los valores del campo indicado.
            Ejemplo:
                List<String> nombresCuentas = listaCampo([SELECT Status, Account.Name FROM Case LIMIT 3], 'Account.Name', false);
                retorna ['JOAN MERCADER OBIOLS', 'PERE CRUZ', 'RAMON MESSEGUER'] */

        List<String> retorno = new List<String>();
        if (registros != null) {
            for (SObject registro : registros) {
                String valor;
                Map<String, Object> mapaCamposActual = registro.getPopulatedFieldsAsMap();
                for (String campoJoin : campo.split('\\.')) {
                    if (campo.containsNone('.') || campoJoin == campo.substringAfterLast('.')) {
                        valor = String.valueOf(mapaCamposActual.get(campoJoin));
                    } else { //Lookup
                        if (mapaCamposActual.get(campoJoin) != null) {
                            mapaCamposActual = ((SObject)mapaCamposActual.get(campoJoin)).getPopulatedFieldsAsMap();
                        }
                    }
                }
                retorno.add(valor);
            }
        }
        return quitarDuplicados ? new List<String>(new Set<String>(retorno)) : retorno;
    }

    public static List<String> listaCampo(List<SObject> lista, String campo) {
        return listaCampo(lista, campo, false);
    }

    public static Map<String, SObject> mapaCampo(List<SObject> lista, String campo) {
        /* Marc Pla, 9/4/2021: Dada una lista de SObject, retorna un mapa con
            los valores del campo indicado como clave y el SObject como valor.

            Ejemplo:
                Map<String, Object> mapaCuentas = listaMapa([SELECT Name FROM Account LIMIT 3], 'Name');
                retorna {'JOAN MERCADER OBIOLS'=(account1), 'PERE CRUZ'=(account2), 'RAMON MESSEGUER'=(account3)} */

        Map<String, SObject> retorno = new Map<String, SObject>();
        if (lista != null) {
            for (SObject item : lista) {
                if (item.getPopulatedFieldsAsMap().containsKey(campo)) {
                    retorno.put(String.valueOf(item.get(campo)), item);
                }
            }
        }
        return retorno;
    }

    public static List<String> descartarDuplicadosLista(List<String> lista) {

        if (lista == null) {
            return null;
        } else {
            Set<String> aux = new Set<String>();
            for (String item : lista) {
                aux.add(item);
            }
            return new List<String>(aux);
        }
    }
}