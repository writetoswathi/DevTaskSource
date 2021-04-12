public without sharing class MetadataTriggerManager {

    public class ClassNotFoundException extends Exception {}
    private string strCurrentObjectName;
    
    @TestVisible
    private static List<Trigger_Handler__mdt> listMockMetadata;

    private TriggerEventsToTriggerHandlers theseEventsToTriggerHandlers;
    
    @TestVisible
    private static TriggerObjectToEventsToHandlers sObjectNameToEventsToTriggerHandlers = new TriggerObjectToEventsToHandlers();

    public MetadataTriggerManager() {
        if(Trigger.new != null) {
            init(Trigger.new.getSObjectType());
        } else {
            init(Trigger.old.getSObjectType());
        }
    }

    public MetadataTriggerManager(sObjectType objectType) {
        init(objectType);
    }

    public void init(sObjectType objectType) {
        String strObjectName = objectType.getDescribe().getName();

        theseEventsToTriggerHandlers = sObjectNameToEventsToTriggerHandlers.get(strObjectName);
        sObjectNameToEventsToTriggerHandlers = new TriggerObjectToEventsToHandlers();

        if(theseEventsToTriggerHandlers == null) {
            if(Test.isRunningTest() && listMockMetadata != null) {
                sObjectNameToEventsToTriggerHandlers.putAll(listMockMetadata);
            } else {
                sObjectNameToEventsToTriggerHandlers.putAll(
                [SELECT DeveloperName, NamespacePrefix, Event__c, sObject__c, Class_Name__c, Order__c
                FROM Trigger_Handler__mdt
                WHERE sObject__c = :strObjectName AND Active__c = true
                ORDER BY Order__c ASC]);
            }
            theseEventsToTriggerHandlers = sObjectNameToEventsToTriggerHandlers.get(objectType.getDescribe().getName());
        }
    }

    public static String triggerFlagsToString(boolean bIsBefore, boolean bIsUpdate, boolean bIsInsert, boolean bIsDelete, boolean bIsUndelete) {
        String strReturnVal = bIsBefore ? 'Before' : 'After';

        if(bIsInsert) {
            strReturnVal += 'Insert';
        } else if(bIsUpdate) {
            strReturnVal += 'Update';
        } 
        /*
        else if(bIsDelete) {
            strReturnVal += 'Delete';
        } else {
            strReturnVal += 'Undelete';
        } */

        return strReturnVal;
    }

    public void handle() {
        //Removing validateRun as this is being handled in TriggerHandler class
        //if(validateRun()){
            handle(Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert, Trigger.isDelete, Trigger.isUndelete, Trigger.old, Trigger.new, Trigger.oldMap);
        //}
    }

    public void handle(boolean bIsBefore, boolean bIsUpdate, boolean bIsInsert, boolean bIsDelete, boolean bIsUndelete, List<sObject> listOld, List<sObject> listNew, Map<Id, sObject> mapOld) {
        if(theseEventsToTriggerHandlers == null) {
            return;
        }
        String strEvent = triggerFlagsToString(bIsBefore, bIsUpdate, bIsInsert, bIsDelete, bIsUndelete);
        List<Trigger_Handler__mdt> listTheseTriggerHandlers = theseEventsToTriggerHandlers.getTriggerHandlers(strEvent);

        if(listTheseTriggerHandlers == null) {
            return;
        }

        for(Trigger_Handler__mdt thisTriggerHandler : listTheseTriggerHandlers) {
            Type handlerType = Type.forName(thisTriggerHandler.NamespacePrefix, thisTriggerHandler.Class_Name__c);
            if(handlerType == null) {
                throw new ClassNotFoundException('MetaDataTriggerManager: handler class not found for ' + thisTriggerHandler);
            } else {
                if(bIsBefore) {
                /*
                    if(bIsUpdate) {
                  //      ((BeforeUpdate)handlerType.newInstance()).handleBeforeUpdate(listNew, mapOld);
                    } else if(bIsInsert) {
                  //      ((BeforeInsert)handlerType.newInstance()).handleBeforeInsert(listNew);
                    } else if(bIsDelete) {
                  //      ((BeforeDelete)handlerType.newInstance()).handleBeforeDelete(listOld);
                    } else if(bIsUndelete) {
                  //      ((BeforeUndelete)handlerType.newInstance()).handleBeforeUndelete(listNew);
                    }
                    */
                } else {
                    if(bIsUpdate) {
                  //      ((AfterUpdate)handlerType.newInstance()).handleAfterUpdate(listNew, mapOld);
                    } else if(bIsInsert) {
                        ((AfterInsert)handlerType.newInstance()).handleAfterInsert(listNew);
                    } else if(bIsDelete) {
                  //      ((AfterDelete)handlerType.newInstance()).handleAfterDelete(listOld);
                    } else if(bIsUndelete) {
                 //       ((AfterUndelete)handlerType.newInstance()).handleAfterUndelete(listNew);
                    }
                }
            }
        }
    }
}