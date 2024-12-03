/**
* @description Clase dummy para clonado y uso en Framework de fusiones
*/
public class CBK_fusion_custom implements Callable {
     /**
     * @description Método Core
     * @param idFusion  : Id del la entidad fusión
     */
    public static boolean exec(CBK_Fusion__c fus) {
        string resultado='OK';
        
        fus.resultado__c=resultado;

        System.debug('Merge: ' + fus.Id);
        return true;
    }
    
    /**
     * @description  Callable::call() implementation, calling static function (completeTask, rather than this.completeTask)
     */
    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'exec' {
                return exec((CBK_Fusion__c)args.get('reg'));
            }
            when else {
                throw new CalloutException('Method not implemented');
            }
        }
    }    
}