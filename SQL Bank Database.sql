----Bank Database Design

----Introduction:
----Introduction: There are only two types of accounts: Checking and Savings accounts. The provided list of column names was separated into appropriate entities (tables) with relationships between these entities defined, according to the database schema provided, in terms of primary key constraints and foreign key constraints, and choosing the appropriate data type for each column.
----Project Goals:
----The goal of the project is to understand database entities in more depth and have practical experience of working with different objects of SQL.


----Other Criteria

----* When an employee opens an account, performs a transaction on or  reactivates an account there must be a record of which employee  performed the action.
----* Every person who opens a savings account does not get the same rate.
----* Because the bank charges an overdraft fee, a record must be maintained  on any transaction that causes an account to go into overdraft.
----* Extra error information is required to be stored when a transaction fails.  The bank uses this information for fraud detection and to diagnose  periodic problems within their networks and applications.
----* Customers have a user logins to allow them to access all of their  accounts. If a user fails a login attempt, for instance because they have  forgotten their password, a record of that failed attempt needs to be kept.
----* The information for checking and saving accounts is very similar to each  other as are the transactions that update those accounts.
----* More than one customer is allowed on each account, and any transaction  record should reflect which customer made the transaction.


----Column List

----DateOpened
----AccountStatus
----OpeningBalance
----CurrentBalance
----AccountID
----CustomerID
----OverdraftAccountID
----TransactionID
----FailedTransactionID
----TransactionTypeID
----TransactionTypeName
----TransactionAmt
----SavingsInterestRate
----TransactionDate
----TransactionAmount
----TransactionType
----OldBalance
----NewBalance
----CustomerFirstName
----CustomerMiddleInitial
----CustomerLastName
----CustomerAddress1
----CustomerAddress2
----City
----State
----Zipcode
----Email
----SSN
----UserLogin
----UserPassword
----UserSecurityQuestion
----UserSecurityQuestionAnswer
----HomePhone  
----WorkPhone  
----CellPhone
----ErrorLogID
----ErrorTime
----UserName
----FailedTransactionErrorID
----FailedTransactionXML
----FailedTransactionErrorTime
----EmployeeID
----EmployeeFirstName
----EmployeeMiddleInitial
----EmployeeLastName
----EmployeeIsManager
----AccountReactivationLogID
----ReactivationDate  UserSecurityQuestion2
----UserSecurityQuestionAnswer2
----UserSecurityQuestion3
----UserSecurityQuestionAnswer3


----Designed Entities
----Categorized columns, * are Primary Keys

----Account table
----*AccountID  
----CurrentBalance
----AccountType  
----AccountStatus

----Customer table
----*CustomerID
----CustomerAddress1  
----CustomerAddress2  
----CustomerFirstName  
----CustomerLastName  
----CustomerMiddleInitial  
----City
----State 
----Zipcode  
----Email
----HomePhone 
----CellPhone  
----WorkPhone
----SSN

----UserSecurityQuestions table
----*UserSecurityQuestionID 
----UserSecurityQuestion
----UserSecurityQuestion2  
----UserSecurityQuestion3

----TransactionLog table
----*TransactionID 
----TransactionType  
----TransactionDate
----DateOpened  
----ReactivationDate
----TransactionAmount
----TransactionAmt
----NewBalance
----OpeningBalance  
----OldBalance

----Employee table
----*EmployeeID  
----EmployeeFirstName  
----EmployeeLastName  
----EmployeeMiddleInitial  
----EmployeeIsManager  

----UserLogins table
----*UserLogin
----UserName  
----UserPassword  

----LoginErrorLog table
----*ErrorLogID  
----ErrorTime

----SavingsInterestRates table
----*SavingsInterestRateID  
----SavingsInterestRate

----TransactionType table
----*TransactionTypeID  
----TransactionTypeName
----AccountReactivationLogID

