# Library-database
This is a database required for a library to store information of their members,
the library catalogue, loan history, fine payments, and overdue fines.
The database is normalised to 3NF

The database is built and designed with a number of database objects such as stored procedures, user-defined functions, views and triggers to do the following.
1. Search the catalogue for matching character strings by title. Results should besorted with most recent publication date first. This will allow them to query thecatalogue looking for a specific item.
2. Return a full list of all items currently on loan which have a due date of lessthan five days from the current date (i.e., the system date when the query is run
3. Insert a new member into the database
4. Update the details for an existing member
5. View the loan history, showing all previous and current loans, and including details of the item borrowed, borrowed date, due date and any associated fines for each loan. You should create a view containing all the required information
6. Update the current status of an item to show if an item is on loan, or is available.
7. identify the total number of loans taken on a specific date
