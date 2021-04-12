/*
 * Author   : Swathi
 * Purpose  : Trigger for TransactionItem__c which handles all the events.
 * 
 * Revision  doc        Release              Modified By     Description
 * --------  -----      --------------       --------------  -------------
 * 1.0       CR10496    12-Apr-2021          09-Apr-2021     Swathi--Send all the transaction items related to a transaction -API call
 
 * 
 * NOTE: Strictly NO business logics inside this trigger.
 */

trigger TransactionItemTrigger on TransactionItem__c (before insert, before update,before delete, after insert, after update, after delete, after undelete) {
     (new MetaDataTriggerManager()).handle();
}