----UserSecurityAnswers table
----*UserAnswerID  
----UserSecurityQuestionAnswer
----UserSecurityQuestionAnswer2  
----UserSecurityQuestionAnswer3

----OverDraftLog table
----OverdraftAccountID

----FailedTransactionLog table
----*FailedTransactionID  
----FailedTransactionXML 
----ErrorTime

----FailedTransactionErrorType table
----*FailedTransactionErrorID  
----FailedTransactionErrorTime

----AccountType table
----*AccountTypeID
----AccountTypeDescription

----AccountStatusType table
----* AccountStatusTypeID
----AccountTypeDescription

----Login-Account table
----UserLoginID
----AccountID

----Customer-Account table
----AccountID
----CustomerID




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

----SQL Programming
----Project Phase 1

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


----1.1.	Create a database for a banking application called “Bank”. [Basic]
create database Bank
use Bank

----1.2.	Create all the tables mentioned in the database diagram. [Moderate]

----Based on the entity-relationship diagram, the order in which the tables will be created is:
----1 UserLogins
----2 UserSecurityQuestions
----3 UserSecurityAnswers
----4 FailedTransactionErrorType
----5 FailedTransactionLog
----6 AccountType
----7 AccountStatusType
----8 SavingsInterestRates
----9 Account
----10 Login-Account
----11 LoginErrorLog
----12 Customer
----13 Customer-Account
----14 Employee
----15 TransactionType
----16 TransactionLog
----17 OverDraftLog

----To drop a table, we must use the reverse order, if there is a relationship (foreign key). Else, the table will not be deleted.

----All Primary Keys in these tables will be defined as NOT NULL. 
----As a result, Foreign Keys referencing these PK's will also be NOT NULL, without defining them specifically as such.


create table UserLogins (
UserLoginID smallint not null Primary Key,
UserName char(15),
UserPassword varchar(20)
)

create table UserSecurityQuestions (
UserSecurityQuestionID tinyint not null Primary Key,
UserSecurityQuestion varchar(50)
)

--version 1 to create a Primary AND Foreign Key when creating the table; see table OverDraftLog (created last) for version 2
create table UserSecurityAnswers (
UserLoginID smallint not null Primary Key references UserLogins(UserLoginID), 
UserSecurityQuestionAnswer varchar(25), 
UserSecurityQuestionID tinyint references UserSecurityQuestions(UserSecurityQuestionID)
)

create table FailedTransactionErrorType (
FailedTransactionErrorTypeID tinyint not null Primary Key,
FailedTransactionErrorDescription varchar(50)
)

create table FailedTransactionLog (
FailedTransactionID int not null Primary Key,
FailedTransactionErrorTypeID tinyint references FailedTransactionErrorType(FailedTransactionErrorTypeID),
FailedTransactionErrorTime datetime, 
FailedTransactionXML varchar(50)
)

create table AccountType (
AccountTypeID tinyint not null Primary Key,
AccountTypeDescription varchar(30)
)

create table AccountStatusType (
AccountStatusTypeID tinyint not null Primary Key,
AccountStatusDescription varchar(30)
)

create table SavingsInterestRates (
InterestSavingsRateID tinyint not null Primary Key,
InterestRateValue decimal(9,9),
InterestRateDescription varchar(20)
)

create table Account (
AccountID int not null Primary Key,
CurrentBalance decimal(12,2),
AccountTypeID tinyint references AccountType(AccountTypeID),
AccountStatusTypeID tinyint not null references AccountStatusType(AccountStatusTypeID), --create FK one way
InterestSavingsRateID tinyint not null, 
Foreign Key (InterestSavingsRateID) references SavingsInterestRates(InterestSavingsRateID) --or in a different way
)

--as per the entity-relationship diagram, this table does not have a Primary Key
create table [Login-Account] (
UserLoginID smallint references UserLogins(UserLoginID), 
AccountID int references Account(AccountID)
)

create table LoginErrorLog (
ErrorLogID int not null Primary Key, 
ErrorTime datetime,
FailedTransactionXML varchar(50)
)

