public class PT_Utils {  

    public static integer getContractApprovalLevel (String rebateType, String incentiveType, 
                                                    Decimal interchangeAmount, Decimal fixedAmount, 
                                                    Decimal maxInterchangeShare, Decimal maxFixedShare, 
                                                    Boolean tCModifications) {
        Integer Approval_Level = 0;

        if (((rebateType == 'Flat' && incentiveType == '% of Interchange') && (interchangeAmount <= 25)) || 
            ((rebateType == 'Flat' && incentiveType == 'Fixed %') && (fixedAmount <= 0.5)) ||
            ((rebateType == 'Tiered' && incentiveType == '% of Interchange') && (maxInterchangeShare <= 25)) || 
            ((rebateType == 'Tiered' && incentiveType == 'Fixed %') && (maxFixedShare <= 0.5))) { 
            if (!tCModifications) {
                Approval_Level = 0;
            } else {
                Approval_Level = 1;
            }
        } else if (((rebateType == 'Flat' && incentiveType == '% of Interchange') && (interchangeAmount > 25 && interchangeAmount <= 40)) || 
            ((rebateType == 'Flat' && incentiveType == 'Fixed %') && (fixedAmount > 0.5 && fixedAmount <= 0.8)) ||
            ((rebateType == 'Tiered' && incentiveType == '% of Interchange') && (maxInterchangeShare > 25 && maxInterchangeShare <= 40)) || 
            ((rebateType == 'Tiered' && incentiveType == 'Fixed %') && (maxFixedShare > 0.5 && maxFixedShare <= 0.8))) {
            Approval_Level = 1;
        }  else if (((rebateType == 'Flat' && incentiveType == '% of Interchange') && (interchangeAmount > 40 && interchangeAmount <= 50)) || 
            ((rebateType == 'Flat' && incentiveType == 'Fixed %') && (fixedAmount > 0.8 && fixedAmount <= 1)) ||
            ((rebateType == 'Tiered' && incentiveType == '% of Interchange') && (maxInterchangeShare > 40 && maxInterchangeShare <= 50)) || 
            ((rebateType == 'Tiered' && incentiveType == 'Fixed %') && (maxFixedShare > 0.8 && maxFixedShare <= 1))) {
            Approval_Level = 2;
        } else if (((rebateType == 'Flat' && incentiveType == '% of Interchange') && (interchangeAmount > 50)) || 
            ((rebateType == 'Flat' && incentiveType == 'Fixed %') && (fixedAmount > 1)) ||
            ((rebateType == 'Tiered' && incentiveType == '% of Interchange') && (maxInterchangeShare > 50)) || 
            ((rebateType == 'Tiered' && incentiveType == 'Fixed %') && (maxFixedShare > 1))) {
            Approval_Level = 3;
        } else {
            Approval_Level = 0;
        }
        return Approval_Level;
    }

    public static Process_Task__c createContractPT(String Owner, String RTypeId, String Account, String ECN, String Subject, String ContractId, Integer Days) {
        Return new Process_Task__c(    OwnerId = Owner,
                            RecordTypeId = RTypeId,
                            Related_Account__c = Account,
                            ECN__c = ECN,                            
                            Status__c = 'In Progress', 
                            Subject__c = Subject, 
                            Task_Type__c = 'Task',
                            eNett_Contract__c = ContractId,
                            eNett_Contract_Task_Open__c = ContractId,
                            Due_Date__c = System.today()+Days );
    }

    public static Process_Task__c createContractPT(String Owner, String RTypeId, String Account, String ECN, String Subject, String ContractId, String ContractType, Integer Days) {
        Return new Process_Task__c(    OwnerId = Owner,
                            RecordTypeId = RTypeId,
                            Related_Account__c = Account,
                            ECN__c = ECN,                            
                            Status__c = 'In Progress', 
                            Subject__c = Subject, 
                            Task_Type__c = 'Task',
                            eNett_Contract__c = ContractId,
                            Contract_Type__c = ContractType,
                            eNett_Contract_Task_Open__c = ContractId,
                            Due_Date__c = System.today()+Days );
    }

