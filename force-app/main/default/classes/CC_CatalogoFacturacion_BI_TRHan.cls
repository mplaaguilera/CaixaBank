/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 06-23-2022
 * @last modified by  : Adrian Mariscal 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06-23-2022   Adrian Mariscal   Initial Version
**/
public with sharing class CC_CatalogoFacturacion_BI_TRHan extends CC_TriggerHandlerBase 
{
    public override void mainEntry (CC_TriggerParameters tp)
    {
        process((List<CBK_CatalogoFacturacion__c>)tp.newList, (Map<Id, CBK_CatalogoFacturacion__c>)tp.newMap);
    }

    private void process(List<CBK_CatalogoFacturacion__c> listNewObj, Map<Id, CBK_CatalogoFacturacion__c> mapNewObj) 
    {
        System.debug('CatalogoFacturacion BI');
        
        // Extraemos la Id del recordtype para que se haga la busqueda solo de ese tipo
	    Id catalogoFacturacionRT = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        
		//creamos una lista del object para luego procesar el registro entrante
		List<CBK_CatalogoFacturacion__c> listaCatalogo =  new List<CBK_CatalogoFacturacion__c>();

        //Creamos una lista con todos los registros ordenados por fechas, de esta manera aseguramos un correcto procesamiento de registros
        List<CBK_CatalogoFacturacion__c> listaCatalogoOrdenado = ordenarLista(listNewObj);
        set<CBK_CatalogoFacturacion__c> listaCatalogoDesechados = new set<CBK_CatalogoFacturacion__c>();
        List<CBK_CatalogoFacturacion__c> listaCatalogoFinal =  new List<CBK_CatalogoFacturacion__c>();

        //Creamos sets para meter unos campos que no queremos que sean repetidos.
        set<String> setcanalProcedencia = new set<String>();
        set<String> setcanalOperativo = new set<String>();
        set<String> setTematica = new set<String>();
        set<String> setProducto = new set<String>();
        set<String> setAreaNegocio = new set<String>();
        set<String> setNegocio = new set<String>();
        //set<String> setGrupoFacturacion = new set<String>();	
        
		//recorremos el listado que nos ha entrado, si coincide el recordType ID, entonces añadimos el registro en la nueva lista 
		for(CBK_CatalogoFacturacion__c catalogoft : listaCatalogoOrdenado)
        {
			if(catalogoft.recordtypeId == catalogoFacturacionRT)
            {
                //Si la lista está vacia metemos el primer registro ya que no tiene ninguno con quien comparar
                //Y se añaden los campos obligatorios en un set para registrar los distintos valores, al ser un set ningun valor se repetirá
                if(listaCatalogo.isEmpty())
                {
                listaCatalogo.add(catalogoft);
                setcanalProcedencia.add(catalogoft.CC_Canal_de_Procedencia__c);
                setcanalOperativo.add(catalogoft.CC_Canal_Operativo__c);
                setTematica.add(catalogoft.CC_Tematica__c);
                setProducto.add(catalogoft.CC_Producto__c);
                setAreaNegocio.add(catalogoft.CC_Area_Negocio__c);
                setNegocio.add(catalogoft.CC_Negocio__c);
                //setGrupoFacturacion.add(catalogoft.CC_Grupo_Facturacion__c);
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

                    for(CBK_CatalogoFacturacion__c catalogocheck : listaCatalogo)
                    {
                        //Las fechas inicio y fin del registro a insertar y de los registros que ya han sido comprobados
                        Datetime regEntradaIni = catalogoft.CC_Fecha_Inicio_Vigencia__c;
                        Datetime regEntradaFin = catalogoft.CC_Fecha_Fin_Vigencia__c;
                        Datetime regCheckIni = catalogocheck.CC_Fecha_Inicio_Vigencia__c;
                        Datetime regCheckFin = catalogocheck.CC_Fecha_Fin_Vigencia__c;

                       //Comrpobamos que los registros a comparar coincidan todos los campos, de esta manera evitamos colisiones erroneas
                        if(catalogoft.CC_Canal_de_Procedencia__c == catalogocheck.CC_Canal_de_Procedencia__c
                        && catalogoft.CC_Canal_Operativo__c == catalogocheck.CC_Canal_Operativo__c
                        && catalogoft.CC_Tematica__c == catalogocheck.CC_Tematica__c
                        && catalogoft.CC_Producto__c == catalogocheck.CC_Producto__c
                        && catalogoft.CC_Area_Negocio__c == catalogocheck.CC_Area_Negocio__c
                        && catalogoft.CC_Negocio__c == catalogocheck.CC_Negocio__c
                       /* && catalogoft.CC_Grupo_Facturacion__c == catalogocheck.CC_Grupo_Facturacion__c*/)
                        {
                            //llamamos un metodo que introducimos las fechas para comparar las fechas de ambos registros, si no hay choque de fechas
                            //Devuelve true 
                            if (comparacionFecha(regEntradaIni, regEntradaFin, regCheckIni, regCheckFin) == false)
                            {
                                longitud = false;
                                listaCatalogoDesechados.add(catalogoft);
                                setcanalProcedencia.add(catalogoft.CC_Canal_de_Procedencia__c);
                                setcanalOperativo.add(catalogoft.CC_Canal_Operativo__c);
                                setTematica.add(catalogoft.CC_Tematica__c);
                                setProducto.add(catalogoft.CC_Producto__c);
                                setNegocio.add(catalogoft.CC_Negocio__c);
                                //setGrupoFacturacion.add(catalogoft.CC_Grupo_Facturacion__c);
                            }
                        }
                        //Si en ningun momento se detecto un error en la comprobación de cada campo, la agrega a la lista
                        //Y se añaden los campos obligatorios en un set para registrar los distintos valores, al ser un set ningun valor se repetirá
                    }
                    if (longitud == true)
                    {
                        listaCatalogo.add(catalogoft);
                        setcanalProcedencia.add(catalogoft.CC_Canal_de_Procedencia__c);
                        setcanalOperativo.add(catalogoft.CC_Canal_Operativo__c);
                        setTematica.add(catalogoft.CC_Tematica__c);
                        setProducto.add(catalogoft.CC_Producto__c);
                        setAreaNegocio.add(catalogoft.CC_Area_Negocio__c);
                        setNegocio.add(catalogoft.CC_Negocio__c);
                        //setGrupoFacturacion.add(catalogoft.CC_Grupo_Facturacion__c);
                    }               
                }
			}     
		}

        //Si la lista no está vacia, creamos una query con una lista todos los campos que coincidan
        //Y la agregamos a otra lista con todas las coincidencias encontradas
        if(!listaCatalogo.isEmpty())
        { 
            List<CBK_CatalogoFacturacion__c> listaSQL = [SELECT id, CC_Canal_de_Procedencia__c, CC_Canal_Operativo__c, CC_Tematica__c, CC_Producto__c
                                            ,CC_Fecha_Inicio_Vigencia__c, CC_Fecha_Fin_Vigencia__c, CC_Area_Negocio__c, CC_Negocio__c/*, CC_Grupo_Facturacion__c*/ FROM CBK_CatalogoFacturacion__c WHERE
                                              CC_Canal_de_Procedencia__c IN :setcanalProcedencia  
                                              AND CC_Canal_Operativo__c IN :setcanalOperativo
                                              AND CC_Tematica__c IN :setTematica
                                              AND CC_Producto__c IN :setProducto 
                                              AND CC_Area_Negocio__c IN :setAreaNegocio
                                              AND CC_Negocio__c IN :setNegocio
                                              /*AND CC_Grupo_Facturacion__c IN :setGrupoFacturacion*/ 
                                              ORDER BY CC_Fecha_Inicio_Vigencia__c ASC];  
                Integer sqlSize = listaSQL.size();
            
        
                //Realizamos una comparacion entre el registro y la lista SQL
                for(CBK_CatalogoFacturacion__c catalogoEntrada : listaCatalogo)
                {
                    Boolean longitud = true;
                    
                    //En este bucle vamos añadiendo los resultados de la lista de SQL a una lista final donde se hayarán todos los registros que no colisionen
                    //Para posteriormente procesarlos con los desechados en caso de que alguno de ellos al final si puedan ser insertados.
                    for(CBK_CatalogoFacturacion__c catalogoSQL: listaSQL)
                    {
                        listaCatalogoFinal.add(catalogoSQL); 

                        if(catalogoSQL.CC_Canal_de_Procedencia__c == catalogoEntrada.CC_Canal_de_Procedencia__c
                            && catalogoSQL.CC_Canal_Operativo__c == catalogoEntrada.CC_Canal_Operativo__c
                            && catalogoSQL.CC_Tematica__c == catalogoEntrada.CC_Tematica__c
                            && catalogoSQL.CC_Producto__c == catalogoEntrada.CC_Producto__c
                            && catalogoSQL.CC_Area_Negocio__c == catalogoEntrada.CC_Area_Negocio__c
                            && catalogoSQL.CC_Negocio__c == catalogoEntrada.CC_Negocio__c
                            /*&& catalogoSQL.CC_Grupo_Facturacion__c == catalogoEntrada.CC_Grupo_Facturacion__c*/)
                        {
                            //Las fechas inicio y fin del registro a insertar y de los registros de la lista QUERY
                            Datetime regEntradaIni = catalogoEntrada.CC_Fecha_Inicio_Vigencia__c;
                            Datetime regEntradaFin = catalogoEntrada.CC_Fecha_Fin_Vigencia__c;
                            Datetime regSQLIni = catalogoSQL.CC_Fecha_Inicio_Vigencia__c;
                            Datetime regSQLFin = catalogoSQL.CC_Fecha_Fin_Vigencia__c;
                            //llamamos un metodo que introducimos las fechas para comparar las fechas de ambos registros
                            if(comparacionFecha(regEntradaIni, regEntradaFin, regSQLIni, regSQLFin) == false)
                            {
                                longitud = false;
                                catalogoEntrada.addError ('Ya existe un registro con fechas similares');
                            }
                            
                            if(longitud == true) 
                            {
                             listaCatalogoFinal.add(catalogoEntrada);   
                            }
                        }
                    }
                }
                //Si no existe ningun registro en el listado SQL, se insertará la lista de registros actuales.
                if (listaSQL.isEmpty())
                {
                    listaCatalogoFinal = listaCatalogo;
                }
            
                /*
                Este es el proceso final donde comprobamos por segunda vez si los registros desechados pueden o no ser insertados 
                */
            if(!listaCatalogoDesechados.isEmpty())
            {
                
                for(CBK_CatalogoFacturacion__c catalogoEntrada : listaCatalogoDesechados)
                {
                    for(CBK_CatalogoFacturacion__c catalogoSQL: listaCatalogoFinal)
                    {
                        if(catalogoSQL.CC_Canal_de_Procedencia__c == catalogoEntrada.CC_Canal_de_Procedencia__c
                            && catalogoSQL.CC_Canal_Operativo__c == catalogoEntrada.CC_Canal_Operativo__c
                            && catalogoSQL.CC_Tematica__c == catalogoEntrada.CC_Tematica__c
                            && catalogoSQL.CC_Producto__c == catalogoEntrada.CC_Producto__c
                            && catalogoSQL.CC_Area_Negocio__c == catalogoEntrada.CC_Area_Negocio__c
                            && catalogoSQL.CC_Negocio__c == catalogoEntrada.CC_Negocio__c
                            /*&& catalogoSQL.CC_Grupo_Facturacion__c == catalogoEntrada.CC_Grupo_Facturacion__c*/)
                        {
                            //Las fechas inicio y fin del registro a insertar y de los registros de la lista QUERY
                            Datetime regEntradaIni = catalogoEntrada.CC_Fecha_Inicio_Vigencia__c;
                            Datetime regEntradaFin = catalogoEntrada.CC_Fecha_Fin_Vigencia__c;
                            Datetime regSQLIni = catalogoSQL.CC_Fecha_Inicio_Vigencia__c;
                            Datetime regSQLFin = catalogoSQL.CC_Fecha_Fin_Vigencia__c;
                            //llamamos un metodo que introducimos las fechas para comparar las fechas de ambos registros
                            //Y si la ID del registro no es la misma a actualizar
                            if(comparacionFecha(regEntradaIni, regEntradaFin, regSQLIni, regSQLFin) == false)
                            {
                                catalogoEntrada.addError ('Ya existe un registro con fechas similares');
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
        if(inicioRegistroEntrada >= inicioRegistroSQL && finRegistroEntrada <= finRegistroSQL)
        {
            resultado = false;
        }
        //2º Si la fecha inicio está en un rango de horarios permitidos pero la fecha fin está pisando las fechas de otros registros.
        else if(inicioRegistroEntrada <= inicioRegistroSQL && finRegistroEntrada >=  inicioRegistroSQL) 
        {
            resultado = false;
        }
        //3º Si el registro SQL tiene una fecha fin vacia, es fecha infinita, con lo cual no se puede sobreescribir en ninguna fecha a continuacion 
        else if(finRegistroSQL == null && (finRegistroEntrada >= inicioRegistroSQL || inicioRegistroEntrada >= inicioRegistroSQL)) 
        {
            resultado = false;
        }
        //4º Si la fecha a insertar tiene fecha infinita pero en el SQL ya hay un registro por medio
        else if(finRegistroEntrada == null && (finRegistroSQL >= inicioRegistroEntrada || inicioRegistroSQL >= inicioRegistroEntrada)) 
        {
            resultado = false;
        //5º Si la fecha inicio esta dentro del rango de inicio y fin del registro SQL
        }else if(inicioRegistroEntrada >= inicioRegistroSQL && inicioRegistroEntrada <=  finRegistroSQL) 
        {
            resultado = false;
        }else 
        {
            resultado = true;
        }
        return resultado;
    }
 
    //Metodo para reordenar la lista de registros en base ascendente a la fecha de inicio de vigencia
    private List<CBK_CatalogoFacturacion__c> ordenarLista (List<CBK_CatalogoFacturacion__c> listNewObjOrdenado)
	{

        set<Datetime> setFechas = new set<Datetime>();
        List<Datetime> listaFechas = new List<Datetime>();
        List<CBK_CatalogoFacturacion__c> listaOrdenada = new List<CBK_CatalogoFacturacion__c>();

        //Metemos las fechas en un set para que las que se repitan se eliminen
        for(CBK_CatalogoFacturacion__c catalogof : listNewObjOrdenado)
        {
            setFechas.add(catalogof.CC_Fecha_Inicio_Vigencia__c);
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
            for(CBK_CatalogoFacturacion__c r : listNewObjOrdenado)
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