create table Customer (
CustomerID int not null Primary Key,
AccountID int references Account(AccountID),
CustomerAddress1 varchar(30),
CustomerAddress2 varchar(30),
CustomerFirstName varchar(30), 
CustomerMiddleInitial char(1), 
CustomerLastName varchar(30), 
City varchar(20),
State char(2),
ZipCode char(10),
EmailAddress varchar(40),
HomePhone char(10),
CellPhone char(10), 
WorkPhone char(10),
SSN char(9),
UserLoginID smallint references UserLogins(UserLoginID)
)

create table [Customer-Account] (
AccountID int references Account(AccountID), 
CustomerID int references Customer(CustomerID)
)

create table Employee (
EmployeeID int not null Primary Key,
EmployeeFirstName varchar(25),
EmployeeMiddleInitial char(1),
EmployeeLastName varchar(25),
EmployeeIsManager bit
)

create table TransactionType (
TransactionTypeID tinyint not null Primary Key,
TransactionTypeName char(10),
TransactionTypeDescription varchar(50),
TransactionFeeAmount decimal(12,2),
)

create table TransactionLog (
TransactionID int not null Primary Key,
TransactionTypeID tinyint references TransactionType(TransactionTypeID),
TransactionDate datetime,
TransactionAmount decimal(12,2),
NewBalance decimal(12,2),
AccountID int not null, --will create Foreign Key AFTER the table is created, to illustrate different ways of doing it
CustomerID int not null, --idem
EmployeeID int not null, --idem 
UserLoginID smallint not null --idem
)

--version 2 to create a Primary AND Foreign Key when creating the table; see table UserSecurityAnswers for version 1
create table OverDraftLog (
AccountID int not null Primary Key, Foreign Key (AccountID) references Account(AccountID),
OverDraftDate datetime,
OverDraftAmount decimal(12,2),
OverDraftTransactionXML varchar(50)
)


----1.3.	Create all the constraints based on the database diagram. [Advanced]

----Most constraints (foreign keys) of this project were created at the time the tables were created. 
----To illustrate how to create a Foreign Key AFTER the table is created, I left only 4 keys in the TransactionLog table. 

--this is the better method. If we try to re-run the command, it will not allow for a foreign key with the same name.
alter table TransactionLog
add constraint FK_TransactionLog_AccountID Foreign Key (AccountID) references Account(AccountID)

--this method, if run more than once, will create more than one relationship (=key) between the same 2 fields
alter table TransactionLog
add Foreign Key (CustomerID) references Customer(CustomerID)

--graphical method (not by code); stackoverflow.com for other versions and variations

alter table TransactionLog 
add constraint FK_TransactionLog_EmployeeID Foreign Key (EmployeeID) references Employee(EmployeeID)

alter table TransactionLog 
add constraint FK_TransactionLog_UserLoginID Foreign Key (UserLoginID) references UserLogins(UserLoginID)


----1.4. 4.	Insert at least 4 rows in each table. [Basic]

--UserLoginID, UserName, UserPassword
insert into UserLogins values ('10', 'BrownBear', 'bear') --UserLoginID, UserName, UserPassword
insert into UserLogins values ('20', 'RedBird', 'bird')
insert into UserLogins values ('30', 'BlueHorse', 'horse')
insert into UserLogins values ('40', 'YellowDuck', 'duck')
insert into UserLogins values ('50', 'PurpleCat', 'cat')
insert into UserLogins values ('60', 'GoldFish', 'fish')
insert into UserLogins values ('70', 'BlackSheep', 'duck')
insert into UserLogins values ('80', 'WhiteDog', 'dog')

--Because UserLoginID is PK in the table UserSecurityAnswers, it cannot appear more than once. 
--That means there can only be ONE security answer per user. 
--(Same with the design of the OverDraftLog table.)

