@isTest
private class DBTConfirmHandlerTest
{

        @isTest
        static void testMethod3(){

          set<id> cIds = New set<id>();
          set<string> tripIds = New Set<String>();


          Orders__c ord = new Orders__c();
          ord.name='12211663367073522';
          ord.Guid__c = '5E786D6F5405F0055BE4CE5801010100';
          insert ord;


          tripIds.add(String.valueOf(ord.name));

          DBT__c dt=new DBT__c();
          dt.status__c='No Case Found';
          dt.amount__c='321';
          dt.formatted_amount__c='321';
          dt.bank_name__c='BRI';
          insert dt;

          


          Order_Items__c  orIt= new Order_Items__c();
          orIt.Order_Name__c = ord.id;
          orIt.Order_Item_Reference_No__c = 'TM6686279816';
          orIt.name = '12211663367079914';
          orIt.Order_Id__c = '12211663367073522';
          orIt.status__c ='Created';
          orIt.Service_Provider_Name__c = 'RedBus';
          orIt.Guid__c='5e8477ad5405f0055be4ce5801020100';
          orIt.Bank_Account_Number__c='12345';
          orIt.Date_Of_Purchase__c=System.today();
          insert orIt;

          // Order_Items__c o = new Order_Items__c();
          // o.Business_Unit__c='REDBUS_ID';
          // o.Transaction_Status__c='WFT';
          // o.Transaction_Latest_status__c='';
          // o.Creation_Time__c=System.Today().addDays(-5);
          // o.Order_Name__c =order.id;
          // insert o;
        
          Payment_Items__c p = new Payment_Items__c();
          p.Order_Item_Name__c = orIt.id;
          p.Payment_Gateway_Type__c='BRI';
          p.Payment_System__c='ONLINE';
          p.Account_Holder_Name__c='TESTACC';
          p.Amount_Payable_Value__c=1234;
          p.Amount_Payable_Currency__c='123';
          p.Guid__c='5e8477ad5405f0055be4ce5801020100';
          p.Order_Name__c = ord.Id;
          insert p;


          case c = New case();
          c.bank_name__c ='BRI';
          c.trip_id_ct__c = '12211663367073522';
          c.amountd__c = '321';
          c.Country__c ='Indonesia';
          c.Business_Unit_ct__c='Indonesia-Bus';
          c.Transaction_ID__c = orIt.id;
          insert c;

          cIds.add(c.Id);

          Test.startTest();
          string json='{"isTicketGenrated":true,"isGFT":false,"IsvoucherExpired":false,"concludeResponse":"http://m.redbus.id/Confirm?tin=IDSA995400712\u0026emailId=beprettylashstudio@gmail.com\u0026ChannelName=MOBILE_APP"}';
          Test.setMock(HttpCalloutMock.class, new RestClientHTTPMocks(200, 'OK', json));
          // DBTConfirmHandler dbt = New DBTConfirmHandler();
          DBTConfirmHandler.dbtConfirm(cIds,tripIds);
          Test.stopTest();
          // Payment_Items__c p=new Payment_Items__c();
          // p.Order_ID__c='12345';
          // p.Payment_System__c='ONLINE';
          // p.Payment_Gateway_Type__c='BRI';
          // p.Order_Name__c=od.id;
          // p.Account_Holder_Name__c='BRI';
          // insert p;


        }
        }