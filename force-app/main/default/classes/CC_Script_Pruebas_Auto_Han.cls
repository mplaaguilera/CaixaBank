/*
*   Clase creada para la insercion de datos en el setup para la realizacion de pruebas de QA.
*   Previamente han de existir los usuarios que realizan dichas pruebas.
*   Para insertar los usuarios lanzaremos desde la anonima el codigo que se encuentra en el metodo insercionUsers de la clase CC_Script_Pruebas_Auto_SetUp_Helper entre los comentarios
*   INICIO EJECUCION ANONIMO Y  FIN EJECUCION ANONIMO.
*   PASOS PARA LA EJECUCION:
*   1.- Comprobar que existan los usuarios, en caso de que no se encuentren ejecutar el codigo entre INICIO EJECUCION ANONIMO Y  FIN EJECUCION ANONIMO.
*   2.- Desde la anonima ejecutar: 
*       CC_Script_Pruebas_Auto_Han.insercionDatos();
*       CC_Script_Pruebas_Auto_SetUp_Han.insercionDatos();
*/

public class CC_Script_Pruebas_Auto_Han
{
    public static void insercionDatos()
    {
        CC_Script_Pruebas_Auto_Helper.insercionMCC();
        CC_Script_Pruebas_Auto_Helper.insercionCuentas();
        CC_Script_Pruebas_Auto_Helper.insercionMarca();
        CC_Script_Pruebas_Auto_Helper.insercionAgrupador();
        CC_Script_Pruebas_Auto_Helper.insercionGrupoColaborador();
        CC_Script_Pruebas_Auto_Helper.insercionCasos();
    }
}