--UserSecurityQuestionID, UserSecurityQuestion
insert into UserSecurityQuestions values ('11', 'Bear color?') 
insert into UserSecurityQuestions values ('21', 'Bird color?')
insert into UserSecurityQuestions values ('31', 'Horse color?')
insert into UserSecurityQuestions values ('41', 'Duck color?')
insert into UserSecurityQuestions values ('51', 'Cat color?')
insert into UserSecurityQuestions values ('61', 'Fish color?')
insert into UserSecurityQuestions values ('71', 'Sheep color?')
insert into UserSecurityQuestions values ('81', 'Dog color?')

--UserLoginID, UserSecurityQuestionAnswer, UserSecurityQuestionID
insert into UserSecurityAnswers values ('10', 'brown', '11') 
insert into UserSecurityAnswers values ('20', 'red', '21')
insert into UserSecurityAnswers values ('30', 'blue', '31')
insert into UserSecurityAnswers values ('40', 'yellow', '41')
insert into UserSecurityAnswers values ('50', 'purple', '51')
insert into UserSecurityAnswers values ('60', 'gold', '61')
insert into UserSecurityAnswers values ('70', 'black', '71')
insert into UserSecurityAnswers values ('80', 'white', '81')

--FailedTransactionErrorTypeID, FailedTransactionErrorDescription
insert into FailedTransactionErrorType values ('91', 'Insufficient funds.') 
insert into FailedTransactionErrorType values ('92', 'Unknown recipient.')
insert into FailedTransactionErrorType values ('93', 'Currency mismatch.')
insert into FailedTransactionErrorType values ('94', 'Other transaction error.')

--FailedTransactionID, FailedTransactionErrorTypeID, FailedTransactionErrorTime, FailedTransactionXML
insert into FailedTransactionLog values ('999100', '92', '20120618 10:34:09 AM', 'Failed trans xml 1') 
insert into FailedTransactionLog values ('999200', '94', '20190223 2:15:43 PM', 'Failed trans xml 2')
insert into FailedTransactionLog values ('999300', '91', '20190327 11:55:22 AM', 'Failed trans xml 3')
insert into FailedTransactionLog values ('999400', '91', '20190802 3:43:43 PM', 'Failed trans xml 4')
insert into FailedTransactionLog values ('999500', '93', '20190802 3:44:52 PM', 'Failed trans xml 5')
insert into FailedTransactionLog values ('999600', '91', '20190802 4:17:02 PM', 'Failed trans xml 6')

--as per specifications, there are only two types of accounts at this time: Checking and Savings accounts

--AccountTypeID, AccountTypeDescription
insert into AccountType values ('1', 'Checking') 
insert into AccountType values ('2', 'Savings')

--AccountStatusTypeID, AccountStatusDescription
insert into AccountStatusType values ('1', 'Open') 
insert into AccountStatusType values ('2', 'Closed')
insert into AccountStatusType values ('3', 'Suspended')
insert into AccountStatusType values ('4', 'Pending Approval')

--numerical values can be inserted with or without apostrophe

--InterestSavingsRateID, InterestRateValue, InterestRateDescription
insert into SavingsInterestRates values ('1', 0.01, 'Bronze') 
insert into SavingsInterestRates values ('2', 0.03, 'Silver')
insert into SavingsInterestRates values ('3', 0.0425125, 'Gold')
insert into SavingsInterestRates values ('4', 0.06111, 'Diamond')

--AccountID, CurrentBalance, AccountTypeID, AccountStatusTypeID, InterestSavingsRateID
insert into Account values (123456, 8900, 1, 1, 4) 
insert into Account values (111111, 2000, 1, 1, 1)
insert into Account values (222222, 100, 2, 1, 1)
insert into Account values (333333, 0, 1, 2, 1)
insert into Account values (444444, 12000, 1, 3, 3)
insert into Account values (555555, 0, 1, 4, 1)
insert into Account values (666666, 5275, 2, 1, 3)
insert into Account values (777777, 4999, 1, 1, 3)
insert into Account values (888888, -80, 1, 3, 2)
insert into Account values (999999, 6200, 1, 1, 2)

