public class TaskUtil {  

    //public static Task createContractTask(String Owner, String RTypeId, String Account, String ECN, String Subject, String ContractId, Integer Days) {
    //    Return new Task(    OwnerId = Owner,
    //                        RecordTypeId = RTypeId,
    //                        Related_Account__c = Account,
    //                        ECN__c = ECN,                            
    //                        Priority = 'Normal', 
    //                        Status = 'In Progress', 
    //                        Subject = Subject, 
    //                        Type = 'Task',
    //                        IsReminderSet = true, 
    //                        ReminderDateTime = System.now()+Days,
    //                        WhatId = ContractId,
    //                        ActivityDate = System.today()+Days ); 
    //}

    //public static Task createOpportunityTask(String Owner, String RTypeId, String Account, String DeliveryType, String ECN, String Subject, String OpportunityId, Datetime DueDate) {  
    //    Return new Task(    OwnerId = Owner,
    //                        RecordTypeId = RTypeId,
    //                        Related_Account__c = Account,
    //                        ECN__c = ECN,                            
    //                        Delivery_Type__c = DeliveryType,
    //                        Priority = 'Normal', 
    //                        Status = 'In Progress', 
    //                        Subject = Subject, 
    //                        Type = 'Task',
    //                        WhatId = OpportunityId,
    //                        IsReminderSet = true,
    //                        ReminderDateTime = DueDate,
    //                        ActivityDate = DueDate.date() );
    //}

    //public static Task createQualifyOpportunityTask(String Owner, String RTypeId, String Account, String DeliveryType, String RegoType, String ContractType, String ECN, String Subject, String OpportunityId, Datetime DueDate) {  
    //    Return new Task(    OwnerId = Owner,
    //                        RecordTypeId = RTypeId,
    //                        Related_Account__c = Account,
    //                        ECN__c = ECN,                            
    //                        Delivery_Type__c = DeliveryType,
    //                        Registration_Type__c = RegoType,
    //                        Contract_Type__c = ContractType,
    //                        Priority = 'Normal', 
    //                        Status = 'In PRogress', 
    //                        Subject = Subject, 
    //                        Type = 'Task',
    //                        WhatId = OpportunityId,
    //                        IsReminderSet = true,
    //                        ReminderDateTime = DueDate,
    //                        ActivityDate = DueDate.date() );
    //}

