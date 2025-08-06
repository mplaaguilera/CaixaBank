public with sharing class CC_IdentClienteExis_Future {
    /*
        Clase para identificación de clientes / contactos en enrutamientos Omnichannel existentes.
    */

    @InvocableMethod(label='Procesar Identificación Clientes Existentes' description='Identificación de clientes Existentes')
	public static void identificarClientesChatExistentes(List<ID> listNewObj) {

        // Si la fecha refresco está configurada a 0 días, salir.
        Integer iDiasRef = CC_WS_Methods_ALF.getDiasRefrescoALF ('CC_Int_ALF');
        if (iDiasRef == 0 && !Test.isRunningTest())
        {
            return;
        }
        
        Set<ID> oID = new Set<ID>(listNewObj);

        // Si existen elementos nuevos enrutados, gestión llamada Alfabético.
        // Lanzamos un máximo de 50 callouts (límite Hard), con las llamadas repartidas.
        if (oID.size() > 0)
        {
            List<ID> oIDList = new List<ID>(oID);
            Integer j = 1;
            Map<Integer,List<ID>> oMap = new Map<Integer,List<ID>>();
            for (Integer i=0;i<oIDList.size();i++)
            {
                if (j > 50)
                    j = 1;

                // Inicializar listas.
                if (oMap.get(j) == null)
                {
                    List<ID> oSet = new List<ID>();
                    oMap.put(j,oSet);
                }

                // Añadir valor.
                oMap.get(j).add(oIDList[i]);

                j = j + 1;
            }

            // Lanzar llamadas Futuras.
            
            for (Integer i : oMap.keySet())
            {
                CC_IdentCliente_Future.CallUpdateALFExistentes(oMap.get(i));
            }

            oIDList.clear();
            oIDList = null;

            oMap.clear();
            oMap = null;
        }

        oID.clear();
        oID = null;
	}
}