--UserLoginID, AccountID
insert into [Login-Account] values (10, 123456) 
insert into [Login-Account] values (20, 111111)
insert into [Login-Account] values (20, 222222)
insert into [Login-Account] values (30, 333333)
insert into [Login-Account] values (40, 444444)
insert into [Login-Account] values (50, 555555)
insert into [Login-Account] values (60, 666666)
insert into [Login-Account] values (60, 777777)
insert into [Login-Account] values (80, 888888)
insert into [Login-Account] values (70, 999999)

--ErrorLogID, ErrorTime, FailedTransactionXML
insert into LoginErrorLog values ('1234', '20190902 12:43:43 PM', 'Failed trans xml 1') 
insert into LoginErrorLog values ('1122', '20190909 9:12:07 AM', 'Failed trans xml 2')
insert into LoginErrorLog values ('3344', '20190916 7:02:18 AM', 'Failed trans xml 3')
insert into LoginErrorLog values ('5566', '20190923 12:51:26 AM', 'Failed trans xml 4')

--CustomerID, AccountID, CustomerAddress1, CustomerAddress2, CustomerFirstName, CustomerMiddleInitial, CustomerLastName, City, State, ZipCode, EmailAddress, HomePhone, CellPhone, WorkPhone, SSN, UserLoginID
insert into Customer values ('10101010', '123456', '10 King St West', 'Unit 9', 'Bear', 'B', 'Brown', 'Toronto', 'ON', 'M11111', 'bear@brown.ca', '6479919911', '4161231234', '4165551234', '515515515', '10') 
insert into Customer values ('20202020', '111111', '20 Queen St West', 'Unit 211', 'Bird', 'B', 'Red', 'London', 'ON', 'L55555', 'bird@red.com', '', '416222222', '', '521234567', '20')
insert into Customer values ('30303030', '333333', '30 Prince St West', '', 'Horse', 'H', 'Blue', 'Toronto', 'ON', 'M54821', 'horse@blue.com', '6301582658', '', '', '530000333', '30')
insert into Customer values ('40404040', '444444', '40 Princes St West', 'Unit 37', 'Duck', 'D', 'Yellow', 'Montreal', 'QC', 'M11111', 'duck@yellow.ca', '', '5141231234', '', '540000444', '40')
insert into Customer values ('50505050', '555555', '50 King St West', 'Apt 2', 'Cat', 'C', 'Purple', 'Chicago', 'IL', '60639', 'cat@purple.com', '', '7731231234', '7733838888', '550000555', '50')
insert into Customer values ('60606060', '777777', '60 Queen St West', 'Garden Apt', 'Fish', 'F', 'Gold', 'Vancouver', 'BC', 'T48784', 'fish@gold.com', '6471237899', '4169875231', '', '560000666', '60')
insert into Customer values ('70707070', '999999', '70 Prince St West', 'Suite 211', 'Sheep', 'S', 'Black', 'Regina', 'SK', 'V78454', 'sheep@black.com', '', '9051231234', '', '570000777', '70')
insert into Customer values ('80808080', '888888', '80 Princess St West', '', 'Dog', 'D', 'White', 'New York', 'NY', '10111', 'dog@white.com', '6479919911', '', '4160590789', '580000888', '80')

--AccountID, CustomerID
insert into [Customer-Account] values ('123456', '10101010') 
insert into [Customer-Account] values ('111111', '20202020')
insert into [Customer-Account] values ('222222', '20202020')
insert into [Customer-Account] values ('333333', '30303030')
insert into [Customer-Account] values ('444444', '40404040')
insert into [Customer-Account] values ('555555', '50505050')
insert into [Customer-Account] values ('666666', '60606060')
insert into [Customer-Account] values ('777777', '60606060')
insert into [Customer-Account] values ('888888', '80808080')
insert into [Customer-Account] values ('999999', '70707070')

