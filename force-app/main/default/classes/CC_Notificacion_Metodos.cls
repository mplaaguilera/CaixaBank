public with sharing class CC_Notificacion_Metodos {

    /*******************************************************************************************************
    * @description Envia una notificación a un usuario
    * @param recipientIds Lista de IDs de usuarios o grupos que recibirán la notificación
    * @param targetId El ID del objeto que se está notificando
    * @param titulo El título de la notificación
    * @param contenidoMensaje El contenido de la notificación
    ********************************************************************************************************/
    public static Boolean enviarNotificacion(Set<String> recipientIds, Id targetId, String titulo, String notificationTypeId, String contenidoMensaje) {
        Boolean hayError = false;   
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(titulo);
        notification.setBody(contenidoMensaje);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(targetId);

        // Actually send the notification
        try {
            notification.send(recipientIds);
            System.debug('CC_Notificacion_Metodos: Notificación enviada correctamente');
        }
        catch (Exception e) {
            System.debug('CC_Notificacion_Metodos: Error al enviar la notificación: ' + e.getMessage());
            hayError = true;
        }
        return hayError;
    }  
}