    //public static Task createDealArrangementTask(String Owner, String RTypeId, eNEtt_Contract__c c, String Subject, String ContractId, Integer Days) {  
    //    Return new Task(    OwnerId = Owner,
    //                        // Subject & Task Information
    //                        Subject = Subject, 
    //                        Type = 'Task',
    //                        WhatId = ContractId,
    //                        Related_Account__c = c.Account_Name__r.Name,
    //                        ActivityDate = System.today()+Days,
    //                        Status = 'In Progress', 
    //                        Priority = 'Normal', 
    //                        ECN__c = c.Account_ECN__c,
    //                        // Required Information
    //                        Rebate_Type__c = c.Rebate_Type__c,
    //                        Incentive_Type__c = c.Incentive_Type__c,
    //                        Interchange_Amount__c = c.Interchange_Amount__c,
    //                        Fixed_Amount__c = c.Fixed_Amount__c,
    //                        Agreement_Term_Years__c = c.Agreement_Term_Years__c,
    //                        Review_Period_Months_if_applicable__c = c.Review_Period_Months_if_applicable__c, 
    //                        // Trial Information
    //                        Trial_Period__c = c.Trial_Period__c,
    //                        Trial_Period_Term_Months__c = c.Trial_Period_Term_Months__c,
    //                        // Exclusivity Information
    //                        Exclusivity_Clause__c = c.Exclusivity_Clause__c, 
    //                        Exclusivity__c = c.Exclusivity__c,
    //                        // Additional Information
    //                        Non_local_Settlement_Currency__c = c.Non_local_Settlement_Currency__c,
    //                        Deletion_of_Marketing_Clause__c = c.Deletion_of_Marketing_Clause__c,
    //                        Non_standard_Funding_Fund_on_Auth__c = c.Non_standard_Funding_Fund_on_Auth__c,
    //                        Cross_Currency_Fee_0_81__c = c.Cross_Currency_Fee_0_81__c,
    //                        Cross_Currency_Details__c = c.Cross_Currency_Details__c,
    //                        Waive_Subscription_Fee_Details__c = c.Waive_Subscription_Fee_Details__c,
    //                        Subscription_Fee__c = c.Subscription_Fee__c,
    //                        Chargeback_Processing_Fee__c = c.Chargeback_Processing_Fee__c,
    //                        Short_Term_Incentive__c = c.Short_Term_Incentive__c,
    //                        Short_Term_Incentive_Details__c = c.Short_Term_Incentive_Details__c,
    //                        Technology_Fund_API_Integration__c = c.Technology_Fund_API_Integration__c,
    //                        Technology_Fund_Details__c = c.Technology_Fund_Details__c,
    //                        Volume_Commitments__c = c.Volume_Commitments__c,
    //                        Volume_Commitments_Details__c = c.Volume_Commitments_Details__c,
    //                        WUBS__c = c.WUBS__c,
    //                        T_C_Modification_Details__c = c.T_C_Modification_Details__c,
    //                        // Tiered Information
    //                        Tiered_Rebate_Calculation_Frequency__c = c.Tiered_Rebate_Calculation_Frequency__c,
    //                        Tier_1_Interchange_Share__c = c.Tier_1_Interchange_Share__c,
    //                        Tier_1_Fixed_Share__c = c.Tier_1_Fixed_Share__c,
    //                        Tier_1_Int_Range_From__c = c.Tier_1_Int_Range_From__c,
    //                        Tier_1_Int_Range_To__c = c.Tier_1_Int_Range_To__c,
    //                        Tier_1_Fixed_Range_From__c = c.Tier_1_Fixed_Range_From__c,
    //                        Tier_1_Fixed_Range_To__c = c.Tier_1_Fixed_Range_To__c,
    //                        Tier_2_Interchange_Share__c = c.Tier_2_Interchange_Share__c,
    //                        Tier_2_Fixed_Share__c = c.Tier_2_Fixed_Share__c,
    //                        Tier_2_Int_Range_From__c = c.Tier_2_Int_Range_From__c,
    //                        Tier_2_Int_Range_To__c = c.Tier_2_Int_Range_To__c,
    //                        Tier_2_Fixed_Range_From__c = c.Tier_2_Fixed_Range_From__c,
    //                        Tier_2_Fixed_Range_To__c = c.Tier_2_Fixed_Range_To__c,
    //                        Tier_3_Interchange_Share__c = c.Tier_3_Interchange_Share__c,
    //                        Tier_3_Fixed_Share__c = c.Tier_3_Fixed_Share__c,
    //                        Tier_3_Int_Range_From__c = c.Tier_3_Int_Range_From__c,
    //                        Tier_3_Int_Range_To__c = c.Tier_3_Int_Range_To__c,
    //                        Tier_3_Fixed_Range_From__c = c.Tier_3_Fixed_Range_From__c,
    //                        Tier_3_Fixed_Range_To__c = c.Tier_3_Fixed_Range_To__c,
    //                        SLA_Required__c = c.SLA_Required__c, // SF-1430
    //                        // Sysytem & Reminder Information
    //                        IsReminderSet = true, 
    //                        ReminderDateTime = System.now()+Days,
    //                        RecordTypeId = RTypeId );
    //}

