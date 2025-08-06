/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 11-21-2022
 * @last modified by  : Adrian Mariscal 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   11-21-2022   Adrian Mariscal   Initial Version
**/

public with sharing class CC_PrecioFacturacion_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry (CC_TriggerParameters tp)
    {
        process((Map<Id, CBK_Precio_Facturacion__c>)tp.oldMap, (List<CBK_Precio_Facturacion__c>)tp.newList, (Map<Id, CBK_Precio_Facturacion__c>)tp.newMap);
    }
    
    private void process(Map<Id, CBK_Precio_Facturacion__c> mapOldObj, List<CBK_Precio_Facturacion__c> listNewObj, Map<Id, CBK_Precio_Facturacion__c> mapNewObj) 
    {
        
        // Extraemos la Id del recordtype para que se haga la busqueda solo de ese tipo
	    Id precioFacturacionRT = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        
		//creamos una lista del object para luego procesar el registro entrante
		List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();
        List<CBK_Precio_Facturacion__c> listaPrecioOrdenado = ordenarLista(listNewObj);
        set<CBK_Precio_Facturacion__c> listaPrecioDesechados = new set<CBK_Precio_Facturacion__c>();

        set<String> setcanalEntrada = new set<String>();
        set<String> setnombreEmpresa = new set<String>();
        set<String> setAreaNegocio = new set<String>();
             
		//recorremos el listado que nos ha entrado, si coincide el recordType ID, y si la fecha fin del antiguo objeto cambia, entonces añadimos el objeto en la nueva lista 
		for(CBK_Precio_Facturacion__c precioft : listaPrecioOrdenado)
        {
			if(precioft.recordtypeId == precioFacturacionRT && mapOldObj.get(precioft.Id).CC_Fecha_Fin_Vigencia__c != precioft.CC_Fecha_Fin_Vigencia__c)
            {
                //Si la lista está vacia metemos el primer registro ya que no tiene ninguno con quien comparar
                //Y se añaden los campos obligatorios en un set para registrar los distintos valores, al ser un set ningun valor se repetirá
                if(listaPrecio.isEmpty())
                {
                listaPrecio.add(precioft);
                setcanalEntrada.add(precioft.CC_Canal_Entrada__c);
                setnombreEmpresa.add(precioft.CC_Nombre_Empresa__c);
                setAreaNegocio.add(precioft.CC_Area_Negocio__c);
                }
                else 
                {
                    /*
                    Cuando ya hay un registro en la lista, cada registro primero se compara con el resto de registros ya insertados.
                    Creamos un booleano para que, despues de chequear el registro con las demás, si no hay ninguna colision de fechas,
                    Se añade a una lista de entrada 
                    En caso de que dos registros choquen, se inserta en una lista de desechados temporales, mas adelante se volverá a 
                    comprobar con la lista final
                    */
                    Boolean longitud = true;

                    for(CBK_Precio_Facturacion__c preciocheck : listaPrecio)
                    {
                        //Las fechas inicio y fin del registro a insertar y de los registros que ya han sido comprobados
                        Datetime regEntradaIni = precioft.CC_Fecha_Inicio_Vigencia__c;
                        Datetime regEntradaFin = precioft.CC_Fecha_Fin_Vigencia__c;
                        Datetime regCheckIni = preciocheck.CC_Fecha_Inicio_Vigencia__c;
                        Datetime regCheckFin = preciocheck.CC_Fecha_Fin_Vigencia__c;

                        if(precioft.CC_Canal_Entrada__c == preciocheck.CC_Canal_Entrada__c
                        && precioft.CC_Nombre_Empresa__c == preciocheck.CC_Nombre_Empresa__c
                        && precioft.CC_Area_Negocio__c == preciocheck.CC_Area_Negocio__c
                        )
                        {
                            //llamamos un metodo que introducimos las fechas para comparar las fechas de ambos registros, si no hay choque de fechas
                            //Devuelve true y suma para pasar al siguiente registro
                            if (comparacionFecha(regEntradaIni, regEntradaFin, regCheckIni, regCheckFin) == false)
                            {
                                longitud = false;
                                listaPrecioDesechados.add(precioft);
                                setcanalEntrada.add(precioft.CC_Canal_Entrada__c);
                                setnombreEmpresa.add(precioft.CC_Nombre_Empresa__c);
                                setAreaNegocio.add(precioft.CC_Area_Negocio__c);
                            }
                        }
                      
                    //Si en ningun momento se detecto un error en la comprobación de cada campo, la agrega a la lista
                    //Y se añaden los campos obligatorios en un set para registrar los distintos valores, al ser un set ningun valor se repetirá
                    }
                    if (longitud == true)
                    {
                        listaPrecio.add(precioft);
                        setcanalEntrada.add(precioft.CC_Canal_Entrada__c);
                        setnombreEmpresa.add(precioft.CC_Nombre_Empresa__c);
                        setAreaNegocio.add(precioft.CC_Area_Negocio__c);
                    }
                }
			}
		}
        
        //Si la lista no está vacia, creamos una query con una lista de todos los campos que coincidan
        //Y la agregamos a otra lista con todas las coincidencias encontradas
        if(!listaPrecio.isEmpty())
        {
            List<CBK_Precio_Facturacion__c> listaSQL = [SELECT id, CC_Canal_Entrada__c, CC_Nombre_Empresa__c, 
            CC_Fecha_Inicio_Vigencia__c, CC_Fecha_Fin_Vigencia__c, CC_Area_Negocio__c 
                                            FROM CBK_Precio_Facturacion__c WHERE
                                              CC_Canal_Entrada__c IN :setcanalEntrada  
                                              AND CC_Nombre_Empresa__c IN :setnombreEmpresa
                                              AND CC_Area_Negocio__c IN :setAreaNegocio
                                              ORDER BY CC_Fecha_Inicio_Vigencia__c ASC];  

            //Realizamos una comparacion entre el registro a insertar con la lista sacada del SQL
                for(CBK_Precio_Facturacion__c precioEntrada : listaPrecio)
                {
                    Integer longitud = 0;

                    for(CBK_Precio_Facturacion__c precioSQL: listaSQL)
                    {
                        if(precioSQL.CC_Canal_Entrada__c == precioEntrada.CC_Canal_Entrada__c
                            && precioSQL.CC_Nombre_Empresa__c == precioEntrada.CC_Nombre_Empresa__c
                            && precioSQL.CC_Area_Negocio__c == precioEntrada.CC_Area_Negocio__c
                            )
                        {
                            //Las fechas inicio y fin del registro a insertar y de los registros de la lista QUERY
                            Datetime regEntradaIni = precioEntrada.CC_Fecha_Inicio_Vigencia__c;
                            Datetime regEntradaFin = precioEntrada.CC_Fecha_Fin_Vigencia__c;
                            Datetime regSQLIni = precioSQL.CC_Fecha_Inicio_Vigencia__c;
                            Datetime regSQLFin = precioSQL.CC_Fecha_Fin_Vigencia__c;
                            String idEntrada = precioEntrada.id;
                            String idSQL = precioSQL.id;
                            //llamamos un metodo que introducimos las fechas para comparar las fechas de ambos registros
                            //Y si la ID del registro no es la misma a actualizar
                            if(comparacionFecha(regEntradaIni, regEntradaFin, regSQLIni, regSQLFin) == false && idEntrada != idSQL)
                            {
                                precioEntrada.addError ('Ya existe un registro con fechas similares');
                            }
                        }
                    }
                }    
            if(!listaPrecioDesechados.isEmpty())
            {
                for(CBK_Precio_Facturacion__c precioEntrada : listaPrecioDesechados)
                {
                    for(CBK_Precio_Facturacion__c precioSQL: listaSQL)
                    {
                        if(precioSQL.CC_Canal_Entrada__c == precioEntrada.CC_Canal_Entrada__c
                            && precioSQL.CC_Nombre_Empresa__c == precioEntrada.CC_Nombre_Empresa__c
                            && precioSQL.CC_Area_Negocio__c == precioEntrada.CC_Area_Negocio__c
                            )
                        {
                            //Las fechas inicio y fin del registro a insertar y de los registros de la lista QUERY
                            Datetime regEntradaIni = precioEntrada.CC_Fecha_Inicio_Vigencia__c;
                            Datetime regEntradaFin = precioEntrada.CC_Fecha_Fin_Vigencia__c;
                            Datetime regSQLIni = precioSQL.CC_Fecha_Inicio_Vigencia__c;
                            Datetime regSQLFin = precioSQL.CC_Fecha_Fin_Vigencia__c;
                            String idEntrada = precioEntrada.id;
                            String idSQL = precioSQL.id;
                            //llamamos un metodo que introducimos las fechas para comparar las fechas de ambos registros
                            //Y si la ID del registro no es la misma a actualizar
                            if(comparacionFecha(regEntradaIni, regEntradaFin, regSQLIni, regSQLFin) == false && idEntrada != idSQL)
                            {
                                precioEntrada.addError ('Ya existe un registro con fechas similares');
                            }
                        }
                    }
                }
            } 
        }
    }

    //Metodo que compara las fechas del registro insertado con los registros sacados via SQL.
    private Boolean comparacionFecha (Datetime inicioRegistroEntrada, Datetime finRegistroEntrada, Datetime inicioRegistroSQL, Datetime finRegistroSQL)
    {
        Boolean resultado = true;

        //1º Comprobar que el registro que vamos a insertar no esté dentro de las fechas inicio y fin de los demás registros.
        if(inicioRegistroEntrada <= inicioRegistroSQL && finRegistroEntrada >=  inicioRegistroSQL)
        {
            resultado = false;
        }
        //2º Si el registro SQL tiene una fecha fin vacia, es fecha infinita, con lo cual no se puede sobreescribir en ninguna fecha a continuacion 
        else if(finRegistroSQL == null && (finRegistroEntrada > inicioRegistroSQL || inicioRegistroEntrada > inicioRegistroSQL)) 
        {
            resultado = false;
        }
        //3º Si la fecha a insertar tiene fecha infinita pero en el SQL ya hay un registro por medio
        else if(finRegistroEntrada == null && (finRegistroSQL >= inicioRegistroEntrada || inicioRegistroSQL >= inicioRegistroEntrada)) 
        {
            resultado = false;
        }else 
        {
            resultado = true;
        }
        return resultado;
    }

    //Metodo para reordenar la lista de registros en base ascendente a la fecha de inicio de vigencia
    private List<CBK_Precio_Facturacion__c> ordenarLista (List<CBK_Precio_Facturacion__c> listNewObjOrdenado)
	{
        set<Datetime> setFechas = new set<Datetime>();
        List<Datetime> listaFechas = new List<Datetime>();
        List<CBK_Precio_Facturacion__c> listaOrdenada = new List<CBK_Precio_Facturacion__c>();

        //Metemos las fechas en un set para que las que se repitan se eliminen
        for(CBK_Precio_Facturacion__c preciof : listNewObjOrdenado)
        {
            setFechas.add(preciof.CC_Fecha_Inicio_Vigencia__c);
        }

        //Las insertamos en una lista para despues ordenarla  
        for(Datetime setF : setFechas)
        {
            listaFechas.add(setF);
        }
        listafechas.sort();

        //Ahora comprobamos por fechas ordenadas cuales coinciden con las fechas de la lista que nos introducen. 
        //Las que coincidan las agrega a la lista, de esa manera se van introduciendo los registros ordenados por las fechas.
        for(Datetime fechas : listaFechas)
        {
            for(CBK_Precio_Facturacion__c r : listNewObjOrdenado)
            {
                if(fechas == r.CC_Fecha_Inicio_Vigencia__c)
                {
                    listaOrdenada.add(r);
                }
            }
        }

        return listaOrdenada;
	}     

}