--EmployeeID, EmployeeFirstName, EmployeeMiddleInitial, EmployeeLastName, EmployeeIsManager
insert into Employee values ('123', 'Laura', 'N', 'Gheroae', 1) 
insert into Employee values ('456', 'Tareq', 'J', 'Jaber', 1)
insert into Employee values ('789', 'David', 'C', 'Bowie', 0)
insert into Employee values ('1011', 'Rachel', 'C', 'McAdams', 0)

--TransactionTypeID, TransactionTypeName, TransactionTypeDescription, TransactionFeeAmount, AccountReactivationLogID
insert into TransactionType values ('1', 'Deposit', 'deposits money into account', '0') 
insert into TransactionType values ('2', 'Withdrawal', 'teller withdrawal', '0')
insert into TransactionType values ('3', 'ATM withdr', 'withdrawal from ATM', '1')
insert into TransactionType values ('4', 'Foreign', 'foreign transaction', '5')
insert into TransactionType values ('5', 'Payment', 'paying for goods/services', '0')
insert into TransactionType values ('6', 'Online', 'payment online', '0.5')

--TransactionID, TransactionTypeID, TransactionDate, TransactionAmount, NewBalance, AccountID, CustomerID, EmployeeID, UserLoginID
insert into TransactionLog values ('894154874', '2', '20191010', '80', '7226.52', '123456', '10101010', '123', '10') 
insert into TransactionLog values ('484968511', '1', '20190808', '2500', '1000', '777777', '60606060', '456', '60')
insert into TransactionLog values ('289878445', '3', '20190929', '544.15', '1515.84', '111111', '20202020', '123', '20')
insert into TransactionLog values ('484984512', '6', '20190817', '84.63', '4516.22', '555555', '50505050', '123', '50')
insert into TransactionLog values ('121234878', '1', '20190716', '4500', '288.08', '444444', '40404040', '1011', '40')
insert into TransactionLog values ('535487945', '3', '20190630', '1', '36', '999999', '70707070', '789', '70')
insert into TransactionLog values ('354584896', '4', '20190426', '542.05', '11589.93', '123456', '10101010', '123', '10')

--Because AccountID is PK in its own table (OverDraftLog), it cannot appear more than once. 
--That means there can only be ONE overdraft per user. 

--AccountID, OverDraftDate, OverDraftAmount, OverDraftTransactionXML
insert into OverDraftLog values ('888888', '20190707', '50.83', 'xml file 1') 
insert into OverDraftLog values ('222222', '20191010', '10', 'xml file 2')
insert into OverDraftLog values ('333333', '20190523', '18.11', 'xml file 3')
insert into OverDraftLog values ('123456', '20191017', '235.24', 'xml file 4')

select * from UserLogins
select * from UserSecurityQuestions
select * from UserSecurityAnswers
select * from FailedTransactionErrorType
select * from FailedTransactionLog
select * from AccountType
select * from AccountStatusType
select * from SavingsInterestRates
select * from Account
select * from [Login-Account]
select * from LoginErrorLog
select * from Customer
select * from [Customer-Account]
select * from Employee
select * from TransactionType
select * from TransactionLog
select * from OverDraftLog





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

----SQL Programming
----Project Phase 2

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


----2.1.	Create a view to get all customers with checking account from ON province. [Moderate]

create view CustwChkingAcctON
as
select c.CustomerID, c.AccountID, c.CustomerFirstName + ' ' + c.CustomerMiddleInitial + '. ' + c.CustomerLastName as CustomerName, c.City, c.State, at.AccountTypeDescription from Customer c
join [Customer-Account] ca
on c.CustomerID = ca.CustomerID
join Account a
on ca.AccountID = a.AccountID
join AccountType at
on a.AccountTypeID = at.AccountTypeID
where c.State = 'ON' and at.AccountTypeDescription = 'Checking'

select * from CustwChkingAcctON


