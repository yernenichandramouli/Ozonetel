import { LightningElement, track, wire } from 'lwc';
import getTotalAgentsinSF from '@salesforce/apex/OmniSupervisorDashboardController.getTotChatAgentsLoggedInSF';
import getTotOmniAgents from '@salesforce/apex/OmniSupervisorDashboardController.getTotAgentsLoggedInOmni';
import getTotOnlineAgents from '@salesforce/apex/OmniSupervisorDashboardController.getTotOnlineAgents';
import getTotBraekAgents from '@salesforce/apex/OmniSupervisorDashboardController.getTotBreakAwayAgents';
import getTotOfflineAgents from '@salesforce/apex/OmniSupervisorDashboardController.getTotOfflineAgents';
import getTotWaitingChats from '@salesforce/apex/OmniSupervisorDashboardController.getWaitingChats';
import getOngoingChats from '@salesforce/apex/OmniSupervisorDashboardController.getOngoingChats';

export default class YourComponent extends LightningElement {
    @track totalAgentsLoggedInSF;
    @track totalwaitingChatsCount;
    @track totalOngoingChatsCount;
    @track totalAgentsLoggedInOmni;
    @track totalOnlineAgents;
    @track totalBreakAwayAgents;
    @track totalofflineAgents;
    @track isModalOpen = false;
    @track selectedAgents;
    @track sortBy;
    @track sortDirection;
    // @track dataToSort = [];

    @track totalAgentsData=[];
    @track agentsInOmniData=[];
    @track onlineInOmniData=[];
    @track breakInOmniData=[];
    @track offlineInOmniData=[];
    @track totalWaitingChatsData =[];


    @track isTable1Visible = false;
    @track isTable2Visible = false;
    @track isTable3Visible = false;
    @track isTable4Visible = false;
    @track isTable5Visible = false;
    @track isTable6Visible = false;
    @track isTable7Visible = false;

    //
    dataFromApex =[];
    //

    showAgentDetailsCol = [
        { label: 'User Name', fieldName: 'UserName__c', sortable: true },
        { label: 'Last Login Time', fieldName: 'Last_Login_Time__c', sortable: true },
        { label: 'Location', fieldName: 'User_Location__c', type: 'text', sortable: true  }
    ];

    showWaitingChatsCol = [
        { label: 'Name', fieldName: 'Name', sortable: true },
        { label: 'Request Time', fieldName: 'RequestTime', sortable: true }
    ];

    agentcolumns = [
        { label: 'User Name', fieldName: 'UserName', type: 'text', sortable: true },
        { label: 'Start Date', fieldName: 'StatusStartDate', sortable: true },
        { label: 'Service Presence Status', fieldName: 'ServicePresenceStatus', sortable: true },
        { label: 'Location', fieldName: 'userLocation',type: 'text', sortable: true  },
        { label: 'Configured Capacity', fieldName: 'ConfiguredCapacity', type: 'text', sortable: true  },
        { label: 'Idle Duration', fieldName: 'IdleDuration' }
    ];

    refreshKey = 0; // Reactive property to trigger wire refresh
    intervalId;

     connectedCallback() {
        // Set interval to update refreshKey every 10 seconds
        this.intervalId = setInterval(() => {
            this.refreshKey = Date.now(); // Changing refreshKey triggers wire methods
        }, 10000); // 10 seconds
    }

    disconnectedCallback() {
        // Clear interval to prevent memory leaks
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
    }

    //  doSorting(event) {
    //     console.log('Inside Sort' +event.target.dataset.table);
    //     this.sortBy = event.detail.fieldName;
    //     this.sortDirection = event.detail.sortDirection;
    //     this.sortData(this.sortBy, this.sortDirection);
    // }

    // sortData(fieldname, direction) {
    //     console.log('Inside Sort Data');
    //     let parseData = JSON.parse(JSON.stringify(this.breakInOmniData));
    //     let keyValue = (a) => {
    //         return a[fieldname];
    //     };
    //     let isReverse = direction === 'asc' ? 1: -1;
    //     parseData.sort((x, y) => {
    //         x = keyValue(x) ? keyValue(x) : '';
    //         y = keyValue(y) ? keyValue(y) : '';
    //         return isReverse * ((x > y) - (y > x));
    //     });
    //     console.log('Inside parseData Data' +JSON.stringify(parseData))
    //     this.breakInOmniData = parseData;
    // } 

