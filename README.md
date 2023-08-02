# Library-database
This repository contains the SQL script for creating the database schema of the EmmanuelNwambuonwo Library. The script includes the table definitions, constraints, triggers, functions, and procedures required to set up the library database.

## Introduction
The EmmanuelNwambuonwo Library database is designed to manage library-related operations such as handling members, items, loans, fines, and payments. The schema includes tables for storing member information, item details, loan records, fines, and payments. The schema also defines relationships between these tables through foreign key constraints.

## Database Schema
### Members
The Members table stores information about library members. Each member is uniquely identified by a MemberId. The table includes attributes such as UserName, Password_hash, FirstName, MiddleName, LastName, DOB, Email, Telephone, MemberStartDate, MemberEndDate, MemberReactivationDate, and AddressId.

### Address
The Address table contains details about member addresses. Each address is identified by an AddressId. The table includes attributes like AddressLine1, AddressLine2, City, Postcode, and Country.

### ItemCatlogue
The ItemCatlogue table stores information about library items. Each item is identified by an ItemId. The table includes attributes like ItemTitle, Author, DateAdded, DatePublished, ISBN, DateLost, DateRemoved, StatusId, and ItemTypeId.

### ItemType
The ItemType table lists different types of library items. Each item type is identified by an ItemTypeId.

### Status
The Status table contains various item statuses. Each status is identified by a StatusId.

### Loan
The Loan table stores loan details, including LoanId, DateTaken, DateDue, DateReturned, OverdueDays, ItemId, and MemberId.

### OverdueFine
The OverdueFine table keeps track of fines imposed on members for overdue items. Each fine is identified by a FineId.

### Payment
The Payment table contains information about payments made by members. Each payment is identified by a PaymentID.

### FormerMembers
The FormerMembers table stores archived member information. The archive is triggered when a member is deleted from the Members table.

### Stored Procedures
GetFivedayDueItems
This procedure retrieves items that are due within the next five days. It selects ItemTitle and Datedue from the ItemCatlogue and Loan tables, respectively.

### InsertMember
This procedure inserts a new member record into the Members table along with their address details into the Address table.

### UpdateMember
This procedure updates member details, including their address information.

### DeleteMember
This procedure deletes a member from the Members table and triggers an archive record in the FormerMembers table.

### InsertItemCatlogue
This procedure inserts a new item into the ItemCatlogue table.

### LoansCountThisday
This procedure returns the count of loans taken on a specific date.

## Functions
ItemSearch
This function takes an ItemName parameter and returns a table of items matching the given name along with their publication years.

## Triggers
t_update_item_status
This trigger is fired after an update on the Loan table, specifically when the DateReturned column is modified. It updates the status of the corresponding item to 'Available' if the item has been returned.

## trg_set_item_on_loan
This trigger is fired after an insert on the Loan table. It updates the status of the corresponding item to 'On Loan'.

## trg_UpdateFineAmount
This trigger is fired after an update on the Loan table, specifically when the DateReturned column is modified. It calculates the fine amount for the loan based on the updated OverdueDays and updates the FineAmount in the OverdueFine table.

## t_member_delete_archive
This trigger is fired after a member is deleted from the Members table. It archives the member's information in the FormerMembers table.

Note: The data provided in the script includes some initial records for members, addresses, and items. Feel free to modify or extend the data to suit your library's needs.

Please let me know if you have any questions or need further assistance with the library database.