    public static Process_Task__c createOpportunityPT(String Owner, String RTypeId, String Account, String DeliveryType, String ECN, String Subject, String OpportunityId, Datetime DueDate) {  
        Return new Process_Task__c(    OwnerId = Owner,
                            RecordTypeId = RTypeId,
                            Related_Account__c = Account,
                            ECN__c = ECN,                            
                            Delivery_Type__c = DeliveryType,
                            Status__c = 'In Progress', 
                            Subject__c = Subject, 
                            Task_Type__c = 'Task',
                            Opportunity__c = OpportunityId,
                            Opportunity_Task_Open__c = OpportunityId,
                            Due_Date__c = DueDate.date() ); 
    }

    public static Process_Task__c createQualifyOpportunityPT(String Owner, String RTypeId, String Account, String AccountId, String DeliveryType, String RegoType, String ContractType, String ECN, String Subject, String OpportunityId, String ISOCode, Datetime DueDate) {  
        Return new Process_Task__c(    OwnerId = Owner,
                            RecordTypeId = RTypeId,
                            Related_Account__c = Account,
                            Account__c = AccountId,
                            ECN__c = ECN,                            
                            Delivery_Type__c = DeliveryType,
                            Registration_Type__c = RegoType,
                            Contract_Type__c = ContractType,
                            Status__c = 'In Progress', 
                            Subject__c = Subject, 
                            Task_Type__c = 'Task',
                            Opportunity__c = OpportunityId,
                            Opportunity_Task_Open__c = OpportunityId,
                            CurrencyIsoCode = ISOCode,
                            Due_Date__c = DueDate.date() );
    }

    public static Process_Task__c createDealArrangementPT(String Owner, String RTypeId, eNEtt_Contract__c c, String Subject, String ContractId, Integer Days) {  
        Return new Process_Task__c(    OwnerId = Owner,
                            // Subject & Task Information
                            Subject__c = Subject, 
                            Task_Type__c = 'Task',
                            eNett_Contract__c = ContractId,
                            eNett_Contract_Task_Open__c = ContractId,
                            Related_Account__c = c.Account_Name__r.Name,
                            Status__c = 'In Progress', 
                            ECN__c = c.Account_ECN__c,
                            Rebate_Type__c = c.Rebate_Type__c,
                            Incentive_Type__c = c.Incentive_Type__c,
                            Interchange_Amount__c = c.Interchange_Amount__c,
                            Fixed_Amount__c = c.Fixed_Amount__c,
                            Agreement_Term_Years__c = c.Agreement_Term_Years__c,
                            Review_Period_Months_if_applicable__c = c.Review_Period_Months_if_applicable__c, 
                            // Trial Information
                            Trial_Period__c = c.Trial_Period__c,
                            Trial_Period_Term_Months__c = c.Trial_Period_Term_Months__c,
                            // Exclusivity Information
                            Exclusivity_Clause__c = c.Exclusivity_Clause__c, 
                            Exclusivity__c = c.Exclusivity__c,
                            // Additional Information
                            Non_local_Settlement_Currency__c = c.Non_local_Settlement_Currency__c,
                            Deletion_of_Marketing_Clause__c = c.Deletion_of_Marketing_Clause__c,
                            Non_standard_Funding_Fund_on_Auth__c = c.Non_standard_Funding_Fund_on_Auth__c,
                            Cross_Currency_Fee_0_81__c = c.Cross_Currency_Fee_0_81__c,
                            Waive_Subscription_Fee_Details__c = c.Waive_Subscription_Fee_Details__c,
                            Subscription_Fee__c = c.Subscription_Fee__c,
                            Chargeback_Processing_Fee__c = c.Chargeback_Processing_Fee__c,
                            Short_Term_Incentive__c = c.Short_Term_Incentive__c,
                            Short_Term_Incentive_Details__c = c.Short_Term_Incentive_Details__c,
                            Technology_Fund_API_Integration__c = c.Technology_Fund_API_Integration__c,
                            Technology_Fund_Details__c = c.Technology_Fund_Details__c,
                            Volume_Commitments__c = c.Volume_Commitments__c,
                            Volume_Commitments_Details__c = c.Volume_Commitments_Details__c,
                            WUBS__c = c.WUBS__c,
                            T_C_Modification_Details__c = c.T_C_Modification_Details__c,
                            // Tiered Information
                            Tiered_Rebate_Calculation_Frequency__c = c.Tiered_Rebate_Calculation_Frequency__c,
                            Tier_1_Interchange_Share__c = c.Tier_1_Interchange_Share__c,
                            Tier_1_Fixed_Share__c = c.Tier_1_Fixed_Share__c,
                            Tier_1_Int_Range_From__c = c.Tier_1_Int_Range_From__c,
                            Tier_1_Int_Range_To__c = c.Tier_1_Int_Range_To__c,
                            Tier_1_Fixed_Range_From__c = c.Tier_1_Fixed_Range_From__c,
                            Tier_1_Fixed_Range_To__c = c.Tier_1_Fixed_Range_To__c,
                            Tier_2_Interchange_Share__c = c.Tier_2_Interchange_Share__c,
                            Tier_2_Fixed_Share__c = c.Tier_2_Fixed_Share__c,
                            Tier_2_Int_Range_From__c = c.Tier_2_Int_Range_From__c,
                            Tier_2_Int_Range_To__c = c.Tier_2_Int_Range_To__c,
                            Tier_2_Fixed_Range_From__c = c.Tier_2_Fixed_Range_From__c,
                            Tier_2_Fixed_Range_To__c = c.Tier_2_Fixed_Range_To__c,
                            Tier_3_Interchange_Share__c = c.Tier_3_Interchange_Share__c,
                            Tier_3_Fixed_Share__c = c.Tier_3_Fixed_Share__c,
                            Tier_3_Int_Range_From__c = c.Tier_3_Int_Range_From__c,
                            Tier_3_Int_Range_To__c = c.Tier_3_Int_Range_To__c,
                            Tier_3_Fixed_Range_From__c = c.Tier_3_Fixed_Range_From__c,
                            Tier_3_Fixed_Range_To__c = c.Tier_3_Fixed_Range_To__c,
                            Tier_4_Interchange_Share__c = c.Tier_4_Interchange_Share__c,
                            Tier_4_Fixed_Share__c = c.Tier_4_Fixed_Share__c,
                            Tier_4_Int_Range_From__c = c.Tier_4_Int_Range_From__c,
                            Tier_4_Int_Range_To__c = c.Tier_4_Int_Range_To__c,
                            Tier_4_Fixed_Range_From__c = c.Tier_4_Fixed_Range_From__c,
                            Tier_4_Fixed_Range_To__c = c.Tier_4_Fixed_Range_To__c,
                            Tier_5_Interchange_Share__c = c.Tier_5_Interchange_Share__c,
                            Tier_5_Fixed_Share__c = c.Tier_5_Fixed_Share__c,
                            Tier_5_Int_Range_From__c = c.Tier_5_Int_Range_From__c,
                            Tier_5_Int_Range_To__c = c.Tier_5_Int_Range_To__c,
                            Tier_5_Fixed_Range_From__c = c.Tier_5_Fixed_Range_From__c,
                            Tier_5_Fixed_Range_To__c = c.Tier_5_Fixed_Range_To__c,                           
                            SLA_Required__c = c.SLA_Required__c, // SF-1430
                            // Sysytem & Reminder Information
                            CurrencyIsoCode = c.CurrencyIsoCode, 
                            Due_Date__c = System.today()+Days, 
                            RecordTypeId = RTypeId );
    }