    convertToIST(utcDate) {
        const date = new Date(utcDate);
        const istOffset = 5.5 * 60 * 60 * 1000; // IST is UTC +5:30
        const istDate = new Date(date.getTime() + istOffset);
        
        // Formatting the date to a readable string
        return istDate.toLocaleString('en-IN', {
            timeZone: 'Asia/Kolkata',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
    }

    doSorting(event) {
    const { fieldName, sortDirection } = event.detail;
    const targetTable = event.target.dataset.table; // Use data attribute to identify the table
    this.sortData(targetTable, fieldName, sortDirection);
    
}

sortData(table, fieldname, direction) {
    console.log('Inside dataToSort');
    let dataToSort;
    switch (table) {
        case 'breakInOmniData':
            dataToSort = [...this.breakInOmniData];
            break;
        case 'agentsInOmniData':
            dataToSort = [...this.agentsInOmniData];
            break;
        case 'onlineInOmniData':
            dataToSort = [...this.onlineInOmniData];
            break;
        case 'offlineInOmniData':
            dataToSort = [...this.offlineInOmniData];
            break;
        case 'totalWaitingChatsData':
            dataToSort = [...this.totalWaitingChatsData];
            break;
        case 'totalOngoingChatsData':
            dataToSort = [...this.totalOngoingChatsData];
            break;
        default:
            return; // Exit if no valid table found
    }

    let keyValue = (a) => a[fieldname] || '';
    let isReverse = direction === 'asc' ? 1 : -1;
    console.log(':: DataToSort = '+JSON.stringify(dataToSort));
    dataToSort.sort((x, y) => {
        return isReverse * ((keyValue(x) > keyValue(y)) - (keyValue(y) > keyValue(x)));
    });

    // Update the corresponding data array
    switch (table) {
        case 'breakInOmniData':
            this.breakInOmniData = dataToSort;
            break;
        case 'agentsInOmniData':
            this.agentsInOmniData = dataToSort;
            break;
        case 'onlineInOmniData':
            this.onlineInOmniData = dataToSort;
            break;
        case 'offlineInOmniData':
            this.offlineInOmniData = dataToSort;
            break;
        case 'totalWaitingChatsData':
            this.totalWaitingChatsData = dataToSort;
            break;
        case 'totalOngoingChatsData':
            this.totalOngoingChatsData = dataToSort;
            break;
    }
}

     columnHeader = ['ID','Start Date','ServicePresenceStatus','UserName', 'userLocation', 'ConfiguredCapacity', 'IdleDuration' ]

        exportContactData(event){
            const targetTable = event.target.id;
            console.log('::: targetTable = '+targetTable);
            let dataToSort;
            // let columnHeader =[];
            if (targetTable.includes('breakInOmniData')) {
                dataToSort = [...this.breakInOmniData];
            } else if (targetTable.includes('agentsInOmniData')) {
                dataToSort = [...this.agentsInOmniData];
            } else if (targetTable.includes('onlineInOmniData')) {
                dataToSort = [...this.onlineInOmniData];
            } else if (targetTable.includes('offlineInOmniData')) {
                this.columnHeader=['Id','UserName','Last Login Time','Location'];
                dataToSort = [...this.offlineInOmniData];
            } else if (targetTable.includes('totalAgentsData')) {
                 this.columnHeader=['UserName','Last Login Time','Location'];
                dataToSort = [...this.totalAgentsData];
            }else {
                return; // Exit if no valid table found
            }
        // Prepare a html table
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';          
        doc += '</style>';
        // Add all the Table Headers
        doc += '<tr>';
        this.columnHeader.forEach(element => {            
            doc += '<th>'+ element +'</th>'           
        });
        doc += '</tr>';
        console.log(':: dataToSort = '+JSON.stringify(dataToSort));
        // Add the data rows
        if (targetTable.includes('offlineInOmniData') || targetTable.includes('totalAgentsData')){
            dataToSort.forEach(record => {
                doc += '<tr>';
                doc += '<th>'+record.Id+'</th>'; 
                doc += '<th>'+record.UserName__c+'</th>'; 
                doc += '<th>'+record.Last_Login_Time__c+'</th>'; 
                doc += '<th>'+record.User_Location__c+'</th>';
                doc += '</tr>';
            });
        }else{
            dataToSort.forEach(record => {
                doc += '<tr>';
                doc += '<th>'+record.Id+'</th>'; 
                doc += '<th>'+record.StatusStartDate+'</th>'; 
                doc += '<th>'+record.ServicePresenceStatus+'</th>'; 
                doc += '<th>'+record.UserName+'</th>';
                doc += '<th>'+record.userLocation+'</th>'; 
                doc += '<th>'+record.ConfiguredCapacity+'</th>'; 
                doc += '<th>'+record.IdleDuration+'</th>'; 
                doc += '</tr>';
            });
        }

        
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Contact Data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }


@wire(getTotalAgentsinSF, { refreshKey: '$refreshKey' })
    wiredTotalAgentinSF({ data, error }) {
        if (data) {
            // this.totalAgentsLoggedInSF = data.length; 
            const uniqueUserIds = new Set(data.map(item => item.UserName__c));
            this.totalAgentsLoggedInSF = uniqueUserIds.size;
            // this.totalAgentsData = data; 
            this.totalAgentsData = data.map((omni) => {
                return {
                    Id: omni.Id,
                    Last_Login_Time__c: this.convertToIST(omni.Last_Login_Time__c),
                    UserName__c: omni.UserName__c,
                    User_Location__c: omni.User_Location__c
                };
            });
            console.log('::: totalOfflineAgents = ' + this.totalofflineAgents);
        } else if (error) {
            console.error('Error fetching offline agents:', error);
            this.totalAgentsData = 0; 
        }
    }


 @wire(getTotOmniAgents, { refreshKey: '$refreshKey' })
    wiredOmniAgents({ data, error }) {
        if (data) {
            this.totalAgentsLoggedInOmni = data.length; // Count of omni agents
            this.agentsInOmniData = data.map((omni) => {
                return {
                    Id: omni.Id,
                    StatusStartDate: this.convertToIST(omni.StatusStartDate),
                    ServicePresenceStatus: omni.ServicePresenceStatus.DeveloperName,
                    UserName: omni.User.Name,
                    userLocation: omni.User.RedBus_Location__c,
                    ConfiguredCapacity: omni.ConfiguredCapacity,
                    IdleDuration: omni.IdleDuration
                };
            });
            console.log('::: totalAgentsLoggedInOmni = ' + this.totalAgentsLoggedInOmni);
        } else if (error) {
            console.error('Error fetching omni agents:', error); // Log error
        }
    }

    @wire(getTotOnlineAgents, { refreshKey: '$refreshKey' })
    wiredOnlineAgents({ data, error }) {
        if (data) {
            this.totalOnlineAgents = data.length; // Count of online agents
            this.onlineInOmniData = data.map((omni) => {
                return {
                    Id: omni.Id,
                    StatusStartDate: this.convertToIST(omni.StatusStartDate),
                    ServicePresenceStatus: omni.ServicePresenceStatus.DeveloperName,
                    UserName: omni.User.Name,
                    userLocation: omni.User.RedBus_Location__c,
                    ConfiguredCapacity: omni.ConfiguredCapacity,
                    IdleDuration: omni.IdleDuration
                };
            });
            console.log('::: totalOnlineAgents = ' + this.totalOnlineAgents);
        } else if (error) {
            console.error('Error fetching online agents:', error); // Log error
        }
    }

   @wire(getTotBraekAgents, { refreshKey: '$refreshKey' })
    wiredBreakAwayAgents({ data, error }) {
        if (data) {
            this.totalBreakAwayAgents = data.length; // Count of break away agents
            console.log('::: totalBreakAwayAgents = ' + this.totalBreakAwayAgents);
            this.breakInOmniData = data.map((omni) => {
                return {
                    Id: omni.Id,
                    StatusStartDate: this.convertToIST(omni.StatusStartDate), // omni.StatusStartDate,
                    ServicePresenceStatus: omni.ServicePresenceStatus.DeveloperName,
                    UserName: omni.User.Name,
                    userLocation: omni.User.RedBus_Location__c,
                    ConfiguredCapacity: omni.ConfiguredCapacity,
                    IdleDuration: omni.IdleDuration
                };
            });
        } else {
            this.totalBreakAwayAgents = 0; // Reset count if no data
            console.error('Error fetching break away agents:', error); // Log error
        }
    }

@wire(getTotOfflineAgents, { refreshKey: '$refreshKey' })
    wiredOfflineAgents({ data, error }) {
        if (data) {
            // this.totalAgentsLoggedInSF = data.length; 
            const uniqueUserIds = new Set(data.map(item => item.UserName__c));
            this.totalofflineAgents = uniqueUserIds.size;

            // this.totalofflineAgents = data.length; // Count of offline agents
            // this.offlineInOmniData = data; // Store offline agents data
            this.offlineInOmniData = data.map((omni) => {
                return {
                    Id: omni.Id,
                    Last_Login_Time__c: this.convertToIST(omni.Last_Login_Time__c),
                    UserName__c: omni.UserName__c,
                    User_Location__c: omni.User_Location__c
                };
            });
            console.log('::: totalOfflineAgents = ' + this.totalofflineAgents);
        } else if (error) {
            console.error('Error fetching offline agents:', error); // Log error
            this.totalofflineAgents = 0; // Reset count on error
        }
    }

    @wire(getTotWaitingChats, { refreshKey: '$refreshKey' })
    wiredWaitingChats({ data, error }) {
        if (data) {
            this.totalwaitingChatsCount = data.length; // Count of offline agents
            this.totalWaitingChatsData = data; // Store offline agents data
            this.totalWaitingChatsData = data.map((omni) => {
                return {
                    Id: omni.Id,
                    RequestTime: this.convertToIST(omni.RequestTime),
                    Name: omni.Name
                };
            });
            console.log('::: totalOfflineAgents = ' + this.totalWaitingChatsData);
        } else if (error) {
            console.error('Error fetching offline agents:', error); // Log error
            this.totalwaitingChatsCount = 0; // Reset count on error
        }
    }

    @wire(getOngoingChats, { refreshKey: '$refreshKey' })
    wiredOngoingChats({ data, error }) {
        if (data) {
            this.totalOngoingChatsCount = data.length; // Count of offline agents
            this.totalOngoingChatsData = data; // Store offline agents data
            this.totalOngoingChatsData = data.map((omni) => {
                return {
                    Id: omni.Id,
                    RequestTime: this.convertToIST(omni.RequestTime),
                    Name: omni.Name
                };
            });
            console.log('::: totalOfflineAgents = ' + this.totalOngoingChatsData);
        } else if (error) {
            console.error('Error fetching offline agents:', error); // Log error
            this.totalOngoingChatsCount = 0; // Reset count on error
        }
    }

    showAgentDetails() {
        this.resetTableVisibility();
        if(this.totalAgentsData){
          this.isTable1Visible = true;
        }
    }

    showTable2() {
        this.resetTableVisibility();
        this.isTable2Visible = true;
    }

    showTable3() {
        this.resetTableVisibility();
        this.isTable3Visible = true;
    }

    showTable4() {
        this.resetTableVisibility();
        this.isTable4Visible = true;
    }

    showTable5() {
        this.resetTableVisibility();
        this.isTable5Visible = true;
    }

    showTable6() {
        this.resetTableVisibility();
        this.isTable6Visible = true;
    }
    showTable7() {
        this.resetTableVisibility();
        this.isTable7Visible = true;
    }

    resetTableVisibility() {
        this.isTable1Visible = false;
        this.isTable2Visible = false;
        this.isTable3Visible = false;
        this.isTable4Visible = false;
        this.isTable5Visible = false;
        this.isTable6Visible = false;
        this.isTable7Visible = false;
    }
}