    //public static void updateContractFields (Task t, eNEtt_Contract__c c, Map<String,RecordType> rt) {
    //    if (t.RecordTypeId == rt.get('Contract_Deal_Arrangement').Id) {
    //        c.Rebate_Type__c = t.Rebate_Type__c;
    //        c.Incentive_Type__c = t.Incentive_Type__c;
    //        c.Interchange_Amount__c = t.Interchange_Amount__c;
    //        c.Fixed_Amount__c = t.Fixed_Amount__c;
    //        c.Agreement_Term_Years__c = t.Agreement_Term_Years__c;
    //        c.Review_Period_Months_if_applicable__c = t.Review_Period_Months_if_applicable__c;
    //        c.Trial_Period__c = t.Trial_Period__c;
    //        c.Trial_Period_Term_Months__c = t.Trial_Period_Term_Months__c;
    //        c.Exclusivity_Clause__c = t.Exclusivity_Clause__c; 
    //        c.Exclusivity__c = t.Exclusivity__c; 
    //        c.Non_local_Settlement_Currency__c = t.Non_local_Settlement_Currency__c;
    //        c.Deletion_of_Marketing_Clause__c = t.Deletion_of_Marketing_Clause__c;
    //        c.Non_standard_Funding_Fund_on_Auth__c = t.Non_standard_Funding_Fund_on_Auth__c;
    //        c.Cross_Currency_Fee_0_81__c = t.Cross_Currency_Fee_0_81__c;
    //        c.Cross_Currency_Details__c = t.Cross_Currency_Details__c;
    //        c.Waive_Subscription_Fee_Details__c = t.Waive_Subscription_Fee_Details__c;
    //        c.Subscription_Fee__c = t.Subscription_Fee__c;
    //        c.Chargeback_Processing_Fee__c = t.Chargeback_Processing_Fee__c;
    //        c.Short_Term_Incentive__c = t.Short_Term_Incentive__c;
    //        c.Short_Term_Incentive_Details__c = t.Short_Term_Incentive_Details__c;
    //        c.Technology_Fund_API_Integration__c = t.Technology_Fund_API_Integration__c;
    //        c.Technology_Fund_Details__c = t.Technology_Fund_Details__c;
    //        c.Volume_Commitments__c = t.Volume_Commitments__c;
    //        c.Volume_Commitments_Details__c = t.Volume_Commitments_Details__c;
    //        c.WUBS__c = t.WUBS__c;
    //        c.T_C_Modification_Details__c = t.T_C_Modification_Details__c;
    //        c.Tiered_Rebate_Calculation_Frequency__c = t.Tiered_Rebate_Calculation_Frequency__c; 
    //        c.Tier_1_Interchange_Share__c = t.Tier_1_Interchange_Share__c;
    //        c.Tier_1_Fixed_Share__c = t.Tier_1_Fixed_Share__c;
    //        c.Tier_1_Int_Range_From__c = t.Tier_1_Int_Range_From__c;
    //        c.Tier_1_Int_Range_To__c = t.Tier_1_Int_Range_To__c;
    //        c.Tier_1_Fixed_Range_From__c = t.Tier_1_Fixed_Range_From__c;
    //        c.Tier_1_Fixed_Range_To__c = t.Tier_1_Fixed_Range_To__c;
    //        c.Tier_2_Interchange_Share__c = t.Tier_2_Interchange_Share__c;
    //        c.Tier_2_Fixed_Share__c = t.Tier_2_Fixed_Share__c;
    //        c.Tier_2_Int_Range_From__c = t.Tier_2_Int_Range_From__c;
    //        c.Tier_2_Int_Range_To__c = t.Tier_2_Int_Range_To__c;
    //        c.Tier_2_Fixed_Range_From__c = t.Tier_2_Fixed_Range_From__c;
    //        c.Tier_2_Fixed_Range_To__c = t.Tier_2_Fixed_Range_To__c;
    //        c.Tier_3_Interchange_Share__c = t.Tier_3_Interchange_Share__c;
    //        c.Tier_3_Fixed_Share__c = t.Tier_3_Fixed_Share__c;
    //        c.Tier_3_Int_Range_From__c = t.Tier_3_Int_Range_From__c;
    //        c.Tier_3_Int_Range_To__c = t.Tier_3_Int_Range_To__c; 
    //        c.Tier_3_Fixed_Range_From__c = t.Tier_3_Fixed_Range_From__c;
    //        c.Tier_3_Fixed_Range_To__c = t.Tier_3_Fixed_Range_To__c; 
    //        c.SLA_Required__c = t.SLA_Required__c; // SF-1430
    //        }
    //}

}