----2.2.	Create a view to get all customers with total account balance (including interest rate) greater than 5000. [Advanced]

--for this project's purpose, the mathematical formula for the interest rate will be simplified to
--balance_with_interest = currentbalance + currentbalance*interestratevalue/100/12 
-----------------------
--Nice to see: interest applied only on savings accounts; with checking accounts bearing 0 interest. (in a correlated statement)

create view CustwTotalBalanceOver5000
as
select c.CustomerID, c.AccountID, c.CustomerFirstName + ' ' + c.CustomerMiddleInitial + '. ' + c.CustomerLastName as CustomerName, 
		c.City, c.State, a.CurrentBalance, sir.InterestRateValue, cast(a.CurrentBalance*sir.InterestRateValue/12 as decimal(12,2)) as InterestBalance, 
		a.CurrentBalance + cast(a.CurrentBalance*sir.InterestRateValue/12 as decimal(12,2)) as TotalBalance from Customer c
join [Customer-Account] ca
on c.CustomerID = ca.CustomerID
join Account a
on ca.AccountID = a.AccountID
join SavingsInterestRates sir
on a.InterestSavingsRateID = sir.InterestSavingsRateID
where a.CurrentBalance + cast(a.CurrentBalance*sir.InterestRateValue/100/12 as decimal(12,2)) > 5000

select * from CustwTotalBalanceOver5000 


----2.3.	Create a view to get counts of checking and savings accounts by customer. [Moderate]

create view NrofAcctsbyCust
as
select c.CustomerID, c.CustomerFirstName + ' ' + c.CustomerMiddleInitial + '. ' + c.CustomerLastName as CustomerName,
		(select count(a.AccountID) from Account a 
			join AccountType at
			on a.AccountTypeID = at.AccountTypeID
			join [Customer-Account] ca
			on a.AccountID = ca.AccountID
			where ca.CustomerID = c.CustomerID and at.AccountTypeDescription = 'Checking'
			) as Nr_Checking_Accts,
		(select count(a.AccountID) from Account a 
			join AccountType at
			on a.AccountTypeID = at.AccountTypeID
			join [Customer-Account] ca
			on a.AccountID = ca.AccountID
			where ca.CustomerID = c.CustomerID and at.AccountTypeDescription = 'Savings'
			) as Nr_Savings_Accts
from Customer c
group by c.CustomerID, c.CustomerFirstName + ' ' + c.CustomerMiddleInitial + '. ' + c.CustomerLastName

select * from NrofAcctsbyCust


----2.4.	Create a view to get any particular user’s login and password using AccountId. [Moderate] 

select ul.UserName, ul.UserPassword from UserLogins ul
join [Login-Account] la
on ul.UserLoginID = la.UserLoginID
where la.AccountID = '777777'


----2.5.	Create a view to get all customers’ overdraft amount. [Moderate]

create view OverDrafts
as
select c.CustomerID, c.CustomerFirstName + ' ' + c.CustomerMiddleInitial + '. ' + c.CustomerLastName as CustomerName, od.OverDraftAmount, od.OverDraftDate
from Customer c
join [Customer-Account] ca
on c.CustomerID = ca.CustomerID
join Account a
on ca.AccountID = a.AccountID
join OverDraftLog od
on a.AccountID = od.AccountID

select * from OverDrafts

--OR version 2 for 2.5.
--for an aggregate view, suming the overdraft by customer
--(in this project, however, there can only be 1 overdraft per customer, due to the primary key design in the OverDraftLog table)
create view OverDrafts2
as
select c.CustomerID, sum(od.OverDraftAmount)
from Customer c
join [Customer-Account] ca
on c.CustomerID = ca.CustomerID
join Account a
on ca.AccountID = a.AccountID
join OverDraftLog od
on a.AccountID = od.AccountID
group by c.CustomerID

select * from OverDrafts2


