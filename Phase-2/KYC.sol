pragma solidity ^0.5.9;

contract KYC {

    //  Struct customer
    //  username - username of the customer
    //  dataHash - customer data
    //  rating - rating given to customer given based on regularity
    //  upvotes - number of upvotes recieved from banks
    //  bank - address of bank that validated the customer account

    struct Customer {
        string username;
        string dataHash;
	uint rating;
        uint upvotes;
        address bank;
        string password;
    }

    //  Struct bank
    //  name - name of the bank/organisation
    //  ethAddress - ethereum address of the bank/organisation
    //  rating - rating based on number of valid/invalid verified accounts
    //  KYC_count - number of KYCs verified by the bank/organisation
    //  regNumber - Registration Number for the bank/organisation

    struct bank{
        string name;
        address ethAddress;
	    uint rating;
        uint KYC_count;
        string regNumber;
    }
    //  List of all Customers
    Customer[] allCustomers;
    // List of all Banks
    bank[] allbanks;

    struct Request {
        string uname;
	string cdata;
        address bankAddress;
        bool isAllowed;
    }
    // List of All KYC Requests
    Request[] allRequests;

    function stringsEqual(string memory _a, string memory _b) pure public returns (bool) {
		bytes memory a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
        {
			if (a[i] != b[i])
				return false;
        }
		return true;
	}
    
    function addRequest(string memory Username, string memory DataHash, address bankAddress) public payable {
        for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringsEqual(allRequests[i].uname, Username) && allRequests[i].bankAddress == bankAddress) {
                return;
            }
        }
	allRequests.length ++;
        allRequests[allRequests.length - 1] = Request(Username, DataHash, bankAddress,false);
    }
    function removeBank(address eth) public payable returns(uint) {
        for(uint i = 0; i < allbanks.length; ++ i) {
            if(allbanks[i].ethAddress == eth) {
                for(uint j = i+1;j < allbanks.length; ++ j) {
                    allbanks[i-1] = allbanks[i];
                }
                allbanks.length --;
                return 0;
            }
        }
        return 1;
    }
    function addBank(string memory name, address eth, string memory regNum) public payable returns (uint) {
        if(allbanks.length == 0 ) {
            allbanks.length ++;
            allbanks[allbanks.length - 1] = bank(name, eth, 200, 0, regNum);
            return 1;
        }

        return 0;
    }
    
    function removeRequest(string memory Username) public payable returns (uint){
        for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringsEqual(allRequests[i].uname,Username)) {
                for(uint j = i+1;j < allRequests.length; ++ j) {
                    allRequests[j-1] = allRequests[j];
                }
                allRequests.length --;
		return 1;
            }
        }
        //  throw error if username not found
        return 0;
    }

    //  function to add a customer profile to the database
    //  returns 1 if successful
    //  returns 0 if customer already in network

    function addCustomer(string memory Username, string memory DataHash) public payable returns(uint) {
        for(uint i = 0;i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Username))
                return 0;
        }
        allCustomers.length ++;
        allCustomers[allCustomers.length-1] = Customer(Username, DataHash,100, 0, msg.sender,"null");
        return 1;
    }

    //  function to remove fraudulent customer profile from the database
    //  returns 1 if successful
    //  returns 0 if customer profile not in database

    function removeCustomer(string memory Uname) public payable returns(uint) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname)) {
                //address a = allCustomers[i].bank;
                for(uint j = i+1;j < allCustomers.length; ++ j) {
                    allCustomers[j-1] = allCustomers[j];
                }
                allCustomers.length --;
		return 1;
            }
        }
        //  throw error if uname not found
        return 0;
    }

    //  function to modify a customer profile in database
    //  returns 1 if successful
    //  returns 0 if customer profile not in database

    function modifyCustomer(string memory Uname,string memory DataHash) public payable returns(uint) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname)) {
                allCustomers[i].dataHash = DataHash;
                allCustomers[i].bank = msg.sender;
                return 1;
            }
        }
        //  throw error if uname not found
        return 0;
    }

    // function to return customer profile data

    function viewCustomer(string memory Uname) public payable returns(string memory) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname)) {
                return allCustomers[i].dataHash;
            }
        }
        return "Customer not found in database!";
    }
    function UpvoteCustomer(string memory Username) public payable returns (uint){
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Username)) {
                //update rating
                    allCustomers[i].upvotes ++;
                    allCustomers[i].rating += 100/(allCustomers[i].upvotes);
                    if(allCustomers[i].rating > 500) {
                        allCustomers[i].rating = 500;
                    }
                return 1;
            }
        }
        //  throw error if bank not found
        return 0;
    }

    function setPassword(string memory Uname, string memory password) public payable returns(bool) {
        for(uint i=0;i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Uname) && stringsEqual(allCustomers[i].password, "null")) {
                allCustomers[i].password = password;
                return true;
            }
        }
        return false;
    }

    //  function to update organisation rating
    //  bool true indicates a succesfull addition of KYC profile
    //  false indicates detection of a fraudulent profile

    function UpvoteBank(address bankAddress) public payable returns(uint) {
        for(uint i = 0; i < allbanks.length; ++ i) {
            if(allbanks[i].ethAddress == bankAddress) {
                //update rating
                    allbanks[i].KYC_count ++;
                    allbanks[i].rating += 100/(allbanks[i].KYC_count);
                    if(allbanks[i].rating > 500) {
                        allbanks[i].rating = 500;
                    }
                return 0;
            }
        }
        //  throw error if bank not found
        return 1;
    }
    //getter functions
    function getBankRating(address ethAcc) public payable returns(uint) {
        for(uint i = 0; i < allbanks.length; ++ i) {
            if(allbanks[i].ethAddress == ethAcc) {
                return allbanks[i].rating;
            }
        }
        return 0;
    }
    function getBankDetails(address ethAcc) public payable returns(string memory,address,uint,uint,string memory) {
        for(uint i = 0; i < allbanks.length; ++ i) {
            if(allbanks[i].ethAddress == ethAcc) {
                return (allbanks[i].name,allbanks[i].ethAddress,allbanks[i].rating,allbanks[i].KYC_count,allbanks[i].regNumber);
            }
        }
    }

    function getCustomerRating(string memory Username) public payable returns(uint) {
        for(uint i = 0;i < allCustomers.length; ++ i) {
            if(stringsEqual(allCustomers[i].username, Username)) {
                return allCustomers[i].rating;
            }
        }
    }


}
