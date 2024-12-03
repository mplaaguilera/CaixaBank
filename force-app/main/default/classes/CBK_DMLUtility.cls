/**
 * @description Esta clase proporciona utilidades para operaciones DML.
 */
public without sharing class CBK_DMLUtility {

   /**
     * Inserta una lista de sObjects y captura cualquier error que ocurra.
     * @param sObjectList Lista de sObjects a insertar.
     * @description Esta función proporciona utilidades para operaciones inserción de registros DML.
     * @return Lista de Database.SaveResult que contiene el resultado de la operación.
     */
    public static List<Database.SaveResult> insertRecords(List<sObject> sObjectList) {
        List<Database.SaveResult> results = Database.insert(sObjectList, false);

        // Manejo de errores específicos de cada operación
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                // La operación falló, obtener todos los errores
                for (Database.Error err : sr.getErrors()) {
                    List<Object> detalle = new List<Object>{
                        'Status: ' + err.getStatusCode(),
                        'Message: ' + err.getMessage(),
                        'Fields: ' + err.getFields()
                    };
                    CBK_Log.addError(null, new CustomException('Insert Error: ' + err.getMessage()), 'Error en operación de Insertar', detalle, null);
                }
            }
        }

        // Insertar los errores en la base de datos
        CBK_Log.insertDML();

        return results;
    }



     /**
     * Método para actualizar registros.
     * @description Esta función proporciona utilidades para operaciones actualización de registros DML.
     */
    public static List<Database.SaveResult> updateRecords(List<sObject> sObjectList) {
        List<Database.SaveResult> results = Database.update(sObjectList, false);

        // Manejo de errores específicos de cada operación
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    List<Object> detalle = new List<Object>{
                        'Status: ' + err.getStatusCode(),
                        'Message: ' + err.getMessage(),
                        'Fields: ' + err.getFields()
                    };
                    CBK_Log.addError(null, new CustomException('Update Error: ' + err.getMessage()), 'Error en operación de Actualizar', detalle, null);
                }
            }
        }

        // Insertar los errores en la base de datos
        CBK_Log.insertDML();

        return results;
    }

    /**
     * @description Esta función proporciona utilidades para operaciones borrado de registros DML.
     * Método para eliminar registros.
     */
    public static List<Database.DeleteResult> deleteRecords(List<sObject> sObjectList) {
        List<Database.DeleteResult> results = Database.delete(sObjectList, false);

        // Manejo de errores específicos de cada operación
        for (Database.DeleteResult dr : results) {
            if (!dr.isSuccess()) {
                for (Database.Error err : dr.getErrors()) {
                    List<Object> detalle = new List<Object>{
                        'Status: ' + err.getStatusCode(),
                        'Message: ' + err.getMessage(),
                        'Fields: ' + err.getFields()
                    };
                    CBK_Log.addError(null, new CustomException('Delete Error: ' + err.getMessage()), 'Error en operación de Borrar', detalle, null);
                }
            }
        }

        // Insertar los errores en la base de datos
        CBK_Log.insertDML();

        return results;
    }

     // Excepción personalizada
     public class CustomException extends Exception {}

}