--version 3
create view TotalOverdrafts
as
select sum(od.OverDraftAmount) as TotalOverdrafts
from Customer c
join [Customer-Account] ca
on c.CustomerID = ca.CustomerID
join Account a
on ca.AccountID = a.AccountID
join OverDraftLog od
on a.AccountID = od.AccountID

select * from TotalOverdrafts

----2.6.	Create a stored procedure to add “User_” as a prefix to everyone’s login (username). [Moderate]

select * from UserLogins

create procedure spAddPrefixtoUserName
as
begin
	update UserLogins
	set UserName = 'User_' + UserName
end

execute spAddPrefixtoUserName
select * from UserLogins


----2.7.	Create a stored procedure that accepts AccountId as a parameter and returns customer’s full name. [Advanced]

create procedure spGetCustFullNamefromAcctID 
@AccountID int
as
begin
	select c.CustomerFirstName + ' ' + c.CustomerMiddleInitial + '. ' + c.CustomerLastName as CustomerName from Customer c
	join [Customer-Account] ca
	on c.CustomerID = ca.CustomerID
	join Account a
	on ca.AccountID = a.AccountID
	where a.AccountID = @AccountID
end

execute spGetCustFullNamefromAcctID '222222'
execute spGetCustFullNamefromAcctID '333333'


--version 2 for problem 2.7.
create procedure spGetCustFullNamefromAcctID2
@AccountID int, 
@CustomerFullName varchar(50) output
as
begin
	select c.CustomerFirstName + ' ' + c.CustomerMiddleInitial + '. ' + c.CustomerLastName as CustomerName from Customer c
	join [Customer-Account] ca
	on c.CustomerID = ca.CustomerID
	join Account a
	on ca.AccountID = a.AccountID
	where a.AccountID = @AccountID
end

declare @CustomerFullName varchar(50)
execute spGetCustFullNamefromAcctID2 '555555', @CustomerFullName output
select @CustomerFullName

declare @CustomerFullName varchar(50)
execute spGetCustFullNamefromAcctID2 '55555', @CustomerFullName output
if (@CustomerFullName is null) --or @CustomerFullName = ''
	print 'No customer found.'
else select @CustomerFullName


----2.8.	Create a stored procedure that takes a deposit as a parameter and updates CurrentBalance value for that particular account. [Advanced]

--This assignment requires a transaction, in case the deposit cannot be performed
--(the account does not exist, or other reasons, amount too high, too low etc.)

create procedure spDeposittoAcctID
@Amount decimal(12,2), @AccountID int
as
begin
	begin try
		begin transaction
			update Account
			set CurrentBalance = CurrentBalance + @Amount 
			where AccountID = @AccountID 
		commit transaction
	end try
	begin catch
		print 'Error: Amount not deposited.'
		rollback transaction
	end catch
end


select * from Account
execute spDeposittoAcctID '350.25', '222222'
execute spDeposittoAcctID '1000', '123444' --(0 row(s) affected); does not print the error message... (not finished)
execute spDeposittoAcctID '1000', '123456'


----2.9.	Create a stored procedure that takes a withdrawal amount as a parameter and updates CurrentBalance value for that particular account. [Advanced]

create procedure spWithdrawFromAcctID
@Amount decimal(12,2), @AccountID int
as
begin
	begin try
		begin transaction
			if (select CurrentBalance - @Amount from Account where AccountID = @AccountID) < 0 
				rollback transaction		
			else
			update Account
			set CurrentBalance = CurrentBalance - @Amount 
			where AccountID = @AccountID 
			commit transaction	
	end try
	begin catch
		print 'Error: Withdrawal not performed.'
	end catch
end

select * from Account
execute spWithdrawFromAcctID '350.25', '222222' --insufficient funds
execute spWithdrawFromAcctID '350.25', '2222481' --account does not exist


----2.10.	Write a query to remove SSN column from Customer table. [Basic]
alter table Customer
drop column SSN


-----------------------------
-------- The End ------------
-----------------------------