    public static void updateContractFields (Process_Task__c pt, eNEtt_Contract__c c, Map<String,RecordType> rt) {
        if (pt.RecordTypeId == rt.get('Contract_Deal_Arrangement').Id) {
            c.Rebate_Type__c = pt.Rebate_Type__c;
            c.Incentive_Type__c = pt.Incentive_Type__c;
            c.Interchange_Amount__c = pt.Interchange_Amount__c;
            c.Fixed_Amount__c = pt.Fixed_Amount__c;
            c.Agreement_Term_Years__c = pt.Agreement_Term_Years__c;
            c.Review_Period_Months_if_applicable__c = pt.Review_Period_Months_if_applicable__c;
            c.Trial_Period__c = pt.Trial_Period__c;
            c.Trial_Period_Term_Months__c = pt.Trial_Period_Term_Months__c;
            c.Exclusivity_Clause__c = pt.Exclusivity_Clause__c; 
            c.Exclusivity__c = pt.Exclusivity__c; 
            c.Non_local_Settlement_Currency__c = pt.Non_local_Settlement_Currency__c;
            c.Deletion_of_Marketing_Clause__c = pt.Deletion_of_Marketing_Clause__c;
            c.Non_standard_Funding_Fund_on_Auth__c = pt.Non_standard_Funding_Fund_on_Auth__c;
            c.Cross_Currency_Fee_0_81__c = pt.Cross_Currency_Fee_0_81__c;
            c.Cross_Currency_Details__c = pt.Cross_Currency_Details__c;
            c.Waive_Subscription_Fee_Details__c = pt.Waive_Subscription_Fee_Details__c;
            c.Subscription_Fee__c = pt.Subscription_Fee__c;
            c.Chargeback_Processing_Fee__c = pt.Chargeback_Processing_Fee__c;
            c.Short_Term_Incentive__c = pt.Short_Term_Incentive__c;
            c.Short_Term_Incentive_Details__c = pt.Short_Term_Incentive_Details__c;
            c.Technology_Fund_API_Integration__c = pt.Technology_Fund_API_Integration__c;
            c.Technology_Fund_Details__c = pt.Technology_Fund_Details__c;
            c.Volume_Commitments__c = pt.Volume_Commitments__c;
            c.Volume_Commitments_Details__c = pt.Volume_Commitments_Details__c;
            c.WUBS__c = pt.WUBS__c;
            c.T_C_Modification_Details__c = pt.T_C_Modification_Details__c;
            c.Tiered_Rebate_Calculation_Frequency__c = pt.Tiered_Rebate_Calculation_Frequency__c; 
            c.Tier_1_Interchange_Share__c = pt.Tier_1_Interchange_Share__c;
            c.Tier_1_Fixed_Share__c = pt.Tier_1_Fixed_Share__c;
            c.Tier_1_Int_Range_From__c = pt.Tier_1_Int_Range_From__c;
            c.Tier_1_Int_Range_To__c = pt.Tier_1_Int_Range_To__c;
            c.Tier_1_Fixed_Range_From__c = pt.Tier_1_Fixed_Range_From__c;
            c.Tier_1_Fixed_Range_To__c = pt.Tier_1_Fixed_Range_To__c;
            c.Tier_2_Interchange_Share__c = pt.Tier_2_Interchange_Share__c;
            c.Tier_2_Fixed_Share__c = pt.Tier_2_Fixed_Share__c;
            c.Tier_2_Int_Range_From__c = pt.Tier_2_Int_Range_From__c;
            c.Tier_2_Int_Range_To__c = pt.Tier_2_Int_Range_To__c;
            c.Tier_2_Fixed_Range_From__c = pt.Tier_2_Fixed_Range_From__c;
            c.Tier_2_Fixed_Range_To__c = pt.Tier_2_Fixed_Range_To__c;
            c.Tier_3_Interchange_Share__c = pt.Tier_3_Interchange_Share__c;
            c.Tier_3_Fixed_Share__c = pt.Tier_3_Fixed_Share__c;
            c.Tier_3_Int_Range_From__c = pt.Tier_3_Int_Range_From__c;
            c.Tier_3_Int_Range_To__c = pt.Tier_3_Int_Range_To__c; 
            c.Tier_3_Fixed_Range_From__c = pt.Tier_3_Fixed_Range_From__c;
            c.Tier_3_Fixed_Range_To__c = pt.Tier_3_Fixed_Range_To__c;
            c.Tier_4_Interchange_Share__c = pt.Tier_4_Interchange_Share__c;
            c.Tier_4_Fixed_Share__c = pt.Tier_4_Fixed_Share__c;
            c.Tier_4_Int_Range_From__c = pt.Tier_4_Int_Range_From__c;
            c.Tier_4_Int_Range_To__c = pt.Tier_4_Int_Range_To__c; 
            c.Tier_4_Fixed_Range_From__c = pt.Tier_4_Fixed_Range_From__c;
            c.Tier_4_Fixed_Range_To__c = pt.Tier_4_Fixed_Range_To__c; 
            c.Tier_5_Interchange_Share__c = pt.Tier_5_Interchange_Share__c;
            c.Tier_5_Fixed_Share__c = pt.Tier_5_Fixed_Share__c;
            c.Tier_5_Int_Range_From__c = pt.Tier_5_Int_Range_From__c;
            c.Tier_5_Int_Range_To__c = pt.Tier_5_Int_Range_To__c; 
            c.Tier_5_Fixed_Range_From__c = pt.Tier_5_Fixed_Range_From__c;
            c.Tier_5_Fixed_Range_To__c = pt.Tier_5_Fixed_Range_To__c; 
            c.SLA_Required__c = pt.SLA_Required__c; // SF-1430
        }
    }
}